<!--
SPDX-FileCopyrightText: 2026 Kirill Elagin <https://kir.elagin.me/>

SPDX-License-Identifier: MPL-2.0 or MIT
-->

# Quickstart

## Just run it

To launch Jupyter Lab with a basic Python kernel without installing anything:

```shell
$ nix run github:kirelagin/jupyter.nix
```

## Customise and run it

Start by creating a new directory and run in it:

```shell
$ nix flake init -t github:kirelagin/jupyter.nix
```


This creates `flake.nix`, edit it in your favourite editor to configure the
Jupyter kernels that you need and then run your brand-new Jupyter flake:

```shell
$ nix run
```

## Add it to your project

Add jupyter.nix as an input to your flake:

```nix
# flake.nix
{
  inputs = {
    # ...
    jupyter = {
      url = "github:kirelagin/jupyter.nix";
      inputs.nixpkgs.follows = "nixpkgs";  # (optional, but recommended)
    };
  };

  outputs = { self, nixpkgs, jupyter }: {
    # All functions from jupyter.nix are available in `jupyter.lib`.
    # ...
  };
}
```

Then expose your Jupyter Lab environment as a runnable package:

```nix
# flake.nix
{
  # inputs = ...

  outputs = { self, nixpkgs, jupyter }:
    let
      # We keep it simple here, but it is better to use `flake-utils` for systems.
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      packages.${system} = {
        # ...
        jupyter = jupyter.lib.makeJupyterLab {
          inherit pkgs;
          kernels = {
            "python".ipykernel = {
              packages = pp: with pp; [
                numpy
                polars
              ];
              withPlotly = true;
            };
          };
        };
      };
    };
}
```

And run it:

```shell
$ nix run .#jupyter
```

## The `makeJupyterLab` function

`makeJupyterLab` is the centerpiece of the library. It takes a single attribute
set with the jupyter.nix configuration and returns a runnable Jupyter Lab
package.

```nix
jupyter.lib.makeJupyterLab {
  # (mandatory) Your Nixpkgs set; used for trivial builders and as the
  # default source of all packages.
  pkgs = nixpkgs.legacyPackages.${system};

  # (optional) Selector for the Python interpreter used to run Jupyter
  # itself and everything in its environment. Defaults to `python3`.
  pythonInterpreter = pkgs: pkgs.python3;

  # (optional) Selector for extra Python packages installed alongside
  # Jupyter into the environment used to run it (not into a kernel!).
  jupyterEnvPackages = pp: with pp; [ ];

  # (optional) Extra Jupyter Lab extension packages to install into the
  # server. Most kernels that need extensions will add them automatically.
  jupyterExtensions = [ ];

  # (optional) Whether to add the “native” kernel, i.e. the Python
  # interpreter used to run Jupyter itself, as a usable kernel.
  # Defaults to `false` (note: upstream Jupyter defaults to `true`).
  enableNativeKernel = false;

  # (optional) Register additional kernel *types*. See the kernel
  # authoring guide for details.
  kernelTypes = { };

  # The kernels to make available. See below and `examples.md`.
  kernels = {
    # ...
  };
}
```

## Defining kernels

Kernel definitions have the following general shape, where the first attribute
level is the *kernel name* (how it appears in Jupyter) and the second is the
*kernel type* (which implementation to use):

```nix
{
  kernels = {
    "<kernel name>"."<kernel type>" = {
      # kernel-type-specific options
    };
  };
}
```

The built-in kernel types are:

* `ipykernel` – standard Python kernel
* `ihaskell` – standard Haskell kernel
* `ijulia` – standard Julia kernel
* `kernelspec` – a raw [Jupyter kernel spec][jupyter:kernelspec] written in Nix

See [`examples.md`](./examples.md) for concrete configurations of each, and the
[kernel authoring guide](./kernel-authoring.md) for how to create your own
kernel type.

[jupyter:kernelspec]: https://jupyter-client.readthedocs.io/en/stable/kernels.html#kernel-specs
