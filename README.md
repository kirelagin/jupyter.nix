<!--
SPDX-FileCopyrightText: 2026 Kirill Elagin <https://kir.elagin.me/>

SPDX-License-Identifier: MPL-2.0 or MIT
-->

jupter.nix
===========

_A Nix library for setting up Jupyter Lab_

This repository provides:

1. NixOS-style module definitions for configuring Jupyter.
2. Presets for getting it up and running in seconds.


## Use

### Running

Just Jupyter Lab with some basic Python packages available:

```shell
$ nix run github:kirelagin/jupyter.nix
```

### Adding to your project

Add it as an input to your flake:

```nix
# flake.nix

{
  inputs = {
    # ...

    jupyter = {
      url = "github:kirelagin/jupyter.nix";
      inputs.nixpkgs.follows = "nixpkgs";  # (optionally)
    };
  };

  outputs = { self, nixpkgs, jupyter }: {
    # All functions from jupyter.nix are available in `jupyter.lib`.
    # ...
  };
}
```

Then you can expose your Jupyter Lab environment as a runnable package:

```nix
# flake.nix
{
  # ...

  outputs = { self, nixpkgs, jupyter }:
    let
      # We keep it simple, but better to use `flake-utils` for systems
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      packages.${system} = {
        # ...
        jupyter = jupyter.lib.makeJupyterLab {
          inherit pkgs;
          kernels = {
            "Python" = jupyter.lib.kernels.python.makePythonKernel {
              inherit pkgs;
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


### Customisation

The centerpiece of the library is the `makeJupyterLab` function.
You need to pass `pkgs` to it, followed by the Jupyter-specific configuration:

```nix
{
  jupyter = jupyter.lib.makeJupyterLab {
    pkgs = nixpkgs.legacyPackages.${system}; # (mandatory) your Nixpkgs set
    pythonInterpreter = pkgs: pkgs.python3;  # (optional)
    kernels = {
      # see below
    };
  };
}
```

You will mostly be interested in the `kernels` option, however there are others
as well (see [`modules.nix`](./jupyter/lib/jupyter.nix/modules.nix) for the detailed documentation).

Each kernel definition is basically a nixified regular Jupyter kernelspec,
plus some extra options.
The library also provides helpers for defining kernels of popular types,
such as Python:

```nix
# kernels =
{
  "Python" = jupyter.lib.kernels.python.makePythonKernel {
    inherit pkgs;
    packages = pp: with pp; [
      # Add Python packages that you need
      # ...
    ];

    # There is nothing particularly special about Plotly or Matplotlib, however
    # they require care when installing, since packages need to be added both to
    # the kernel and to the Jupyter environment, so the helper function
    # can take care of that for simplicity.
    withPlotly = true;
    withMatplotlib = false;
  };
}
```

Instead of using helper functions, you could just define your own kernel from scratch.
The definition above is roughly equivalent to the following direct definition:

```nix
# kernels =
{
  "Python" =
    let
      kernelEnv = pkgs.python3.withPackages (pp: with pp; [
        # These are needed for Plotly
        anywidget
        nbconvert
        pandas
        plotly
        # Add Python packages that you need
        # ...
      ]);
    in {
      spec = {
        argv = [
          "${kernelEnv.interpreter}"
          "-m" "ipykernel_launcher"
          "-f" "{connection_file}"
        ];
        language = "python";
        # logos ...
      };
      jupyterEnvPackages = pp: with pp; [
        anywidget
        plotly
      ];
    };
}
```


## Limitations

* No way to provide global Jupyter configuration
* No support for Jupyter extensions
* Definition helper only for Python kernels
* ...

These are not inherent technical limitations, I have just implemented the bare minimum
that I, as a fairly unsophisticated Jupyter user, need.
Contributions are extremely welcome!


## Contributing

If you would like to see something added to the library, please create an issue
or, even better, send a pull request!

Please, note that in this repository we are making effort to track
the authorship information for all contributions.
In particular, we are following the [REUSE] practices.
The tl;dr is: please, add information about yourself to the headers of
each of the files that you edited if your change was _substantial_
(you get to judge what is substantial and what is not).

[REUSE]: https://reuse.software/

Also, do not forget to reflect the changes you make in `CHANGELOG.md`.


## License

[MPL-2.0] © [Kirill Elagin] and contributors (see headers in the files).

Additionally, all code in this repository is dual-licensed under the MIT license
for direct compatibility with nixpkgs.

[MPL-2.0]: https://spdx.org/licenses/MPL-2.0.html
[Kirill Elagin]: https://kir.elagin.me/
