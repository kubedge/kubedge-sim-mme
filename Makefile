
# Image URL to use all building/pushing image targets
VERSION_V1        ?= 0.2.24
IMG_FSB_DEV       ?= hack4easy/mmesim-fsb-dev:v${VERSION_V1}
IMG_GPB_DEV       ?= hack4easy/mmesim-gpb-dev:v${VERSION_V1}
IMG_LC_DEV        ?= hack4easy/mmesim-lc-dev:v${VERSION_V1}
IMG_NCB_DEV       ?= hack4easy/mmesim-ncb-dev:v${VERSION_V1}

IMG_FSB_AMD64     ?= hack4easy/mmesim-fsb-amd64:v${VERSION_V1}
IMG_GPB_AMD64     ?= hack4easy/mmesim-gpb-amd64:v${VERSION_V1}
IMG_LC_AMD64      ?= hack4easy/mmesim-lc-amd64:v${VERSION_V1}
IMG_NCB_AMD64     ?= hack4easy/mmesim-ncb-amd64:v${VERSION_V1}

IMG_FSB_ARM64V8   ?= hack4easy/mmesim-fsb-arm64v8:v${VERSION_V1}
IMG_GPB_ARM64V8   ?= hack4easy/mmesim-gpb-arm64v8:v${VERSION_V1}
IMG_LC_ARM64V8    ?= hack4easy/mmesim-lc-arm64v8:v${VERSION_V1}
IMG_NCB_ARM64V8   ?= hack4easy/mmesim-ncb-arm64v8:v${VERSION_V1}

IMG_FSB_ARM32V7   ?= hack4easy/mmesim-fsb-arm32v7:v${VERSION_V1}
IMG_GPB_ARM32V7   ?= hack4easy/mmesim-gpb-arm32v7:v${VERSION_V1}
IMG_LC_ARM32V7    ?= hack4easy/mmesim-lc-arm32v7:v${VERSION_V1}
IMG_NCB_ARM32V7   ?= hack4easy/mmesim-ncb-arm32v7:v${VERSION_V1}

IMG_FSB           ?= hack4easy/mmesim-fsb:v${VERSION_V1}
IMG_GPB           ?= hack4easy/mmesim-gpb:v${VERSION_V1}
IMG_LC            ?= hack4easy/mmesim-lc:v${VERSION_V1}
IMG_NCB           ?= hack4easy/mmesim-ncb:v${VERSION_V1}

# CONTAINER_TOOL defines the container tool to be used for building images.
# Be aware that the target commands are only tested with Docker which is
# scaffolded by default. However, you might want to replace it to use other
# tools. (i.e. podman)
CONTAINER_TOOL ?= docker

# Setting SHELL to bash allows bash commands to be executed by recipes.
# Options are set to exit when a recipe line exits non-zero or a piped command fails.
SHELL = /usr/bin/env bash -o pipefail
.SHELLFLAGS = -ec


all: docker-build

setup:
ifndef GOPATH
	$(error GOPATH not defined, please define GOPATH. Run "go help gopath" to learn more about GOPATH)
endif
	# dep ensure

clean:
	rm -fr vendor
	rm -fr cover.out
	rm -fr build/_output
	rm -fr go.sum

unittest: setup fmt vet-v1
	go test ./pkg/... ./cmd/... -coverprofile cover.out

# Run go fmt against code
fmt: setup
	go fmt ./pkg/... ./cmd/...

vet: fmt
	go vet -composites=false ./pkg/... ./cmd/...

docker-build-fsb-dev: vet
	GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -o build/_output/bin/mmesim-fsb -gcflags all=-trimpath=${GOPATH} -asmflags all=-trimpath=${GOPATH} -tags=fsb ./cmd/fsb/...
	docker buildx build --platform=linux/adm64 . -f build/Dockerfile.mmesim-fsb -t ${IMG_FSB_DEV}

docker-push-fsb-dev:
	docker push ${IMG_FSB_DEV}

docker-build-gpb-dev: vet
	GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -o build/_output/bin/mmesim-gpb -gcflags all=-trimpath=${GOPATH} -asmflags all=-trimpath=${GOPATH} -tags=gpb ./cmd/gpb/...
	docker buildx build --platform=linux/adm64 . -f build/Dockerfile.mmesim-gpb -t ${IMG_GPB_DEV}

docker-push-gpb-dev:
	docker push ${IMG_GPB_DEV}

