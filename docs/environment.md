# Environment variables

Environment variables are used to configure the symbiont at build time or at runtime.
They act like a DNA, defining the behavior of the symbiont.

## Build time variables

These variables are optional and have default values.
They are used to configure the symbiont image during the build process.

| Command          | Variable          | Default            | Description            |
|------------------|-------------------|--------------------|------------------------|
| `image template` | `X_DISTRO_ID`     | from `/etc/os-release` | Distribution to build for |
| `image template` | `X_DISTRO_VERSION`| from `/etc/os-release` | Distribution version to build for |
| `image template` | `X_IMAGE_PLATFORM`| i686 or x86_64     | CPU architecture (see below) |
| `image build`    | `X_SEAT_PLATFORM` | `Workstation`      | Seat platform to build for (see below) |
| `image build`    | `X_SEAT_LOCALE`   | `en_US`            | Seat locale to build for (see below) |

### Supported distributions and architectures

| Distribution | X_DISTRO_ID | X_DISTRO_VERSION | X_IMAGE_PLATFORM |
|--------------|-------------|------------------|------------------|
| Debian       | debian      | 11, 12           | i686, x86_64     |
| CentOS       | centos      | 10               | x86_64           |
| Fedora       | fedora      | 43               | x86_64           |

### Supported seat platforms

| Platform      | Description                            |
|---------------|----------------------------------------|
| `Console`     | Command line only, mainly for testing  |
| `Desktop`     | Minimal desktop environment with basic tools |
| `Workstation` | Desktop environment with more features like printing and scanning support |

### Supported seat locales

| Locale  | Keyboard/Model | Timezone         | Description             |
|---------|----------------|------------------|-------------------------|
| `en_US` | us/pc104       | America/New_York | English (United States) |
| `it_IT` | it/pc105       | Europe/Rome      | Italian (Italy)         |

## Runtime variables

These variables are used to configure the symbiont at runtime, most of them are automatically detected from the system and cannot be overridden.
