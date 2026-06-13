# SPDX-FileCopyrightText: 2026 Kirill Elagin <https://kir.elagin.me/>
# SPDX-FileCopyrightText: 2026 Kaoru Babasaki <https://kaorubb.org/>
#
# SPDX-License-Identifier: MPL-2.0 OR MIT

{ kernelName, name, config, jupyterLib, lib, pkgs, ... }:

{

  options = {
    julia = lib.mkOption {
      type = lib.types.package;
      description = "Julia package to use";
      default = pkgs.julia-bin;
      defaultText = lib.literalExpression "pkgs.julia-bin";
    };

    project = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      description = "Path to the directory containing Project.toml and Manifest.toml";
      default = null;
      example = "@.";
    };

    packages = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      description = "List of Julia packages to include with the kernel (only if project is null)";
      default = [ ];
      example = [ "Plots" "DataFrames" ];
    };

    extraArgs = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      description = "Extra arguments to pass to the Julia executable";
      default = [ "-i" "--startup-file=yes" "--color=yes" ];
      example = [ "-i" "--color=yes" ];
    };
  };

  config =
    let
      kernelEnv = config.julia.withPackages ([ "IJulia" ] ++ config.packages);

      spec = {
        argv = [
          "${kernelEnv}/bin/julia"
        ] ++ lib.optional (config.project != null) "--project=${config.project}"
          ++ config.extraArgs ++ [
          "-e" ''
            using Pkg
            ${lib.optionalString (config.project != null) "Pkg.instantiate()"}
            import IJulia
            IJulia.run_kernel()
          ''
          "{connection_file}"
        ];

        display_name = "Julia (${kernelName})";

        language = "julia";

        logo_svg = "${config.julia}/share/doc/julia/html/en/assets/logo.svg";
      };
    in {
      outDir = jupyterLib.buildKernelSpec pkgs name spec;
    };

}