docker-build-lc-dev: vet
	GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -o build/_output/bin/mmesim-lc -gcflags all=-trimpath=${GOPATH} -asmflags all=-trimpath=${GOPATH} -tags=lc ./cmd/lc/...
	docker buildx build --platform=linux/adm64 . -f build/Dockerfile.mmesim-lc -t ${IMG_LC_DEV}

docker-push-lc-dev:
	docker push ${IMG_LC_DEV}

docker-build-ncb-dev: vet
	GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -o build/_output/bin/mmesim-ncb -gcflags all=-trimpath=${GOPATH} -asmflags all=-trimpath=${GOPATH} -tags=ncb ./cmd/ncb/...
	docker buildx build --platform=linux/adm64 . -f build/Dockerfile.mmesim-ncb -t ${IMG_NCB_DEV}

docker-push-ncb-dev:
	docker push ${IMG_NCB_DEV}

# AMD64 production
docker-build-fsb-amd64:
	GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -o build/_output/amd64/mmesim-fsb -gcflags all=-trimpath=${GOPATH} -asmflags all=-trimpath=${GOPATH} -tags=fsb ./cmd/fsb/...
	docker buildx build --platform=linux/adm64 . -f build/Dockerfile.mmesim-fsb.amd64 -t ${IMG_FSB_AMD64}

docker-push-fsb-amd64:
	docker push ${IMG_FSB_AMD64}

docker-build-gpb-amd64:
	GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -o build/_output/amd64/mmesim-gpb -gcflags all=-trimpath=${GOPATH} -asmflags all=-trimpath=${GOPATH} -tags=gpb ./cmd/gpb/...
	docker buildx build --platform=linux/adm64 . -f build/Dockerfile.mmesim-gpb.amd64 -t ${IMG_GPB_AMD64}

docker-push-gpb-amd64:
	docker push ${IMG_GPB_AMD64}

docker-build-lc-amd64:
	GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -o build/_output/amd64/mmesim-lc -gcflags all=-trimpath=${GOPATH} -asmflags all=-trimpath=${GOPATH} -tags=lc ./cmd/lc/...
	docker buildx build --platform=linux/adm64 . -f build/Dockerfile.mmesim-lc.amd64 -t ${IMG_LC_AMD64}

docker-push-lc-amd64:
	docker push ${IMG_LC_AMD64}

docker-build-ncb-amd64:
	GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -o build/_output/amd64/mmesim-ncb -gcflags all=-trimpath=${GOPATH} -asmflags all=-trimpath=${GOPATH} -tags=ncb ./cmd/ncb/...
	docker buildx build --platform=linux/adm64 . -f build/Dockerfile.mmesim-ncb.amd64 -t ${IMG_NCB_AMD64}

docker-push-ncb-amd64:
	docker push ${IMG_NCB_AMD64}

#ARM32V7
docker-build-fsb-arm32v7:
	GOOS=linux GOARM=7 GOARCH=arm CGO_ENABLED=0 go build -o build/_output/arm32v7/mmesim-fsb -gcflags all=-trimpath=${GOPATH} -asmflags all=-trimpath=${GOPATH} -tags=fsb ./cmd/fsb/...
	docker buildx build --platform=linux/arm/v7 . -f build/Dockerfile.mmesim-fsb.arm32v7 -t ${IMG_FSB_ARM32V7}

docker-push-fsb-arm32v7:
	docker push ${IMG_FSB_ARM32V7}

docker-build-gpb-arm32v7:
	GOOS=linux GOARM=7 GOARCH=arm CGO_ENABLED=0 go build -o build/_output/arm32v7/mmesim-gpb -gcflags all=-trimpath=${GOPATH} -asmflags all=-trimpath=${GOPATH} -tags=gpb ./cmd/gpb/...
	docker buildx build --platform=linux/arm/v7 . -f build/Dockerfile.mmesim-gpb.arm32v7 -t ${IMG_GPB_ARM32V7}

docker-push-gpb-arm32v7:
	docker push ${IMG_GPB_ARM32V7}

docker-build-lc-arm32v7:
	GOOS=linux GOARM=7 GOARCH=arm CGO_ENABLED=0 go build -o build/_output/arm32v7/mmesim-lc -gcflags all=-trimpath=${GOPATH} -asmflags all=-trimpath=${GOPATH} -tags=lc ./cmd/lc/...
	docker buildx build --platform=linux/arm/v7 . -f build/Dockerfile.mmesim-lc.arm32v7 -t ${IMG_LC_ARM32V7}

