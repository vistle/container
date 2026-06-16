# Docker image for Vistle

This image is based on Debian 13/Trixie, but Ubuntu 26.04 should also mostly work as base.

## Building
Run `build/build.sh`, change included features by providing non-empty values for some environment variables, requires docker.

## Running
Start `bin/vnc` and connect to `vnc://localhost:5900` with a VNC viewer.
Docker, Apptainer, Podman, and Orbstack have been used for execution.
