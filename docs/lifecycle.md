# The symbiont lifecycle

## Install the symbiont
Clone the project into your `<source-path>` to get sources:

```shell
git clone https://gitlab.com/mbugni/xbiont.git /<source-path>
```

Create an accessible link to the main program like:

```shell
ln -s /<source-path>/root/usr/bin/xbiont ~/bin/xbiont
```

## Build the image (creating the digital life)

### 1. Generate the image template (genetic instructions)

```shell
xbiont image template
```

It creates a folder named `template` in the current directory.
If you don't specify any distribution, it will use the current one (if supported).
To prepare an image for a specific distribution, setup the environment variables:

```shell
xbiont image template X_DISTRO_ID=fedora X_DISTRO_VERSION=43
```

See the [README](../README.md) documentation for more information about supported distributions.

### 2. Build the container (prebiotic soup)

To create a reusable container for building the image run:

```shell
xbiont image container
```

It creates a local container like `localhost/xbiont/<distro>-<version>` using the instructions from the `template` folder generated in the previous step.
To see created containers:

```shell
sudo podman images
```

### 3. Build the image (digital organism genesis)

To build the system image run:

```shell
xbiont image build
```

It uses the container built in the previous step to create the image using configuration files from the `template` folder.
The root (system files) will be created in the `build` folder, while the `.iso` image will be created in the current folder.

You can specify the interaction platform and locale to build for:

```shell
xbiont image build X_SEAT_PLATFORM=Workstation X_SEAT_LOCALE=en_US
```

See the [environment variables](./environment.md) documentation for more information about supported platforms and locales.

## Use the image (spreading the digital life)
You can use a tool like [Ventoy](https://www.ventoy.net/) to build multiboot USB devices, or simply transfer the image to a single USB stick using the `dd` command:

```shell
sudo dd if=/<target-path>/xbiont-<distro>-<version>.iso of=/dev/<stick-device>
```

You can also use virtualization software like [Virt-Manager](https://virt-manager.org) or [QEMU](https://www.qemu.org/) to run the image directly.
