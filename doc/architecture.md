<!--
SPDX-FileCopyrightText: 2026 Kirill Elagin <https://kir.elagin.me/>

SPDX-License-Identifier: MPL-2.0 or MIT
-->

# Architecture

jupyter.nix is built on top of the NixOS module system (`lib.evalModules`).
A user’s configuration is evaluated against a set of modules, and the result is
a single derivation: a Python environment with Jupyter Lab, the configured
kernels, and the required extensions.

## Directory layout

```
jupyter/
├── lib.nix                  Library entry point (exposed as `jupyter.lib`)
├── config/
│   └── module.nix           Top-level configuration module
├── kernel/
│   └── module.nix           The kernel “interface” (output contract)
├── kernelspec/
│   ├── module.nix           Options describing a raw Jupyter kernelspec
│   └── lib.nix              Helpers for building kernelspecs (`specKernel`, …)
├── kernel-types.nix         A registry of built-in kernel types
└── kernel-types/
    ├── ipykernel.nix        Built-in Python kernel type
    ├── ihaskell.nix         Built-in Haskell kernel type
    └── ijulia.nix           Built-in Julia kernel type
```

## The library entry point (`jupyter/lib.nix`)

`jupyter/lib.nix` is what gets exposed as `jupyter.lib`. It:

* defines the registry of built-in kernel types (`kernelspec`, `ipykernel`,
  `ihaskell`, `ijulia`);
* exposes `makeJupyterLab`, the main user-facing function;
* exposes helpers for kernel-type authors (`kernelspecKernel`,
  `buildKernelSpec`).

`makeJupyterLab config` simply evaluates the module tree against `config` and
returns the resulting output derivation (`config.outDrv`).

## The configuration module (`jupyter/config/module.nix`)

This is the top-level module and the most complex part of the codebase. It:

* declares the user-facing options (`pkgs`, `pythonInterpreter`, `kernels`,
  `jupyterExtensions`, `enableNativeKernel`, …);
* declares the `kernels` option, whose type is built dynamically from the
  registered `kernelTypes` (see below);
* assembles the final `outDrv` derivation: a `python.buildEnv` containing
  Jupyter Lab plus, for each kernel, a symlink into `share/jupyter/kernels/`,
  and a symlinked tree of Jupyter Lab extensions.

### How the `kernels` option type is built

Each kernel is configured as `kernels.<name>.<type>`. The type of the option is
generated from the `kernelTypes` registry using `lib.types.attrTag`: every
registered kernel type becomes a possible tag, and the value under that tag is a
submodule built from the kernel type’s module plus the common kernel interface
(`jupyter/kernel/module.nix`).

A consequence of using `attrTag` is that the kernel type’s `name` argument (the
last attribute name in the NixOS module sense) is the *kernel type*, not the
kernel name. The kernel name (the second-to-last attribute) is passed
separately as `kernelName`. See the [kernel authoring guide](./kernel-authoring.md)
for details.

## The kernel interface (`jupyter/kernel/module.nix`)

This module defines the *output contract* that every kernel type must satisfy:

* `outDir` – a directory containing the Jupyter kernel spec (`kernel.json`,
  logos, …);
* `jupyterEnvPackages` – Python packages to add to the Jupyter environment;
* `jupyterExtensions` – Jupyter Lab extension packages to install.

A kernel type is free to produce `outDir` however it likes. Most kernel types,
however, build it from a declarative spec — see below.

## The kernelspec subsystem (`jupyter/kernelspec/`)

* `module.nix` declares options mirroring the fields of a Jupyter kernel spec
  (`argv`, `display_name`, `language`, logos, …) and turns them into an `outDir`
  directory with a `kernel.json` and logo files.
* `lib.nix` provides `specKernel` (a module mixin that adds conveniences such as
  `extraPath` on top of the kernelspec module) and `buildKernelSpec`/`evalKernelSpec`
  helpers for building/testing a kernelspec directly.

The `kernelspecKernel` helper in `jupyter/lib.nix` wires a kernel type module
together with `specKernel`, so that a kernel type only needs to fill in the
`spec` option and `outDir` is produced automatically.

## Data flow, end to end

```
makeJupyterLab config
  └─ evalModules [ config/module.nix, { kernelTypes }, config ]
       ├─ kernels.<name>.<type>  ──▶  kernel type module (kernel-types/*.nix)
       │                                └─ produces `spec`  ──▶  specKernel
       │                                                          └─ outDir (kernel.json + logos)
       └─ config.outDrv  ──▶  python.buildEnv
                                ├─ jupyterlab + jupyterEnvPackages
                                ├─ symlink each kernel’s outDir into share/jupyter/kernels/
                                └─ symlink jupyterExtensions into share/jupyter/labextensions/
```
