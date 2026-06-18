# Docker image for Vistle

This image provides a containerized environment for running Vistle, a tool for visualizing scientific data.
It includes a pre-configured desktop environment and all necessary dependencies, so you can start using Vistle by connecting to the container with a VNC viewer.

For the following steps, you should clone this repository inside a Linux/Unix environment.
On Linux and macOS you can do this immediately, but on Windows you should first follow the steps below in order to get into WSL.

## Executing
This repository includes scripts for using the software in the container.
From the root of the checkout of this repository, you will find them in the directory `bin`.
You will need to execute them from a Linux/Unix environment, so on Windows you should first follow the steps below in order to get into WSL.

The most important way to work with the container is to  start a  desktop environment inside the container and connect to it with a VNC viewer.

Start `bin/vnc` and connect to `vnc://localhost:5900` with a VNC viewer.
The required password is `secret`. After pulling an image from `docker.io`,
this will launch an Xfce desktop. Vistle is installed to `/usr/local`,
and you can start it by entering `vistle` into the terminal emulator.
Some example workflows can be found in `/usr/local/share/vistle/example`.

Docker, Apptainer, Podman, and Orbstack have been used for execution.
If the wrong mechanism is auto-detected, you can override it by setting `RUNNER`.
Especially if you built the image locally using `docker`, you might want to do so,
in order to make sure that you use the locally built image.


## Working with the container

Connecting your VNC viewer to the container will bring up a Xfce desktop environment.
Open a terminal emulator and type `vistle` to start the software.
It is installed to `/usr/local`, and you can find some example workflows in `/usr/local/share/vistle/example`.

You can also start it from the *Applications* menu from the *Science* category.

The included Firefox browser can be used to access the documentation on [vistle.io](https://vistle.io) and is set up to open `vistle://` links in the documentation with the installed Vistle software.

The directory `data` from this directory is visible inside the container as `/data`.
You can use this to save your changes and exchange data.


## Prepare your system for using the container

The prequisites for using the container are:
- the ability to run Linux containers on your system, e.g., by using Docker, Podman, or Orbstack
- a VNC viewer for connecting to the container, e.g., TigerVNC or the built-in VNC viewer on macOS
Please follow the section for your operating system, if your system does not yet provide the required components.

### Windows - WSL, Docker Desktop and TigerVNC

To use the container on Windows, please follow the following steps:
1. Start *Windows Powershell* as administrator (by searching for *Windows Powershell* in the search bar, right-clicking on it and then selecting “Run as administrator”).
2.	Inside the shell, install *WSL* by typing the following command: `wsl -–install` and then hitting the Enter button.
3.	Install *docker* with the command: `winget install Docker.DockerDesktop` (if the package cannot be found, search for the correct name for your system with `winget search docker`).
4.	As we will need a VNC viewer later on, install *TigerVNC* with: `winget install TigerVNC.TigerVNC`
5.	Restart your computer.
6.	Open the *Docker Desktop* application and once it started up, go to the settings (the gear wheel symbol at the top). There navigate to “Resources”, then “WSL integration” and finally make sure that “Enable integrations with my default WSL distro” is enabled.
7.	Start the *WSL* application, this will open a terminal and prompt you to create an account the first time you use it. Please create one with the username and password of your choice.
8.	Once you have logged in, navigate to a folder of your choice, e.g., to the home directory with the following command: `cd ~`. Note that you can use the command `mkdir` to create new folders.
9.	Now clone this repository with the command: `git clone https://github.com/vistle/container.git`
10.	This should have create a folder called *container* in your working directory. Navigate to it with the command: `cd container` 
11. Run the following command to start the VNC session: `sudo ./bin/vnc`
12.	Now, still on your local machine, start the *TigerVNC* application. As VNC server, enter the following into the window that just appeared: `localhost:5900`
13. Cick on “Connect” and enter the password `secret`.
14.	Inside the window that just opened, open a terminal and type in the command `vistle`. 

You're now all set to use Vistle!


### Linux - Docker and TigerVNC

On Debian/Ubuntu do the following, to install the Docker runtime and CLI:
```sh
apt install docker.io docker-cli
```
You also need a VNC viewer for connecting to the container, for example `tigervnc-viewer`:
```sh
apt install tigervnc-viewer
```
After starting the container with `bin/vnc`, you can connect to it by running
```sh
vncviewer localhost:5900
```

### macOS - Docker Desktop

We assume that you use [Homebrew](brew.sh) to install the required components and that this is already set up on your computer.

Docker containers are based on Linux and thus require a virtual machine for execution.
While there are many possibilities for doing so, we suggest to use [Docker Desktop](https://docs.docker.com/desktop/setup/install/mac-install/).
You can do so by running
```sh
brew install docker-desktop
```
This should install a _Docker runtime_ and the _Docker CLI_ as `docker`.
This should be sufficient to run the included scripts.
You can use the VNC client included in macOS to connect to the container:
after spinning up the container with `bin/vnc`, open the Finder, select "Go" -> "Connect to Server..." and enter `vnc://localhost:5900` as the server address.


## Building the image
The docker image built from this repository is based on Debian 13/Trixie, but Ubuntu 26.04 should also mostly work as base.

In order to build the container image, run `build/build.sh`.
Building  with this script always requires `docker`.
You can change the included features by providing non-empty values for some environment variables: 
just edit them at the top of `build/build.sh`.
