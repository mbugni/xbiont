# Xbiont - The Linux Symbiont

This project is a framework to build Linux systems for personal computing.
You can build and [try the live image](https://virt-manager.org), then install it in 
your PC if you want.
You can also customize the image starting from generated recipes.

## The biological metaphor

The name "symbiont" is inspired by the biological concept of a symbiotic relationship, where two different organisms live together in close association, often benefiting each other. In this context, the symbiont represents a digital organism that lives in symbiosis with the Linux system, providing services and utilities to the system.

Like a cooperative digital organism, it assists during the entire [life cycle of the system](./docs/lifecycle.md), from building to installation and maintenance.

Main goals of the symbiont are:
* Building and installing the system through an image
* Keep the system homeostatic (balanced and stable)
* Facilitating interaction with humans
* Expanding the system usage (extra-repos, support for external devices)
* Survive and evolve

Xbiont [works as a digital organism](./docs/how-it-works.md) that has a nervous system to coordinate and configure actions and tools. When the symbiont receives a signal, it performs actions driven by variables and activates a sequence of small scripts.

## Supported distributions

The following table illustrates the supported distributions and their intended target:

| Distribution | Architecture | Target Epoch | Desktop         |
|--------------|--------------|--------------|-----------------|
| Debian 11    | i686, x86_64 | 2001-2010    | Trinity R14.1.x |
| Debian 12    | x86_64       | 2011-2020    | KDE Plasma 5.x  |
| Debian 13    | x86_64       | 2021-2025    | KDE Plasma 6.x  |
| CentOS 10    | x86_64 v3    | 2025-now     | KDE Plasma 6.x  |
| Fedora 43    | x86_64       | 2025-now     | KDE Plasma 6.x  |
| Fedora 44    | x86_64       | 2025-now     | KDE Plasma 6.x  |

## Basic components

The fundamental building blocks of the symbiont are:

* KDE-based desktop - for providing a graphical user interface
* systemd - for managing system interactions
* bash - for running the system scripts
* Kiwi NG - for building the system image
* Podman - for building in an isolated environment

## Licensing (SPDX-License-Identifier: GPL-3.0-or-later)
This is free software: you can redistribute it and/or modify it under the terms of
the GNU General Public License as published by the Free Software Foundation, under
version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program.
If not, see <http://www.gnu.org/licenses/>.
