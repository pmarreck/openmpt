{
	description = "libopenmpt - Cross-platform C/C++ library for decoding tracker music files";

	inputs = {
		nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
		zig-overlay = {
			url = "github:mitchellh/zig-overlay";
			inputs.nixpkgs.follows = "nixpkgs";
		};
	};

	outputs = { self, nixpkgs, zig-overlay }:
		let
			systems = [ "aarch64-darwin" "x86_64-darwin" "x86_64-linux" "aarch64-linux" ];
			forAllSystems = nixpkgs.lib.genAttrs systems;

			# Zig 0.16's bundled libc++ #include chain
			#   <array> -> <cwchar> -> <wchar.h> -> <__mbstate_t.h> -> <bits/alltypes.h>
			# resolves `bits/alltypes.h` only under the musl C library headers
			# Zig ships (`lib/zig/libc/include/<arch>-linux-musl/bits/alltypes.h`).
			# Native linux-gnu targets have no fallback for that header, so the
			# default `zig build` on Linux fails across every translation unit
			# in libopenmpt with "'bits/alltypes.h' file not found".
			# Cross-target musl on Linux. macOS uses the Apple SDK and works as-is.
			# (Mirrors the same pattern used in jpegz/flake.nix.)
			zigTargetFor = system:
				if system == "x86_64-linux"  then "-Dtarget=x86_64-linux-musl"
				else if system == "aarch64-linux" then "-Dtarget=aarch64-linux-musl"
				else "";
		in {
			packages = forAllSystems (system:
				let
					pkgs = import nixpkgs { inherit system; };
					zig = zig-overlay.packages.${system}."0.16.0";
					targetFlag = zigTargetFor system;
				in {
					default = pkgs.stdenv.mkDerivation {
						pname = "openmpt";
						version = "0.9.0";
						src = ./.;
						nativeBuildInputs = [ zig ];
						dontConfigure = true;
						buildPhase = ''
							export HOME=$TMPDIR
							export ZIG_GLOBAL_CACHE_DIR=$TMPDIR/zig-cache
							mkdir -p "$ZIG_GLOBAL_CACHE_DIR"
							zig build -Doptimize=ReleaseFast ${targetFlag} --prefix $out
						'';
						installPhase = "true"; # build.zig installs lib + headers to $out
					};
				});

			checks = forAllSystems (system:
				let
					pkgs = import nixpkgs { inherit system; };
					zig = zig-overlay.packages.${system}."0.16.0";
					targetFlag = zigTargetFor system;
				in {
					test = pkgs.stdenv.mkDerivation {
						pname = "openmpt-test";
						version = "0.9.0";
						src = ./.;
						nativeBuildInputs = [ zig ];
						dontConfigure = true;
						buildPhase = ''
							export HOME=$TMPDIR
							export ZIG_GLOBAL_CACHE_DIR=$TMPDIR/zig-cache
							mkdir -p "$ZIG_GLOBAL_CACHE_DIR"
							zig build test -Doptimize=ReleaseFast ${targetFlag}
							touch $out
						'';
						installPhase = "true";
					};
				});

			devShells = forAllSystems (system:
				let
					pkgs = import nixpkgs { inherit system; };
					zig = zig-overlay.packages.${system}."0.16.0";
				in {
					default = pkgs.mkShell {
						packages = [
							zig
							pkgs.git
						];
						shellHook = ''
							echo "libopenmpt development shell"
							echo "Build with: zig build"
							echo "Test with:  zig build test"
						'';
					};
				});
		};
}
