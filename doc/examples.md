<!--
SPDX-FileCopyrightText: 2026 Kirill Elagin <https://kir.elagin.me/>

SPDX-License-Identifier: MPL-2.0 or MIT
-->

# Examples

All examples below show the value of the `kernels` option passed to
`makeJupyterLab`. See [`quickstart.md`](./quickstart.md) for the surrounding
flake boilerplate.

## Python kernel (`ipykernel`)

A standard Python kernel. Add the Python packages you need with `packages`.

```nix
kernels = {
  "python".ipykernel = {
    packages = pp: with pp; [
      numpy
      polars
      requests
      scipy
    ];

    # There is nothing particularly special about Plotly or Matplotlib, but
    # they require packages to be added both to the kernel *and* to the Jupyter
    # environment, so these helpers take care of that for you.
    withPlotly = true;
    withMatplotlib = false;
  };
};
```

## Haskell kernel (`ihaskell`)

A standard Haskell kernel based on IHaskell.

```nix
kernels = {
  "Haskell".ihaskell = {
    packages = hp: with hp; [
      aeson
      ihaskell-aeson
    ];

    # (optional) Pick a specific Haskell package set.
    haskellPackageSet = pkgs: pkgs.haskellPackages;

    # (optional) RTS options passed to the kernel executable.
    rtsOptions = [ "-M3g" "-N2" ];
  };
};
```

## Julia kernel (`ijulia`)

A standard Julia kernel based on IJulia.

```nix
kernels = {
  "Julia".ijulia = {
    packages = [
      "CSV"
      "DataFrames"
      "Distributions"
    ];
  };
};
```

You can also use an existing Julia project with `Project.toml` and
`Manifest.toml` by providing its directory:

```nix
kernels = {
  "Julia project".ijulia = {
    project = "@.";
  };
};
```

## Raw Jupyter kernel spec (`kernelspec`)

Provide a [Jupyter kernel spec][jupyter:kernelspec] directly in Nix. The
`ipykernel` example above is roughly equivalent to the following:

```nix
kernels = {
  "python".kernelspec =
    let
      kernelEnv = pkgs.python3.withPackages (pp: with pp; [
        ipykernel
        # These are needed for Plotly:
        anywidget
        nbconvert
        pandas
        plotly
        # Add the Python packages that you need:
        # ...
      ]);
    in {
      spec = {
        argv = [
          "${kernelEnv.interpreter}"
          "-m" "ipykernel_launcher"
          "-f" "{connection_file}"
        ];
        display_name = "Python 3 (python)";
        language = "python";
        # logo_svg = ...; logo_64 = ...; logo_32 = ...;
      };

      # Plotly needs its extensions installed in the Jupyter server too:
      jupyterExtensions = with pkgs.python3.pkgs; [
        anywidget
        plotly
      ];
    };
};
```

[jupyter:kernelspec]: https://jupyter-client.readthedocs.io/en/stable/kernels.html#kernel-specs

## A custom directory-based kernel type (`custom-dir-kernel`)

If you already have a kernelspec directory (or want to build one yourself), you
can define a kernel type that assigns `outDir` directly, bypassing the `spec`
machinery. First register the kernel type, then use it:

```nix
jupyter.lib.makeJupyterLab {
  inherit pkgs;

  kernelTypes = {
    dir-kernel = {
      # `buildKernelSpec` is a convenience that builds a kernelspec directory
      # from a raw spec; you could also point `outDir` at any directory.
      config.outDir = jupyter.lib.buildKernelSpec pkgs "dir-kernel" {
        argv = [ "echo" "hello" ];
        display_name = "kernelspec test";
        language = "none";
      };
    };
  };

  kernels = {
    "custom-dir-kernel".dir-kernel = { };
  };
}
```

This pattern (taken from the flake's `checks`) is the simplest way to wrap an
externally-provided kernelspec directory. See the
[kernel authoring guide](./kernel-authoring.md) for more on building reusable
kernel types.
