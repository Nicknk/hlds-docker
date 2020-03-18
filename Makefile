
# Build options
IMAGE_NAME?="nicknk/hlds"
IMAGE_TAG?="latest"

STEAM_USER?="anonymous"
STEAM_PASSWORD?=""

DOCKER_NO_CACHE?="true"

# Publish options
DOCKER_PUBLISH_NAME?="nicknk/hlds"
DOCKER_PUBLISH_TAG?=$(IMAGE_TAG)

# Test tools
SHELLCHECK_IMAGE?="koalaman/shellcheck:v0.4.6"
TEST_CONTAINER_NAME?="test_hlds_auto"
TEST_CONTAINER_PORT?="27015"
HLDS_NAME?="Counter-Strike 1.6 Server"
HLDS_MAP?="de_dust2"
TEST_WEB_PORT?="80"

.PHONY: build
build:
	docker build -f Dockerfile --no-cache=$(DOCKER_NO_CACHE) \
	-t $(IMAGE_NAME):$(IMAGE_TAG) \
	--build-arg steam_user=$(STEAM_USER) \
	--build-arg steam_password=$(STEAM_PASSWORD) .

.PHONY: test
test: shellcheck test-smoke test-clean

.PHONY: shellcheck
shellcheck:
	docker run --rm -v $(PWD):/code \
	--entrypoint sh $(SHELLCHECK_IMAGE) -c \
	"find /code/ -type f -name '*.sh' | xargs shellcheck"

.PHONY: test-start-server
test-start-server:
	$(MAKE) test-stop-server
	docker run -d -p $(TEST_CONTAINER_PORT):27015/udp -p $(TEST_WEB_PORT):80/tcp \
	-e START_MAP=$(HLDS_MAP) -e SERVER_NAME=$(HLDS_NAME) -e GAME=cstrike \
	--name $(TEST_CONTAINER_NAME) $(IMAGE_NAME):$(IMAGE_TAG)

.PHONY: test-stop-server
test-stop-server:
	-docker rm -f $(TEST_CONTAINER_NAME)

.PHONY: test-smoke
test-smoke: test-start-server
	tests/smoke.py

.PHONY: test-clean
test-clean: test-stop-server

.PHONY: clean
clean: test-clean
	-docker rmi $(IMAGE_NAME):$(IMAGE_TAG)

.PHONY: publish
publish:
	docker tag $(IMAGE_NAME):$(IMAGE_TAG) $(DOCKER_PUBLISH_NAME):$(DOCKER_PUBLISH_TAG)
	docker push $(DOCKER_PUBLISH_NAME):$(DOCKER_PUBLISH_TAG)
