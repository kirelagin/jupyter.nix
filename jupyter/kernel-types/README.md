<!--
SPDX-FileCopyrightText: 2026 Kirill Elagin <https://kir.elagin.me/>

SPDX-License-Identifier: MPL-2.0 or MIT
-->

# How to make a kernel type

## The basics

Start with the following template:

```nix
{ kernelName, name, config, jupyterLib, lib, pkgs, ... }:

{

  options = {
    /* TODO */
  };

  config = {
    /* mandatory */ outDir = /* TODO */;
    /* optional */  jupyterEnvPackages = pp: [ /* ...packages... */ ];
  };

}
```

Each kernel module definition will receive the following arguments:

* Standard NixOS module system ones:
  * `config` – current module’s configuration fixpoint;
  * `lib` – Nixpkgs library;
  * `pkgs` – Nixpkgs packages set;
  * `name` – name of the attribute in the attrset the config is in
    (_note:_ this is always the _last_ attribute name, so, in jupyter.nix,
    it is the kernel type, not the kernel name!);
  * ... all other standard arguments.
* Jupyter.nix specific arguments:
  * `kernelName` – actually the name of this kernel in the attrset
    (i.e. the _second-last_ attribute name);
  * `jupyterLib` – the jupyter.nix library.

You can define whatever options make sense for this kernel type.
Your goal is to produce a Jupyter kernelspec directory and put it into
the `outDir` config option.
You may also assign to the `jupyterEnvPackages` option – this will cause
the packages you select from the Python packages set (given to your function
as `pp`) to get installed into the Python environment that Jupyter is running from.

_Note: you do not need to define the `outDir` and `jupyterEnvPackages` options in your
module, they will be defined automatically._

## Kernel spec helpers

The directory for `outDir` needs to follow a special format understood by Jupyter.
Rather than creating it yourself, you can write a kernel spec in Nix
(see [lib/modules/kernelspec.nix](../lib/modules/kernelspec.nix) for the documentation
of available options).
And then you can just pass it to `jupyterLib.buildKernelSpec`:

```nix
{ # ...
  config =
    let
      spec = {
        # prepare the spec
      };
    in {
      outDir = jupyterLib.buildKernelSpec pkgs name spec;
    };
}
```

## Known kernel types

To tell jupyter.nix about your new kernel type, you need to add it to the
`kernelTypes` configuration option:

```nix
jupyter.lib.makeJupyterLab {
  # ...
  kernelTypes = {
    yourNewKernelType = ./path/to/your/kernel/type.nix;
  };
}
```

If you are contributing a new kernel type to jupyter.nix, add it
to the `kernelTypes` attrset in (`lib/default.nix`)[../lib/default.nix].

You can also distribute your kernel type separately, in any manner your like,
and users will be able to activate it by adding it to `kernelTypes` in their own
jupyter.nix configs.
