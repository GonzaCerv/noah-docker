<p align="center">
  <a href="" rel="noopener">
 <img width=427px height=285px src="doc/docker.png" alt="Project logo"></a>
</p>

<h3 align="center">Noah Docker container</h3>

<div align="center">

[![Status](https://img.shields.io/badge/status-active-success.svg)]()
[![License](https://img.shields.io/badge/license-GPL-blue.svg)](/LICENSE)

</div>

---

##  Table of Contents

- [About](#about)
- [Prerequisites](#Prerequisites)
- [Usage](#usage)
- [TODO](#todo)
- [Authors](#authors)

## :page_facing_up: About <a name = "about"></a>

This repo stores the Docker container for Noah robot. This image is based on the [ROS melodic-robot](https://hub.docker.com/_/ros?tab=description) provided by OSRF. The image is able to run on ARMv7, ARMv8 and AMD64. This is perfect to build and test your project in your linux PC and then port it into an SBC such as Raspberry PI. 

## :hammer: Prerequisites

Docker needs to be installed

## 📝 Usage <a name="usage"></a>

In order to start the docker container, you must run the noah_dev.sh script. The script can run manually or it can automatically detect your intentions and run autonomously.  

- To run autonomous mode, you need to run the script withouth parameters. The script will detect check if there is an image created with the same characteristics as the Dockerfile. If there is an existing image of Docker, it will try to start that image. In the last case, if an image is created and its container is running, it will try to attach the terminal to that container.
```
  ./noah_dev.sh
```

- For building the container:
```
  ./noah_dev.sh -b
```

- For running the container:
```
  ./noah_dev.sh -r
```

- If you want to delete the container:
```
  ./noah_dev.sh -d
```

- If there is an image running and want to attach another shell to it:
```
  ./noah_dev.sh -a
```

- If you want to start from zero (build everything again) do this:
```
  ./noah_dev.sh -z
```

## 🎈 TODO <a name="todo"></a>

- Implement Support for Nvidia
- Test X11

## ✍️ Authors <a name = "authors"></a>

- [Gonzalo Cervetti](https://github.com/GonzaCerv) - Idea & Initial work


