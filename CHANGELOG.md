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

* Add basic support for Jupyter extensions (`jupyterExtensions`
  top-level configuration option and kernel config output option).
* Make the IHaskell kernell install its extension for syntax highlighting.

### Changed

* For ipykernel, when `enablePlotly = true`, do not install `anywidget` and
  `plotly` Python packages into the Jupyter env, just install the extensions.
* Force read-only extension manager in the webui.


## [1.0.0]

First release.


[Unreleased]: https://github.com/kirelagin/jupyter.nix/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/kirelagin/jupyter.nix/releases/tag/v1.0.0
