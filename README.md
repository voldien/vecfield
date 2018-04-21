# VecField #
----
[![Travis Build Status](https://travis-ci.org/voldien/vecfield.svg?branch=master)](https://travis-ci.org/voldien/vecfield)

Simple dedicated vector-field particle simulation program that is written in *objective-c* with the *gnustep*. It uses OpenGL for rendering and OpenCL for computing the particle displacement.
The program is not design as a research simulation program. But rather as a visualization program. However, the equations used for solving the particle displacement are based on the physical laws and formulas. Thus, it could be modified in the OpenCL code as such to mimic real particles.

## Features ##
* Random VectorField - *Perlin Noise* is for creating random vector fields.
* Small Particle size - Each particle takes 16 bytes ( 8 for position and 8 for velocity).
* Command line options - The settings of the program can be overridden with option arguments.

# Motivation #
The main motivation of this project is to create a visualization program for particles in a vector-field in R^2. Where the particles
can be influenced by the mouse/pointer motion.

# Examples #
The program can executed by simply as followed:
```
./vecfield
```

# Installation # 
The program can be easily be installed by using the following command:
```
cmake .
make
make install
```
This will compile the program and create the dependencies resources and install the program onto the system.

# Dependencies #
In order to compile the program, the following Debian packages are required.
```
apt-get install ocl-icd-opencl-dev libsdl2-dev gnustep-devel libzip-dev mesa-common-dev opencl-headers
```
The rest of the library dependencies are the OpenCL and OpenGL library provided by the graphic driver.

# License #
This project is licensed under the GPL+3 License - see the [LICENSE](LICENSE) file for details.

