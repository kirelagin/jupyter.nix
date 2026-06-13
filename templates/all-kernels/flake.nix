{
  inputs = {
    nixpkgs = { };
    flake-utils.url = "github:numtide/flake-utils";
    jupyter = {
      url = "github:kirelagin/jupyter.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      jupyter,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        packages.default = jupyter.lib.makeJupyterLab {
          inherit pkgs;

          kernels = {
            "Python 3".ipykernel = {
              #packages =
              #  pythonPackages: with pythonPackages; [
              #    # add Python packages
              #  ];
              #withPlotly = true;
              #withMatplotlib = true;
            };

            "Haskell".ihaskell = {
              #packages =
              #  haskellPackages: with haskellPackages; [
              #    # add Haskell packages
              #  ];
              #rtsOptions = [ ];
            };

            "Julia".ijulia = {
              #packages = [
              #  # add Julia packages
              #];
              #project = "@.";
            };
          };

          #collaboration.enable = true;

          #jupyterExtensions = [ ];

          #jupyterEnvPackages=
          #  pythonPackages: with pythonPackages; [
          #    # add Python packages to the _Jupyter server_ env
          #  ];

        };
      }
    );
}
