# Helper makefile to demonstrate the use of the rpi-emu docker environment
# This is mostly useful for development and extension as part of an image builder
# 
# For an example using this in a project, see Makefile.example

DIST=rosbots-ros-opencv-stretch-lite-2018-10-09
FILE=download?cid=6CB86F905DD427BC&resid=6CB86F905DD427BC%21583339&authkey=AO09FGWppqhx0JA
ZIP=$(FILE).zip
DIST_ZIP=$(DIST).zip
IMAGE=$(DIST).img

DL_PATH=https://onedrive.live.com/download?cid=6CB86F905DD427BC&resid=6CB86F905DD427BC%21583339&authkey=AO09FGWppqhx0JA
CWD=$(shell pwd)

# Docker arguments
# Interactive mode, remove container after running, privileged mode for loopback access
# Mount images to /usr/rpi/images to access image files from container
# Change working directory to /usr/rpi (which is loaded with the helper scripts)
RUN_ARGS=-it --rm --privileged=true -v $(CWD)/images:/usr/rpi/images -w /usr/rpi ryankurte/docker-rpi-emu
MOUNT_DIR=/media/rpi

# Build the docker image
build:
	@echo "Building base docker image"
	@docker build -t ryankurte/docker-rpi-emu .

# Bootstrap a RPI image into the images directory
bootstrap: images/$(IMAGE)

# Fetch the RPI image from the path above
images/$(IMAGE):
	@echo "Pulling Raspbian image"
	# @mkdir -O images/$(ZIP) --no-check-certificate images
	# wget $(DL_PATH) --header "Referer: https://onedrive.live.com/"
	@mkdir -p images
	wget -O images/$(DIST_ZIP) --no-check-certificate "$(DL_PATH)"
	@unzip -d images/ images/$(DIST_ZIP)
	@touch $@

# Expand the image by a specified size
# TODO: implement expand script to detect partition sizes
#expand: build bootstrap
#	dd if=/dev/zero bs=1M count=10240 >> images/$(IMAGE)
#	@docker run $(RUN_ARGS) ./expand.sh images/$(IMAGE) 10240

# Launch the docker image without running any of the utility scripts
run: build bootstrap
	@echo "Launching interactive docker session"
	@docker run $(RUN_ARGS) /bin/bash 

# Launch the docker image into an emulated session
run-emu: build bootstrap
	@echo "Launching interactive emulated session"
	@docker run $(RUN_ARGS) /bin/bash -c './run.sh images/$(IMAGE)'

test: build bootstrap
	@echo "Running test command"
	@docker run $(RUN_ARGS) /bin/bash -c './run.sh images/$(IMAGE) "uname -a"'
