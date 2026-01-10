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

### Customisation

TBD


## Contributing

TBD

Please, note that in this repository we are making effort to track
the authorship information for all contributions.
In particular, we are following the [REUSE] practices.
The tl;dr is: please, add information about yourself to the headers of
each of the files that you edited if your change was _substantial_
(you get to judge what is substantial and what is not).

[REUSE]: https://reuse.software/


## License

[MPL-2.0] © [Kirill Elagin] and contributors (see headers in the files).

Additionally, all code in this repository is dual-licensed under the MIT license
for direct compatibility with nixpkgs.

[MPL-2.0]: https://spdx.org/licenses/MPL-2.0.html
[Kirill Elagin]: https://kir.elagin.me/
