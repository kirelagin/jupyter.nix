# SPDX-FileCopyrightText: 2026 Kirill Elagin <https://kir.elagin.me/>
#
# SPDX-License-Identifier: MPL-2.0 OR MIT

{ kernelName, name, config, jupyterLib, lib, pkgs, ... }:

{

  options = {
    packages = lib.mkOption {
      type = lib.types.functionTo (lib.types.listOf lib.types.package);
      description = "Selector for Python packages to include with the kernel";
      default = _: [];
      defaultText = lib.literalExpression ''_: []'';
      # TODO: example
    };

    withMatplotlib = lib.mkOption {
      type = lib.types.bool;
      description = "Add Matplotlib support";
      default = false;
      example = true;
    };

    withPlotly = lib.mkOption {
      type = lib.types.bool;
      description = "Add Plotly support";
      default = false;
      example = true;
    };
  };

  config =
    let
      kernelEnv = pkgs.python3.withPackages (pp: [
        pp.ipykernel
      ] ++ lib.optionals config.withPlotly [
        pp.anywidget  # Required for FigureWidget
        pp.nbconvert  # Required for the mimetype renderer (the default one for Jupyter)
        pp.pandas  # Dependency of plotly
        pp.plotly
      ] ++ lib.optionals config.withMatplotlib [
        pp.ipympl
        pp.matplotlib
      ] ++ config.packages pp);

      spec = {
        argv = [
          "${kernelEnv.interpreter}"
          "-m" "ipykernel_launcher"
          "-f" "{connection_file}"
        ];

        display_name = "Python (${kernelName})";

        language = "python";

        logo_svg = "${kernelEnv}/${kernelEnv.sitePackages}/ipykernel/resources/logo-svg.svg";
        logo_64 = "${kernelEnv}/${kernelEnv.sitePackages}/ipykernel/resources/logo-64x64.png";
        logo_32 = "${kernelEnv}/${kernelEnv.sitePackages}/ipykernel/resources/logo-32x32.png";
      };
    in {
      outDir = jupyterLib.buildKernelSpec pkgs name spec;

      # Plotly itself and anywidget have to be installed in both envs!
      # Same for ipympl for Matplotlib
      jupyterEnvPackages = pp:
        lib.optionals config.withPlotly [
          pp.anywidget
          pp.plotly
        ] ++ lib.optionals config.withMatplotlib [
          pp.ipympl
        ];
    };

}
