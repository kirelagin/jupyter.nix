# SPDX-FileCopyrightText: 2026 Kirill Elagin <https://kir.elagin.me/>
#
# SPDX-License-Identifier: MPL-2.0 OR MIT

{ kernelName, name, config, jupyterConfig, jupyterLib, lib, pkgs, ... }:

{

  options = {
    packages = lib.mkOption {
      type = lib.types.functionTo (lib.types.listOf lib.types.package);
      description = "Selector for Python packages to include with the kernel";
      default = _: [];
      defaultText = lib.literalExpression ''_: []'';
      example = lib.literalExpression ''pp: with pp; [ plotly ]'';
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
      # NOTE: We always use the same Python interpreter for the kernel as for Jupyter itself.
      # Python packages that need to be installed into both environments may expect to have
      # “compatible” versions (whatever this means) – an easy way to shoot onself in the foot.
      # Should we allow this and let the user deal with the issues?
      kernelEnv = (jupyterConfig.pythonInterpreter pkgs).withPackages (pp: [
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

      jupyterExtensions =
        let
          pp = (jupyterConfig.pythonInterpreter pkgs).pkgs;
        in
          lib.optionals config.withPlotly [
            pp.anywidget
            pp.plotly
          ];

      # ipympl for Matplotlib needs to be installed in both envs
      jupyterEnvPackages = pp:
        lib.optionals config.withMatplotlib [
          pp.ipympl
        ];
    };

}
