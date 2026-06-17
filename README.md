# Docker image for Vistle

This image is based on Debian 13/Trixie, but Ubuntu 26.04 should also mostly work as base.

## Building
In order to build the container image, run `build/build.sh`.
Building always requires `docker`.
You can change the included features by providing non-empty values for some environment variables: 
just edit them at the top of `build/build.sh`.

## Running
Start `bin/vnc` and connect to `vnc://localhost:5900` with a VNC viewer.
The required password is `secret`.

Docker, Apptainer, Podman, and Orbstack have been used for execution.
If the wrong mechanism is auto-detected, you can override it by setting `RUNNER`.

The directory `data` from this directory is visible inside the container as `/data`.
You can use this to save your changes and exchange data.
