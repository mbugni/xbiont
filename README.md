# Xbiont - The Linux Symbiont

This project is a framework to build Linux systems for personal computing.
You can build and [try the live image](https://virt-manager.org), then install it in 
your PC if you want.
You can also customize the image starting from generated recipes.

## Why the symbiont?

A symbiont is a living being that lives in symbiosis with another living being.
In this case, the symbiont lives in symbiosis with the Linux system.
Like a cooperative digital organism, it provides services and utilities to the system.

Main goals of the symbiont are:
* Building and installing the system through an image
* Keep the system homeostatic (balanced and stable)
* Facilitating interaction with humans
* Expanding the system usage (extra-repos, support for external devices)
* Survive and evolve

## How it works

The symbiont is built using [Kiwi NG](https://osinside.github.io/kiwi/) and 
[Podman](https://podman.io/).
It assists during the entire life cycle of the system, from building to installation and maintenance.
It is configured using environment variables, that act like a DNA.
Variables can be set at build time or at runtime: in most cases are automatically detected from the system.
When the symbiont receives a signal, it performs actions driven by the DNA and activates a sequence of small scripts.
The symbiont uses systemd, bash and basic shell commands to perform its tasks.

See the [lifecycle documentation](./docs/lifecycle.md) for more details.

For each lifecycle stage, the symbiont provides a specific set of profiles and features.
The stage can be customized by setting the [environment variables](./docs/environment.md).

## Supported distributions

The following table illustrates the supported distributions and their intended target:

| Distribution | Architecture | Target Epoch | Desktop         |
|--------------|--------------|--------------|-----------------|
| Debian 11    | i686, x86_64 | 2001-2010    | Trinity R14.1.x |
| Debian 12    | x86_64       | 2011-2020    | KDE Plasma 5.x  |
| CentOS 10    | x86_64 v3    | 2021-now     | KDE Plasma 6.x  |
| Fedora 43    | x86_64       | 2021-now     | KDE Plasma 6.x  |

The fundamental building blocks of the symbiont are:

* KDE-based desktop - for providing a graphical user interface
* systemd - for managing system interactions
* bash - for running the system scripts
* Kiwi NG - for building the system image
* Podman - for building in an isolated environment

## Licensing (SPDX-License-Identifier: GPL-2.0-or-later)
This program is free software; you can redistribute it and/or modify it under the terms of
the GNU General Public License version 2 as published by the Free Software Foundation, or
(at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program.
If not, see <http://www.gnu.org/licenses/>.
