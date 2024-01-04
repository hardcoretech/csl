ECR_WEST_DOMAIN = 478041131377.dkr.ecr.us-west-2.amazonaws.com
IMAGE_NAME = gofreight/csl
NAMESPACE_POSTFIX = csl
RELEASE_NAME_POSTFIX = csl
CHART_PATH = deployment/kubernetes/charts/csl
GITHUB_REPO_OWNER = "hardcoretech"
GITHUB_REPO_NAME = csl

.PHONY: test

help:		# Show the help menu
	@printf "Usage: make [OPTION]\n"
	@printf "\n"
	@perl -nle 'print $$& if m{^[\w-]+:.*?#.*$$}' $(MAKEFILE_LIST) | \
        awk 'BEGIN {FS = ":.*?#"} {printf "    %-18s %s\n", $$1, $$2}'

build-docker-image:	# Build the docker image
	docker build -t $(IMAGE_NAME)-api:$${IMAGE_TAG:-latest} --platform linux/amd64 .
	docker build -t $(IMAGE_NAME)-data-import:$${IMAGE_TAG:-latest} --platform linux/amd64 .

push-docker-image:	# Push the docker image to ECR
	docker tag "$(IMAGE_NAME)-api:$${IMAGE_TAG}" "$(ECR_WEST_DOMAIN)/$(IMAGE_NAME):$${IMAGE_TAG}"
	docker push "$(ECR_WEST_DOMAIN)/$(IMAGE_NAME)-api:$${IMAGE_TAG}"
	docker tag "$(IMAGE_NAME)-data-import:$${IMAGE_TAG}" "$(ECR_WEST_DOMAIN)/$(IMAGE_NAME):$${IMAGE_TAG}"
	docker push "$(ECR_WEST_DOMAIN)/$(IMAGE_NAME)-data-import:$${IMAGE_TAG}"

test:	# Run any type of tests you want
	@echo "No tests yet"

tear-down:	# Prune the docker resources and deprecated images
	docker system prune -f --volumes
	docker image prune -a --force --filter "until=48h"

update-image-tag:	# Update the image tag in the values-version.yaml file
	@echo "image:\n    tag: $(IMAGE_TAG)\n" > $(CHART_PATH)/values-version.yaml

gen-version:	# Generate the version string
	@echo v`date -u +"%y%m%d-%H%M"`

run-dev:	# Run the app at local environment
	@docker compose -f docker/docker-compose.yml up -d --remove-orphans --no-color

rm-dev:		# Remove the app at local environment
	@docker compose -f docker/docker-compose.yml down -v --remove-orphans
