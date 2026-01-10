# SPDX-FileCopyrightText: 2026 Kirill Elagin <https://kir.elagin.me/>
#
# SPDX-License-Identifier: MPL-2.0 OR MIT

# This file is provided for compatibility, but, please, use this project as a flake.

{
  pkgs ? import <nixpkgs> { },
  ...
}:

{
  jupyterlib = import ./jupyter/lib { inherit (pkgs) lib; };
}
