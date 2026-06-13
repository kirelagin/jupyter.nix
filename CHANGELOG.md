<!--
SPDX-FileCopyrightText: 2026 Kirill Elagin <https://kir.elagin.me/>

SPDX-License-Identifier: MPL-2.0 or MIT
-->

# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

* Add high-level support for Julia kernels (`ijulia` kernel type).
* Add `project` option to the `ijulia` kernel type to support Julia projects
  (use `"@."` for automatic root detection).
* Add support for Real-Time Collaboration (`jupyter-collaboration`).
  (Set `collaboration.enable = true`.)
* Add `settings` for providing arbitrary `jupyter_config.json` settings.

### Changed

* Rename `jupyterExtensions` -> `labextensions`.


## [2.0.0]

### Added

* Add basic support for Jupyter extensions (`jupyterExtensions`
  top-level configuration option and kernel config output option).
* Make the IHaskell kernel install its extension for syntax highlighting.
* Add `extraPath` module for adding directories to the PATH available in the kernel.
* Add `kernel.js` symlinking to kernelspec.
* Add `jupyter-ihaskell` to flake output packages to make it easier for users
  to directly run a basic IHaskell notebook.
* Add a flake template for easier quick start.

### Changed

* For ipykernel, when `enablePlotly = true`, do not install `anywidget` and
  `plotly` Python packages into the Jupyter env, just install the extensions.
* Force read-only extension manager in the webui.
* Add `jupyterLib.kernelspecKernel` helper for defining new kernel types that
  are built from a spec, so there is no need to call `buildKernelSpec` and
  assigning to `outDir` manually.
* Reorganise documentation: the `README.md` is now a concise overview, with
  detailed guides moved into the `doc/` directory (quickstart, examples,
  architecture, kernel authoring). Add a top-level `CONTRIBUTING.md`.
* Do not install the `jupyterlab-pygments` extension.
* Only install the `jupyterlab-widgets` extension when `ipykernel` is used
  and `withPlotly = true`.

### Fixed

* Account for `targetPrefix` in the IHaskell package datadir path.


## [1.0.0]

First release.


[Unreleased]: https://github.com/kirelagin/jupyter.nix/compare/v2.0.0...HEAD
[2.0.0]: https://github.com/kirelagin/jupyter.nix/compare/v1.0.0...v2.0.0
[1.0.0]: https://github.com/kirelagin/jupyter.nix/releases/tag/v1.0.0
