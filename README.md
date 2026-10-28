This project grew out of frustration with installing ProB by hand. The official route is to download the `ProB.linux64.tar.gz` tarball, extract it, and then install and manage its dependencies yourself: Java 8+ for the B parser, GraphViz for visualizations, and native libraries such as GMP, libuuid and Z3 for the bundled helpers.

Nix flake packaging the [ProB 1.16.1](https://prob.hhu.de/w/index.php/Download) command-line tool `probcli`, an animator, constraint solver and model checker for the B method.

## Usage

```sh
nix shell github:Quoteme/probcli
```

## Use in another flake

```nix
{
  inputs = {
    probcli.url = "github:Quoteme/probcli";
    nixpkgs.follows = "probcli/nixpkgs";
  };

  outputs =
    { nixpkgs, probcli, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        packages = [ probcli.packages.${system}.prob ];
      };
    };
}
```
