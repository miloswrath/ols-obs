{
  description = "A Nix-flake-based Python development environment";

  inputs.nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0.1.*.tar.gz";

  outputs = { self, nixpkgs }:
    let
      supportedSystems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      forEachSupportedSystem = f: nixpkgs.lib.genAttrs supportedSystems (system: f {
        pkgs = import nixpkgs { inherit system; };
      });

      version = "3";
    in {
      devShells = forEachSupportedSystem ({ pkgs }:
        let
          concatMajorMinor = v:
            pkgs.lib.pipe v [
              pkgs.lib.versions.splitVersion
              (pkgs.lib.sublist 0 2)
              pkgs.lib.concatStrings
            ];

          python = pkgs."python${concatMajorMinor version}";

          catppuccin-jupyterlab = python.pkgs.buildPythonPackage rec {
            pname = "catppuccin_jupyterlab";
            version = "0.2.4";
            format = "wheel";

            src = pkgs.fetchPypi {
              inherit pname version;
              format = "wheel";
              python = "py3";
              dist = "py3";
              abi = "none";
              platform = "any";
              hash = "sha256-ZDg5scRuk+SXvrledB1A3VhfxOSJpEwsbOiahpqc72c=";
            };

            doCheck = false;
          };

          actipy = python.pkgs.buildPythonPackage rec {
            pname = "actipy";
            version = "2.0.0"; # Latest version as of 2025-08-22; update as needed
            format = "wheel";

            src = pkgs.fetchPypi {
              inherit pname version;
              format = "wheel";
              python = "py3";
              dist = "py3";
              abi = "none";
              platform = "any";
              hash = "sha256-HSVodOlV3vqniRHlwEgThKWF19fg4bDirDCDCnz32tA=";
            };

            doCheck = false;
          };

          pythonEnv = python.withPackages (ps:
            [
              ps.jupyterlab
              ps.ipykernel
              ps.pandas
              ps.numpy
              ps.matplotlib
              ps.seaborn
              ps.plotly
              ps.requests
              ps.httpx
              ps.scipy
              ps.pyyaml
              ps.pyarrow
              ps.jpype1
              ps.statsmodels
            ] ++ [ catppuccin-jupyterlab actipy ]
          );
        in {
          default = pkgs.mkShellNoCC {
            packages = [
              pythonEnv
              pkgs.git
              pkgs.jdk21 # Add OpenJDK 21 to provide JVM
            ];

            postShellHook = ''
              KERNEL_NAME="jl-313"
              KERNEL_DIR="$HOME/.local/share/jupyter/kernels/$KERNEL_NAME"
              if [ ! -d "$KERNEL_DIR" ]; then
                python -m ipykernel install --user \
                  --name "$KERNEL_NAME" \
                  --display-name "Python 3.9 (flake)" >/dev/null
              fi
              # Set JAVA_HOME to the JDK path
              export JAVA_HOME=${pkgs.jdk21}
            '';
          };
        });
    };
}
