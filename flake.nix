{
	description = "libopenmpt - Cross-platform C/C++ library for decoding tracker music files";

	inputs = {
		nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
	};

	outputs = { self, nixpkgs }:
		let
			systems = [ "aarch64-darwin" "x86_64-darwin" "x86_64-linux" "aarch64-linux" ];
			forAllSystems = nixpkgs.lib.genAttrs systems;
		in {
			devShells = forAllSystems (system:
				let
					pkgs = import nixpkgs { inherit system; };
				in {
					default = pkgs.mkShell {
						packages = with pkgs; [
							zig
							git
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
