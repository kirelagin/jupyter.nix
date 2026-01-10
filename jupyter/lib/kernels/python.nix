# SPDX-FileCopyrightText: 2026 Kirill Elagin <https://kir.elagin.me/>
#
# SPDX-License-Identifier: MPL-2.0 OR MIT

{ lib }:

{

mkPythonKernel = { pkgs, packages }:
  let
    kernelEnv = pkgs.python3.withPackages (pp: [
      pp.ipykernel
    ] ++ packages pp);
  in {
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

}
