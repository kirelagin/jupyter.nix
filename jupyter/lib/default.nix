# SPDX-FileCopyrightText: 2026 Kirill Elagin <https://kir.elagin.me/>
#
# SPDX-License-Identifier: MPL-2.0 OR MIT

{ lib }:
let
  eval = import ./jupyter.nix/eval.nix { inherit lib; };

in {
  inherit (eval) makeJupyterLab;
  kernels = {
    python = import ./kernels/python.nix { inherit lib; };
  };
}
