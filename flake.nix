{
  description = "ProB 1.16.1 (probcli) as a Nix package and dev shell";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};

      prob = pkgs.stdenv.mkDerivation rec {
        pname = "prob";
        version = "1.16.1";

        src = pkgs.fetchurl {
          url = "https://stups.hhu-hosting.de/downloads/prob/tcltk/releases/${version}/ProB.linux64.tar.gz";
          hash = "sha256-6fDHSmu/F3yRRtAYaa+hxCdvX8jTtnDzGwIw8DV1O+8=";
        };

        nativeBuildInputs = [
          pkgs.autoPatchelfHook
          pkgs.makeWrapper
        ];

        # Libraries needed by the bundled helper binaries / extensions in lib/
        buildInputs = [
          pkgs.stdenv.cc.cc.lib # libstdc++, libgcc_s
          pkgs.gmp # cspmf
          pkgs.libuuid # libczmq
          pkgs.z3 # z3interface.so
        ];

        # Only the CLI is packaged; the Tcl/Tk GUI binary is dropped.
        dontConfigure = true;
        dontBuild = true;
        dontStrip = true;

        installPhase = ''
          runHook preInstall

          mkdir -p $out/share/prob $out/bin
          cp -r . $out/share/prob
          rm -f $out/share/prob/prob $out/share/prob/StartProB.sh
          chmod +x $out/share/prob/probcli

          # probcli looks up lib/, stdlib/ etc. relative to its own location,
          # so keep the tree intact and wrap the binary.
          makeWrapper $out/share/prob/probcli $out/bin/probcli \
            --prefix PATH : ${pkgs.lib.makeBinPath [ pkgs.jre pkgs.graphviz ]}

          runHook postInstall
        '';

        # Make sure the bundled libs (libzmq, libczmq, libbliss) are found.
        preFixup = ''
          addAutoPatchelfSearchPath $out/share/prob/lib
        '';

        meta = {
          description = "Animator, constraint solver and model checker for the B method";
          homepage = "https://prob.hhu.de";
          license = pkgs.lib.licenses.epl10;
          platforms = [ "x86_64-linux" ];
          mainProgram = "probcli";
        };
      };
    in
    {
      packages.${system} = {
        inherit prob;
        default = prob;
      };

      apps.${system}.default = {
        type = "app";
        program = "${prob}/bin/probcli";
      };

      devShells.${system}.default = pkgs.mkShell {
        packages = [
          prob
          pkgs.jre
          pkgs.graphviz
        ];
      };
    };
}
