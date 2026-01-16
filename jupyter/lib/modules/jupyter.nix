# SPDX-FileCopyrightText: 2026 Kirill Elagin <https://kir.elagin.me/>
#
# SPDX-License-Identifier: MPL-2.0 OR MIT

{ config, jupyterLib, lib, ... }:

{
  options = {
    pkgs = lib.mkOption {
      type = lib.types.pkgs;
      description = "Nixpkgs to use for trivial builders and as the default source of all packages";
    };

    pythonInterpreter = lib.mkOption {
      type = lib.types.functionTo lib.types.package;
      description = "The selector for the Python interpreter to be used by Jupyter and all packages in its environment";
      default = pkgs: pkgs.python3;
      defaultText = lib.literalExpression ''pkgs: pkgs.python3'';
      example = lib.literalExpression ''pkgs: pkgs.python315'';
    };

    jupyterEnvPackages = lib.mkOption {
      type = lib.types.functionTo (lib.types.listOf lib.types.package);
      description = "Selector for Python packages installed alongside Jupyter into the Python environment used to run it";
      default = _: [];
      defaultText = lib.literalExpression ''_: []'';
      example = lib.literalExpression ''pp: with pp; [ plotly ]'';
    };

    jupyterExtensions = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      description = "Packages containing Jupyter extensions to install";
      default = [ ];
    };

    kernelTypes = lib.mkOption {
      type = lib.types.attrsOf (lib.types.deferredModuleWith {
        staticModules = [ ./kernel.nix ];  # This is what defines the output config options commont to all kernel types
      });
      description = "Supported kernel types";
      example = {
        kernelspec = ./moduels/kernelspec.nix;  # kernel defined directly by a kernelspec
      };
    };

    kernels = lib.mkOption {
      type = lib.types.attrsOf (lib.types.attrTag (lib.mapAttrs (name: kernelTypeModule:
        lib.mkOption {
          type = lib.types.submoduleWith {
            modules = [{
              imports = [
                kernelTypeModule
                ({ _prefix, ... }: {
                  _module.args = {
                    pkgs = config.pkgs;
                    kernelName = lib.last (lib.init _prefix);  # kernels.<kernelName>.<kernelType> (i.e. `name` = kernel type)
                    jupyterConfig = config;
                  };
                })
              ];
            }];
            specialArgs = { inherit jupyterLib; };
          };
          description = "${name} kernel definition";
        }
      ) config.kernelTypes));
      description = "Jupter kernels definitions";
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
      inherit (config) pkgs;

      python = config.pythonInterpreter pkgs;

      jupyterConf = pkgs.writeTextFile {
        name = "jupyterConf";
        destination = "/etc/jupyter/jupyter_config.json";
        text = lib.generators.toJSON { } {
          "KernelSpecManager" = {
            "ensure_native_kernel" = config.enableNativeKernel;
          };
          "LabApp" = {
            "extension_manager" = "readonly";
          };
        };
      };

      kernelsDir = "$out/share/jupyter/kernels";

      extensionsDir = "share/jupyter/labextensions";
      extensions = pkgs.symlinkJoin {
        name = "jupyter-labextensions";
        paths = config.jupyterExtensions;
        stripPrefix = "/${extensionsDir}";
        failOnMissing = true;
      };

      # This is annoying but all the values in `attrTag` remain one-level deep
      # under the tag, which we do not know. But we know that there is exactly one...
      kernels = lib.mapAttrs (_: v: v.${lib.head (lib.attrNames v)}) config.kernels;
    in {
      jupyterEnvPackages = pp:
        lib.concatMap (kern: kern.jupyterEnvPackages pp) (lib.attrValues kernels);

      jupyterExtensions = [
        python.pkgs.jupyterlab-widgets
        python.pkgs.jupyterlab-pygments
      ] ++ lib.concatMap (kern: kern.jupyterExtensions) (lib.attrValues kernels);

      outDrv = python.buildEnv.override (orig: {
        buildEnv = { paths, ... }@args: orig.buildEnv (args // {
          paths = paths ++ [
            jupyterConf
          ];

          meta = {
            changelog = "https://github.com/kirelagin/jupyter.nix/blob/main/CHANGELOG.md";
            homepage = "https://github.com/kirelagin/jupyter.nix";
            license = with lib.licenses; [ mpl20 mit ];
            mainProgram = "jupyter-lab";
          };
        });

        extraLibs = [
          python.pkgs.jupyterlab
        ] ++ config.jupyterEnvPackages python.pkgs;

        postBuild = ''
          # jupyterlab depends on ipykernel, which ships with a kernel spec for itself,
          # so it gets symlinked into our environment, but we do not want it!
          # XXX: this might be a bit fragile, since we assume that we can `rm` it,
          # which might not be always true (e.g. if there parent is a symlink into another drv).
          rm -rf -- "${kernelsDir}"
          mkdir -p -- "${kernelsDir}"
        '' + lib.concatStringsSep "\n" (lib.mapAttrsToList (name: kern: ''
          ln -sT -- "${kern.outDir}" "${kernelsDir}/${name}"
        '') kernels) + ''
          rm -rf -- "$out/${extensionsDir}"
          ln -sT -- "${extensions}" "$out/${extensionsDir}"
        '';
      });
    };

}
