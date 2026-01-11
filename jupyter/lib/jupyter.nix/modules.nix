# SPDX-FileCopyrightText: 2026 Kirill Elagin <https://kir.elagin.me/>
#
# SPDX-License-Identifier: MPL-2.0 OR MIT

{ config, lib, pkgs, ... }:

let

  jupyterTypes = import ./types.nix { inherit lib pkgs; };

in {

  options = {
    jupyterEnvPackages = lib.mkOption {
      type = lib.types.functionTo (lib.types.listOf lib.types.package);
      description = "Selector for Python packages installed alongside Jupyter into the Python environment used to run it";
      default = _: [];
      defaultText = lib.literalExpression ''_: []'';
    };

    kernels = lib.mkOption {
      type = jupyterTypes.kernels;
      description = "Jupter kernels to enable";
      default = {};
      defaultText = lib.literalExpression ''{}'';
    };

    enableNativeKernel = lib.mkOption {
      type = lib.types.bool;
      description = ''Whether to add the “native” kernel, i.e. the Python interpreter used to run Jupyter itself'';
      default = false;  # Note: Upstream Jupyter default is `true`!
      example = true;
    };

    outDrv = lib.mkOption {
      type = lib.types.package;
      description = "Output derivation with the configured Jupyter environment";
      internal = true;
      readOnly = true;
    };
  };

  config =
    let
      pp = pkgs.python3Packages;
      jupyterConfDir = "$out/etc/jupyter";
      jupyterConf = {
        "KernelSpecManager" = {
          "ensure_native_kernel" = config.enableNativeKernel;
        };
      };
      kernelsDir = "$out/share/jupyter/kernels";
    in {
      jupyterEnvPackages = pp:
        lib.concatMap (kern: kern.jupyterEnvPackages pp) (lib.attrValues config.kernels);

      outDrv = (pkgs.python3.buildEnv.override {
        extraLibs = [
          pp.jupyterlab
        ] ++ config.jupyterEnvPackages pp;

        postBuild = ''
          mkdir -p -- "${jupyterConfDir}"
          printf -- '%s\n' '${builtins.toJSON jupyterConf}' > "${jupyterConfDir}/jupyter_config.json"

          rm -rf "${kernelsDir}"
          mkdir -p -- "${kernelsDir}"
        '' + lib.concatMapStringsSep "\n" (kern: ''
          ln -s -t "${kernelsDir}" -- "${if lib.isString kern || lib.isDerivation kern then kern else kern.outDir}"
        '') (lib.attrValues config.kernels);
      }).overrideAttrs ( {
        meta = {
          changelog = "https://github.com/kirelagin/jupyter.nix/blob/main/CHANGELOG.md";
          homepage = "https://github.com/kirelagin/jupyter.nix";
          license = with lib.licenses; [ mpl20 mit ];
          mainProgram = "jupyter-lab";
        };
      });
    };

}
