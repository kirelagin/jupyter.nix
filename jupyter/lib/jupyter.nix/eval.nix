# SPDX-FileCopyrightText: 2026 Kirill Elagin <https://kir.elagin.me/>
#
# SPDX-License-Identifier: MPL-2.0 OR MIT

{ lib }:

rec {

  evalJupyterConfig = config:
    lib.evalModules {
      modules = [
        { inherit config; }
        ./modules.nix
      ];
    };

  makeJupyterLab = config:
    (evalJupyterConfig config).config.outDrv;

}
