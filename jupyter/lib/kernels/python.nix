# SPDX-FileCopyrightText: 2026 Kirill Elagin <https://kir.elagin.me/>
#
# SPDX-License-Identifier: MPL-2.0 OR MIT

{ lib }:

{

makePythonKernel =
  { pkgs
  , packages ? _:[], jupyterEnvPackages ? _:[]

  , withMatplotlib ? false
  , withPlotly ? false
  }:
  let
    kernelEnv = pkgs.python3.withPackages (pp: [
      pp.ipykernel
    ] ++ lib.optionals withPlotly [
      pp.anywidget  # Required for FigureWidget
      pp.nbconvert  # Required for the mimetype renderer (the default one for Jupyter)
      pp.pandas  # Dependency of plotly
      pp.plotly
    ] ++ lib.optionals withMatplotlib [
      pp.ipympl
      pp.matplotlib
    ] ++ packages pp);
  in {
    spec = {
      argv = [
        "${kernelEnv.interpreter}"
        "-m" "ipykernel_launcher"
        "-f" "{connection_file}"
      ];

      language = "python";

      logo_svg = "${kernelEnv}/${kernelEnv.sitePackages}/ipykernel/resources/logo-svg.svg";
      logo_64 = "${kernelEnv}/${kernelEnv.sitePackages}/ipykernel/resources/logo-64x64.png";
      logo_32 = "${kernelEnv}/${kernelEnv.sitePackages}/ipykernel/resources/logo-32x32.png";
    };

    jupyterEnvPackages = pp:
      # Plotly itself and anywidget have to be installed in both envs!
      jupyterEnvPackages pp ++ lib.optionals withPlotly [
        pp.anywidget
        pp.plotly
      ] ++ lib.optionals withMatplotlib [
        pp.ipympl
      ];
  };

}