docker-push-lc-arm32v7:
	docker push ${IMG_LC_ARM32V7}

docker-build-ncb-arm32v7:
	GOOS=linux GOARM=7 GOARCH=arm CGO_ENABLED=0 go build -o build/_output/arm32v7/mmesim-ncb -gcflags all=-trimpath=${GOPATH} -asmflags all=-trimpath=${GOPATH} -tags=ncb ./cmd/ncb/...
	docker buildx build --platform=linux/arm/v7 . -f build/Dockerfile.mmesim-ncb.arm32v7 -t ${IMG_NCB_ARM32V7}

docker-push-ncb-arm32v7:
	docker push ${IMG_NCB_ARM32V7}

#ARM64V8
docker-build-fsb-arm64v8:
	GOOS=linux GOARCH=arm64 CGO_ENABLED=0 go build -o build/_output/arm64v8/mmesim-fsb -gcflags all=-trimpath=${GOPATH} -asmflags all=-trimpath=${GOPATH} -tags=fsb ./cmd/fsb/...
	docker buildx build --platform=linux/arm64 . -f build/Dockerfile.mmesim-fsb.arm64v8 -t ${IMG_FSB_ARM64V8}

docker-push-fsb-arm64v8:
	docker push ${IMG_FSB_ARM64V8}

docker-build-gpb-arm64v8:
	GOOS=linux GOARCH=arm64 CGO_ENABLED=0 go build -o build/_output/arm64v8/mmesim-gpb -gcflags all=-trimpath=${GOPATH} -asmflags all=-trimpath=${GOPATH} -tags=gpb ./cmd/gpb/...
	docker buildx build --platform=linux/arm64 . -f build/Dockerfile.mmesim-gpb.arm64v8 -t ${IMG_GPB_ARM64V8}

docker-push-gpb-arm64v8:
	docker push ${IMG_GPB_ARM64V8}

docker-build-lc-arm64v8:
	GOOS=linux GOARCH=arm64 CGO_ENABLED=0 go build -o build/_output/arm64v8/mmesim-lc -gcflags all=-trimpath=${GOPATH} -asmflags all=-trimpath=${GOPATH} -tags=lc ./cmd/lc/...
	docker buildx build --platform=linux/arm64 . -f build/Dockerfile.mmesim-lc.arm64v8 -t ${IMG_LC_ARM64V8}

docker-push-lc-arm64v8:
	docker push ${IMG_LC_ARM64V8}

docker-build-ncb-arm64v8:
	GOOS=linux GOARCH=arm64 CGO_ENABLED=0 go build -o build/_output/arm64v8/mmesim-ncb -gcflags all=-trimpath=${GOPATH} -asmflags all=-trimpath=${GOPATH} -tags=ncb ./cmd/ncb/...
	docker buildx build --platform=linux/arm64 . -f build/Dockerfile.mmesim-ncb.arm64v8 -t ${IMG_NCB_ARM64V8}

docker-push-ncb-arm64v8:
	docker push ${IMG_NCB_ARM64V8}

PLATFORMS ?= linux/arm64,linux/amd64,linux/arm/v7
.PHONY: docker-fsb-buildx
docker-fsb-buildx: ## Build and push docker image for the manager for cross-platform support
	# copy existing Dockerfile and insert --platform=${BUILDPLATFORM} into Dockerfile.fsb.cross, and preserve the original Dockerfile
	sed -e '1 s/\(^FROM\)/FROM --platform=\$$\{BUILDPLATFORM\}/; t' -e ' 1,// s//FROM --platform=\$$\{BUILDPLATFORM\}/' build/Dockerfile.mmesim-fsb.buildkit > Dockerfile.fsb.cross
	- $(CONTAINER_TOOL) buildx create --name project-v3-builder
	$(CONTAINER_TOOL) buildx use project-v3-builder
	- $(CONTAINER_TOOL) buildx build --push --platform=$(PLATFORMS) --tag ${IMG_FSB} -f Dockerfile.fsb.cross .
	- $(CONTAINER_TOOL) buildx rm project-v3-builder
	rm Dockerfile.fsb.cross

