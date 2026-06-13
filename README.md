<!--
SPDX-FileCopyrightText: 2026 Kirill Elagin <https://kir.elagin.me/>

SPDX-License-Identifier: MPL-2.0 or MIT
-->

jupyter.nix
============

_A Nix library for setting up Jupyter Lab._

This repository provides:

1. NixOS-style module definitions for configuring Jupyter.
2. Presets for getting it up and running in seconds.


## Quick start

Just run Jupyter Lab with some basic Python packages available:

```shell
$ nix run github:kirelagin/jupyter.nix
```

This will give you a basic Jupyter Lab instance with the Python kernel.

If you would like to add other kernels, customise the Python kernel (e.g.
add more Python packages to it) or adjust the configuration of Jupyter Lab
itself, create your own Jupyter-flake in an empty directory:

```shell
$ nix flake init -t github:kirelagin/jupyter.nix
```

then edit `flake.nix` and start your Jupyter Lab:

```shell
nix run
```

See the [documentation](#documentation) below for the full story.


## Documentation

* [Quickstart](./doc/quickstart.md) – installing, configuring, and the
  `makeJupyterLab` options.
* [Examples](./doc/examples.md) – ready-to-use configurations for every built-in
  kernel type.
* [Architecture](./doc/architecture.md) – how the library is structured and how
  a configuration becomes a Jupyter Lab environment.
* [Kernel authoring](./doc/kernel-authoring.md) – how to write your own kernel
  type.

The built-in kernel types are `ipykernel` (Python), `ihaskell` (Haskell),
`ijulia` (Julia), and `kernelspec` (a raw Jupyter kernel spec written in Nix).


## Limitations

* Only a fixed subset of global Jupyter configuration is exposed.
* High-level helpers only for Python, Haskell, and Julia kernels (could be more!).
* ...

These are not inherent technical limitations, just the bare minimum that I, as a
fairly unsophisticated Jupyter user, need. Contributions are extremely welcome!


## Contributing

If you would like to see something added to the library, please create an issue
or, even better, send a pull request! See [`CONTRIBUTING.md`](./CONTRIBUTING.md)
for the repository layout, where the documentation lives, and our authorship
(REUSE) conventions.


## License

[MPL-2.0] © [Kirill Elagin] and contributors (see headers in the files).

Additionally, all code in this repository is dual-licensed under the MIT license
for direct compatibility with nixpkgs.

[MPL-2.0]: https://spdx.org/licenses/MPL-2.0.html
[Kirill Elagin]: https://kir.elagin.me/
