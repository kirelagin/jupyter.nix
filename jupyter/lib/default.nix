# SPDX-FileCopyrightText: 2026 Kirill Elagin <https://kir.elagin.me/>
#
# SPDX-License-Identifier: MPL-2.0 OR MIT

{ lib }:

let
  kernelTypes = {
    kernelspec = ./modules/kernelspec.nix;
    ihaskell = ../kernel-types/ihaskell.nix;
    ipykernel = ../kernel-types/ipykernel.nix;
  };

  jupyterLib = rec {
    evalJupyterConfig = config:
      lib.evalModules {
        modules = [
          ./modules/jupyter.nix
          {
            config = { inherit kernelTypes; };
          }
          { inherit config; }
        ];
        specialArgs = {
          inherit jupyterLib;
        };
      };

    makeJupyterLab = config:
      (evalJupyterConfig config).config.outDrv;

    inherit (import ./kernelspec.nix { inherit lib; }) buildKernelSpec;
  };

in jupyterLib
