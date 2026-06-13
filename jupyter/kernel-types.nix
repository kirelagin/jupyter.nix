# SPDX-FileCopyrightText: 2026 Kirill Elagin <https://kir.elagin.me/>
#
# SPDX-License-Identifier: MPL-2.0 OR MIT

{ kernelspecKernel }:

{
  kernelspec = kernelspecKernel { };

  ihaskell = ./kernel-types/ihaskell.nix;
  ipykernel = ./kernel-types/ipykernel.nix;
  ijulia = ./kernel-types/ijulia.nix;
}
