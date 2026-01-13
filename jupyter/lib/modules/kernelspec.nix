# SPDX-FileCopyrightText: 2026 Kirill Elagin <https://kir.elagin.me/>
#
# SPDX-License-Identifier: MPL-2.0 OR MIT

{ name, config, lib, pkgs, ... }:

{
  # See Jupyter docs for details:
  # https://jupyter-client.readthedocs.io/en/latest/kernels.html#kernel-specs
  options = {
    spec = {
      argv = lib.mkOption {
        type = lib.types.nonEmptyListOf lib.types.str;
        description = "Command line to start the kernel";
        example = ["python" "-m" "ipykernel_launcher" "-f" "{connection_file}"];
      };

      display_name = lib.mkOption {
        type = lib.types.nonEmptyStr;
        description = "Name for the kernel";
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


      # The options below are not part of the kernel spec json and
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

      ### Output:

      # This module generates the specification into the following
      # output option, which has to be defined by the evaluator:
      # outDir = lib.mkOption {
      #   type = lib.types.package;
      # };
    };
  };

  config =
    let
      jsonSpec = lib.generators.toJSON { } (lib.filterAttrs (k: v: v != null) config.spec);
    in {
      outDir = pkgs.runCommandLocal "jupyter-kernelspec-${name}" { } (''
        mkdir -p -- "$out"
        ln -s -- "${pkgs.writeText "${name}.json" jsonSpec}" "$out/kernel.json"
      '' + lib.optionalString (config.spec.logo_svg != null) ''
        ln -s -- "${config.spec.logo_svg}" "$out/logo-svg.svg"
      '' + lib.optionalString (config.spec.logo_32 != null) ''
        ln -s -- "${config.spec.logo_64}" "$out/logo-64x64.png"
      '' + lib.optionalString (config.spec.logo_svg != null) ''
        ln -s -- "${config.spec.logo_32}" "$out/logo-32x32.png"
      '');
    };
}
