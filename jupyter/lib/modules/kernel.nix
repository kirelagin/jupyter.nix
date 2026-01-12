# SPDX-FileCopyrightText: 2026 Kirill Elagin <https://kir.elagin.me/>
#
# SPDX-License-Identifier: MPL-2.0 OR MIT

{ name, config, lib, pkgs, ... }:

{
  options = {
    outDir = lib.mkOption {
      type = lib.types.package;
      description = "Output kernel definition";
      internal = true;
      readOnly = true;
    };

    jupyterEnvPackages = lib.mkOption {
      type = lib.types.functionTo (lib.types.listOf lib.types.package);
      description = "Selector for extra Python packages to install into the Jupyter python environment";
      default = _: [];
      defaultText = lib.literalExpression ''_: []'';
    };
  };
}
