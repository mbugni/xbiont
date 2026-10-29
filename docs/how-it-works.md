# How Xbiont Works

Xbiont is a Linux meta-distribution that is built using the kiwi-ng tool. It is designed to be a lightweight, secure, and reliable system for desktop computers.

## Architecture

Xbiont is a collection of tools and metadata that allow you to create custom Linux systems based on different [supported distributions](../README.md#supported-distributions). The [kiwi-ng](https://osinside.github.io/kiwi/) tool allows you to define the base image, the packages to be installed, and the configuration files to be included in the image. The image is built using [Podman](https://podman.io/) to create a live system.

Xbiont provides a set of pre-defined configurations and recipes included in the image that help to build a Linux system tailored to human needs.

Xbiont is designed to be a [symbiotic relationship](../README.md#the-biological-metaphor) between the system components and the user, where:
- The Linux distribution provides the foundation
- Xbiont acts as a nervous system that coordinates and configures the components
- The [DNA environment](./environment.md) provides the context for the symbiont to drive reactions

Variables can be set at build time or at runtime: in most cases are automatically detected from the system.

Main Xbiont components are:

- **Triggers**: Events that trigger the execution of specific actions or scripts.
- **Actionables**: Bash scripts that perform specific tasks to react to triggers.
- **Tools**: A collection of tools that provide the specific functionality for end users.

### Triggers

Triggers are usually system events that can be captured by systemd units (services, timers, etc.).
Sometimes triggers can be fired by hooks provided by desktop environment or other system components.
Triggers are injected into the system during the [build process](./lifecycle.md).

### Actionables

Actionables are bash scripts that perform specific tasks to react to triggers. They can be executed through the `xbiont <service> <request>` command. They are organized in a hierarchical structure that follows the naming convention service/request under the [`/usr/libexec/xbiont/command`](../root/usr/libexec/xbiont/command) directory.
Like systemd unit templates, actionables are named using a pattern `<action>@<condition>.sh`, where `action` is the *what* part of the request and `condition` is the *when* or *condition* part of the request. The condition is evaluated dinamically during the execution. By default, an `action@run.sh` is the entry point script for the execution.
Common `functions.sh` and `variables.sh` can be sourced in the [`module`] folder for each actionable.
Top level actionables typically define common environment variables and functions that are used by subsequent actionables.
Variables provided by actionables are prefixed with `X_` and represent the DNA of the symbiont. The `X` convention is used to mimic the double helix of DNA.
Actionables can add variables to communicate with each other and to react to triggers. 

### Tools

Tools provide the specific functionality for end users. They are composed of an interactive interface (CLI or GUI) and a set of backend scripts that perform the actual work.
They are organized in a hierarchical structure that follow the naming convention tool/action under the [`/usr/libexec/xbiont/tool`](../root/usr/libexec/xbiont/tool) directory.
Like actionables, tools can source common `functions.sh` and `variables.sh` from the [`module`] folder for each tool.

## Implementation

Xbiont is implemented mostly as systemd units and `bash` scripts. It guarantees a consistent and portable behavior across different distributions.
Scripts are small and readable, they use standard system commands provided by the initial lifecycle phase.
