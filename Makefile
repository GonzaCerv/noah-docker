# If you want to rebuild all images, set this to --no-cache from the commandline
DOCKER_ARGS?=
USERID=$(shell id -u)

# You need to specify a particular target
#--------------------------------------------------------------------------
# Stable and local targets

.PHONY: stretch_melodic
stretch_melodic:
	docker build ${DOCKER_ARGS} --build-arg uid=$(USERID) -t stretch_melodic stretch_melodic