.PHONY: docker-gpb-buildx
docker-gpb-buildx: ## Build and push docker image for the manager for cross-platform support
	# copy existing Dockerfile and insert --platform=${BUILDPLATFORM} into Dockerfile.gpb.cross, and preserve the original Dockerfile
	sed -e '1 s/\(^FROM\)/FROM --platform=\$$\{BUILDPLATFORM\}/; t' -e ' 1,// s//FROM --platform=\$$\{BUILDPLATFORM\}/' build/Dockerfile.mmesim-gpb.buildkit > Dockerfile.gpb.cross
	- $(CONTAINER_TOOL) buildx create --name project-v3-builder
	$(CONTAINER_TOOL) buildx use project-v3-builder
	- $(CONTAINER_TOOL) buildx build --push --platform=$(PLATFORMS) --tag ${IMG_GPB} -f Dockerfile.gpb.cross .
	- $(CONTAINER_TOOL) buildx rm project-v3-builder
	rm Dockerfile.gpb.cross

.PHONY: docker-lc-buildx
docker-lc-buildx: ## Build and push docker image for the manager for cross-platform support
	# copy existing Dockerfile and insert --platform=${BUILDPLATFORM} into Dockerfile.lc.cross, and preserve the original Dockerfile
	sed -e '1 s/\(^FROM\)/FROM --platform=\$$\{BUILDPLATFORM\}/; t' -e ' 1,// s//FROM --platform=\$$\{BUILDPLATFORM\}/' build/Dockerfile.mmesim-lc.buildkit > Dockerfile.lc.cross
	- $(CONTAINER_TOOL) buildx create --name project-v3-builder
	$(CONTAINER_TOOL) buildx use project-v3-builder
	- $(CONTAINER_TOOL) buildx build --push --platform=$(PLATFORMS) --tag ${IMG_LC} -f Dockerfile.lc.cross .
	- $(CONTAINER_TOOL) buildx rm project-v3-builder
	rm Dockerfile.lc.cross

.PHONY: docker-ncb-buildx
docker-ncb-buildx: ## Build and push docker image for the manager for cross-platform support
	# copy existing Dockerfile and insert --platform=${BUILDPLATFORM} into Dockerfile.ncb.cross, and preserve the original Dockerfile
	sed -e '1 s/\(^FROM\)/FROM --platform=\$$\{BUILDPLATFORM\}/; t' -e ' 1,// s//FROM --platform=\$$\{BUILDPLATFORM\}/' build/Dockerfile.mmesim-ncb.buildkit > Dockerfile.ncb.cross
	- $(CONTAINER_TOOL) buildx create --name project-v3-builder
	$(CONTAINER_TOOL) buildx use project-v3-builder
	- $(CONTAINER_TOOL) buildx build --push --platform=$(PLATFORMS) --tag ${IMG_NCB} -f Dockerfile.ncb.cross .
	- $(CONTAINER_TOOL) buildx rm project-v3-builder
	rm Dockerfile.ncb.cross

# Build the docker image
docker-build-dev: docker-build-fsb-dev docker-build-gpb-dev docker-build-lc-dev docker-build-ncb-dev
docker-build-amd64: docker-build-fsb-amd64 docker-build-gpb-amd64 docker-build-lc-amd64 docker-build-ncb-amd64
docker-build-arm32v7: docker-build-fsb-arm32v7 docker-build-gpb-arm32v7 docker-build-lc-arm32v7 docker-build-ncb-arm32v7
docker-build-arm64v8: docker-build-fsb-arm64v8 docker-build-gpb-arm64v8 docker-build-lc-arm64v8 docker-build-ncb-arm64v8

docker-build: fmt vet docker-build-dev docker-build-amd64 docker-build-arm32v7 docker-build-arm64v8

# Push the docker image
docker-push-dev: docker-push-fsb-dev docker-push-gpb-dev docker-push-lc-dev docker-push-ncb-dev
docker-push-amd64: docker-push-fsb-amd64 docker-push-gpb-amd64 docker-push-lc-amd64 docker-push-ncb-amd64
docker-push-arm32v7: docker-push-fsb-arm32v7 docker-push-gpb-arm32v7 docker-push-lc-arm32v7 docker-push-ncb-arm32v7
docker-push-arm64v8: docker-push-fsb-arm64v8 docker-push-gpb-arm64v8 docker-push-lc-arm64v8 docker-push-ncb-arm64v8

docker-push: docker-push-dev docker-push-amd64 docker-push-arm32v7 docker-push-arm64v8

# Cross compilation
docker-buildx: fmt vet docker-fsb-buildx docker-gpb-buildx docker-lc-buildx docker-ncb-buildx
