# Docker image for Vistle

This image is based on Debian 13/Trixie, but Ubuntu 26.04 should also mostly work as base.

## Building
In order to build the container image, run `build/build.sh`.
Building always requires `docker`.
You can change the included features by providing non-empty values for some environment variables: 
just edit them at the top of `build/build.sh`.

## Running
Start `bin/vnc` and connect to `vnc://localhost:5900` with a VNC viewer.
The required password is `secret`. After pulling an image from `docker.io`,
this will launch an Xfce desktop. Vistle is installed to `/usr/local`,
and you can start it by entering `vistle` into the terminal emulator.
Some example workflows can be found in `/usr/local/share/vistle/example`.

Docker, Apptainer, Podman, and Orbstack have been used for execution.
If the wrong mechanism is auto-detected, you can override it by setting `RUNNER`.
Especially if you built the image locally using `docker`, you might want to do so,
in order to make sure that you use the locally built image.

The directory `data` from this directory is visible inside the container as `/data`.
You can use this to save your changes and exchange data.

### Docker on Windows

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


### Docker on Linux


### Docker on macOS
