# SPDX-FileCopyrightText: 2026 Kirill Elagin <https://kir.elagin.me/>
#
# SPDX-License-Identifier: MPL-2.0 OR MIT

{ lib, pkgs }:

rec {

  kernels = lib.types.attrsOf (lib.types.either lib.types.path kernel);

  kernel = lib.types.submodule ({ name, config, ...}: {
    # See Jupyter docs for details:
    # https://jupyter-client.readthedocs.io/en/latest/kernels.html#kernel-specs
    options = {
      argv = lib.mkOption {
        type = lib.types.nonEmptyListOf lib.types.str;
        description = "Command line to start the kernel";
        example = ["python" "-m" "ipykernel_launcher" "-f" "{connection_file}"];
      };

      display_name = lib.mkOption {
        type = lib.types.nonEmptyStr;
        description = "Name for the kernel";
        default = name;
        defaultText = "The name it is given in the kernels attrset";
        example = "Python";
      };

      language = lib.mkOption {
        type = lib.types.nonEmptyStr;
        description = "Language name";
        example = "python";
      };

      interrupt_mode = lib.mkOption {
        type = lib.types.nullOr (lib.types.oneOf [ "signal" "message" ]);
        description = "How the client interrupts cell execution for this kernel";
        default = null;
        example = "message";
      };

      env = lib.mkOption {
        type = lib.types.attrsOf lib.types.str;
        description = "Environment variables to set for the kernel";
        default = { };
      };

      metadata = lib.mkOption {
        type = lib.types.attrsOf lib.types.anything;
        description = "Additional kernel metadata";
        default = { };
      };


      # The options below are not part of the kernel spec and
      # do not seem to be well-documented.

      logo_svg = lib.mkOption {
        type = lib.types.nullOr lib.types.path;
        description = "SVG logo for the kernel";
        default = null;
      };
      logo_64 = lib.mkOption {
        type = lib.types.nullOr lib.types.path;
        description = "64×64 PNG logo for the kernel";
        default = null;
      };
      logo_32 = lib.mkOption {
        type = lib.types.nullOr lib.types.path;
        description = "32×32 PNG logo for the kernel";
        default = null;
      };

      ###

      outDir = lib.mkOption {
        type = lib.types.package;
        description = "Output kernel definition";
        internal = true;
        readOnly = true;
      };

    };

    config = {
      outDir =
        let
          outName = "jupyter-kernel-${config.language}";
          cleanConfig = {
            # The attrs here have to be exactly the same as the options in the module...
            # Ideally, we would just do `removeAttrs config ["_module"]`, but this does not work for weird lazyness reasons
            inherit (config) argv display_name language interrupt_mode env metadata;
          };
          jsonSpec = pkgs.writeText "${outName}.json" (builtins.toJSON (lib.filterAttrs (k: v: v != null) cleanConfig));
        in pkgs.runCommandLocal outName { } (''
          mkdir -p -- "$out"
          ln -s -- "${jsonSpec}" "$out/kernel.json"
        '' + lib.optionalString (config.logo_svg != null) ''
          ln -s -- "${config.logo_svg}" "$out/logo-svg.svg"
        '' + lib.optionalString (config.logo_32 != null) ''
          ln -s -- "${config.logo_64}" "$out/logo-64x64.png"
        '' + lib.optionalString (config.logo_svg != null) ''
          ln -s -- "${config.logo_32}" "$out/logo-32x32.png"
        '');
    };
  });

}
