APPLICATION=kafka-manager
REPOSITORY=castle
VERSION=${VERSION}

.PHONY: help

help: ## show help
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.DEFAULT_GOAL := help

build: ## build container
	docker build -t $(APPLICATION) --build-arg VERSION=$(VERSION) .

build-nc: ## build container without caching
	docker build --no-cache -t $(APPLICATION) --build-arg VERSION=$(VERSION) .

release: build-nc publish ## release container to docker hub

publish: publish-latest publish-version ## publish the `version` and `latest` container tags

publish-latest: tag-latest ## publish `latest` container tag
	docker push $(REPOSITORY)/$(APPLICATION):latest

publish-version: tag-version ## publish `version` container tag
	docker push $(REPOSITORY)/$(APPLICATION):$(VERSION)

tag: tag-latest tag-version ## tag container with `version` and `latest`

tag-latest: ## generate container `latest` tag
	docker tag $(APPLICATION) $(REPOSITORY)/$(APPLICATION):latest

tag-version: ## Generate container `version` tag
	docker tag $(APPLICATION) $(REPOSITORY)/$(APPLICATION):$(VERSION)
