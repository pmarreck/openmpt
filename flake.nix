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
		in {
			packages = forAllSystems (system:
				let
					pkgs = import nixpkgs { inherit system; };
					zig = zig-overlay.packages.${system}."0.16.0";
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
							zig build -Doptimize=ReleaseFast --prefix $out
						'';
						installPhase = "true"; # build.zig installs lib + headers to $out
					};
				});

			checks = forAllSystems (system:
				let
					pkgs = import nixpkgs { inherit system; };
					zig = zig-overlay.packages.${system}."0.16.0";
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
							zig build test -Doptimize=ReleaseFast
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
