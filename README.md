# SMARTS Docker wrapper

This repository builds a Docker image for the licensed Linux SMARTS 2.9.5 distribution and provides a small wrapper script you can use in place of `smarts295bat`.

The repository does **not** download SMARTS for you during `docker build`.

You must obtain the SMARTS archive yourself from National Laboratory of the Rockies after registering and agreeing to their license terms:

- https://www.nlr.gov/grid/solar-resource/smarts

## Get the SMARTS tarball

Before building the image, download the Linux SMARTS archive from the SMARTS page above.

Accepted input filenames are:

- `smarts-295-linux-tar`
- `smarts-295-linux-tar.gz`

`docker_build.sh` uses the tarball in this order:

1. `vendor/smarts-295-linux-tar`, if it already exists
2. the optional command-line argument you pass to `docker_build.sh`
3. a file in the current working directory named `smarts-295-linux-tar`
4. a file in the current working directory named `smarts-295-linux-tar.gz`

If the source file is `smarts-295-linux-tar.gz`, the build script expands it into:

- `vendor/smarts-295-linux-tar`

## Build the Docker image

Build using a tarball already staged in `vendor/`:

```bash
./docker_build.sh
```

Build by pointing directly at a downloaded archive:

```bash
./docker_build.sh /path/to/smarts-295-linux-tar.gz
```

Build by placing `smarts-295-linux-tar` or `smarts-295-linux-tar.gz` in your current working directory, then running:

```bash
./docker_build.sh
```

Optional environment variables:

- `IMAGE_NAME` controls the Docker image tag
- `PLATFORM` controls the Docker build platform

Example:

```bash
IMAGE_NAME=smarts295:local ./docker_build.sh
```

## Use the image as a replacement for `smarts295bat`

After the image is built, run `docker_run.sh` instead of running `smarts295bat` directly.

Native SMARTS usage:

```bash
smarts295bat INPUT.DAT
```

Docker wrapper usage:

```bash
./docker_run.sh INPUT.DAT
```

The wrapper:

- starts the container from the built image
- mounts your current working directory at `/work` inside the container
- runs SMARTS from `/opt/SMARTS_295_Linux`
- passes its arguments through to `smarts295bat`

If the first argument is:

- a relative path, it is rewritten as a path under `/work`
- an absolute path inside your current working directory, it is also rewritten under `/work`

Examples:

```bash
./docker_run.sh INPUT.DAT
./docker_run.sh ./INPUT.DAT
./docker_run.sh "$PWD/INPUT.DAT"
```

## Notes

- You must download SMARTS yourself after agreeing to the license terms on the SMARTS site.
- The Docker build expects a local SMARTS tarball and will not fetch it from the network.
- `docker_run.sh` only remaps the first argument as a mounted file path, so the simplest workflow is to run it from the directory containing your SMARTS input file.
