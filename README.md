# IDE for Microcontroller Development

A comprehensive set of tools for developing applications for microcontrollers with special emphasis for [MicroPython](https://micropython.org/).

## Setup and configuration

Running this project is as simple as deploying it to a balenaCloud application. You can do it in just one click by pressing the button below:

[![deploy button](https://balena.io/deploy.svg)](https://dashboard.balena-cloud.com/deploy?repoUrl=https://github.com/iot49/ide49&defaultDeviceType=raspberrypi4-64)

## Documentation

[iot49 - Electronics for IoT](https://iot49.org)

## Build

To build a new release, open the `Balena Command Line Tools` container and run the following code:

```bash
cd ~/ide49
balena push <FLEET>
```

Substitute `<FLEET>` with the name of your fleet (app) on the balena cloud. E.g. `ide49` or `ide49-amd64`.