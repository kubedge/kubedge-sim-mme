
# Image URL to use all building/pushing image targets
VERSION            ?= 0.2.24

# Arch-independent image tags — one multi-arch manifest list per component,
# produced by the `docker-buildx` path below. These are the tags the paired
# kubedge-operator-mme MMESim CR references.
IMG_FSB            ?= hack4easy/mmesim-fsb:v${VERSION}
IMG_GPB            ?= hack4easy/mmesim-gpb:v${VERSION}
IMG_LC             ?= hack4easy/mmesim-lc:v${VERSION}
IMG_NCB            ?= hack4easy/mmesim-ncb:v${VERSION}

# RETIRED: superseded by docker-buildx — the arch-suffixed (-dev/-amd64/
# -arm64v8/-arm32v7) image tags are replaced by the single arch-independent
# IMG_<C> above (buildx emits one multi-arch manifest list per component).
# IMG_FSB_DEV       ?= hack4easy/mmesim-fsb-dev:v${VERSION}
# IMG_GPB_DEV       ?= hack4easy/mmesim-gpb-dev:v${VERSION}
# IMG_LC_DEV        ?= hack4easy/mmesim-lc-dev:v${VERSION}
# IMG_NCB_DEV       ?= hack4easy/mmesim-ncb-dev:v${VERSION}
#
# IMG_FSB_AMD64     ?= hack4easy/mmesim-fsb-amd64:v${VERSION}
# IMG_GPB_AMD64     ?= hack4easy/mmesim-gpb-amd64:v${VERSION}
# IMG_LC_AMD64      ?= hack4easy/mmesim-lc-amd64:v${VERSION}
# IMG_NCB_AMD64     ?= hack4easy/mmesim-ncb-amd64:v${VERSION}
#
# IMG_FSB_ARM64V8   ?= hack4easy/mmesim-fsb-arm64v8:v${VERSION}
# IMG_GPB_ARM64V8   ?= hack4easy/mmesim-gpb-arm64v8:v${VERSION}
# IMG_LC_ARM64V8    ?= hack4easy/mmesim-lc-arm64v8:v${VERSION}
# IMG_NCB_ARM64V8   ?= hack4easy/mmesim-ncb-arm64v8:v${VERSION}
#
# IMG_FSB_ARM32V7   ?= hack4easy/mmesim-fsb-arm32v7:v${VERSION}
# IMG_GPB_ARM32V7   ?= hack4easy/mmesim-gpb-arm32v7:v${VERSION}
# IMG_LC_ARM32V7    ?= hack4easy/mmesim-lc-arm32v7:v${VERSION}
# IMG_NCB_ARM32V7   ?= hack4easy/mmesim-ncb-arm32v7:v${VERSION}

# CONTAINER_TOOL defines the container tool to be used for building images.
# Be aware that the target commands are only tested with Docker which is
# scaffolded by default. However, you might want to replace it to use other
# tools. (i.e. podman)
CONTAINER_TOOL ?= docker

# Setting SHELL to bash allows bash commands to be executed by recipes.
# Options are set to exit when a recipe line exits non-zero or a piped command fails.
SHELL = /usr/bin/env bash -o pipefail
.SHELLFLAGS = -ec

# docker-buildx is the sole go-forward image path: one multi-arch manifest
# list per component, built from build/Dockerfile.mmesim-<c>.buildkit (which
# pins `FROM --platform=$$BUILDPLATFORM` and cross-compiles via GOARCH).
all: docker-buildx

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

unittest: setup fmt vet
	go test ./pkg/... ./cmd/... -coverprofile cover.out

# Run go fmt against code
fmt: setup
	go fmt ./pkg/... ./cmd/...

vet: fmt
	go vet -composites=false ./pkg/... ./cmd/...

# ---------------------------------------------------------------------------
# Cross-platform multi-arch images (buildx) — THE go-forward path.
# Each target drives the existing build/Dockerfile.mmesim-<c>.buildkit directly.
# The Dockerfile already pins the builder to $$BUILDPLATFORM and cross-compiles
# (CGO_ENABLED=0, GOARCH=$$TARGETARCH), so no per-arch emulation is needed.
# Requires a live buildx builder (e.g. `colima start` on Apple Silicon).
# NOTE: buildx pushes multi-arch manifests directly (can't --load a manifest
# list), so these targets --push. arm/v7 retired from the default PLATFORMS
# (validated on arm64+amd64); re-add `,linux/arm/v7` if a target needs it.
# ---------------------------------------------------------------------------
PLATFORMS ?= linux/arm64,linux/amd64

.PHONY: docker-fsb-buildx
docker-fsb-buildx: ## Build and push the multi-arch fsb image
	$(CONTAINER_TOOL) buildx build --push --platform=$(PLATFORMS) -t ${IMG_FSB} -f build/Dockerfile.mmesim-fsb.buildkit .

.PHONY: docker-gpb-buildx
docker-gpb-buildx: ## Build and push the multi-arch gpb image
	$(CONTAINER_TOOL) buildx build --push --platform=$(PLATFORMS) -t ${IMG_GPB} -f build/Dockerfile.mmesim-gpb.buildkit .

.PHONY: docker-lc-buildx
docker-lc-buildx: ## Build and push the multi-arch lc image
	$(CONTAINER_TOOL) buildx build --push --platform=$(PLATFORMS) -t ${IMG_LC} -f build/Dockerfile.mmesim-lc.buildkit .

.PHONY: docker-ncb-buildx
docker-ncb-buildx: ## Build and push the multi-arch ncb image
	$(CONTAINER_TOOL) buildx build --push --platform=$(PLATFORMS) -t ${IMG_NCB} -f build/Dockerfile.mmesim-ncb.buildkit .

# Cross compilation — build + push all four multi-arch images
docker-buildx: fmt vet docker-fsb-buildx docker-gpb-buildx docker-lc-buildx docker-ncb-buildx

# ===========================================================================
# RETIRED: superseded by docker-buildx.
# The per-variant (dev / amd64 / arm32v7 / arm64v8) single-arch build + push
# targets below drove the plain + per-arch Dockerfiles (build/Dockerfile.mmesim-*
# and *.amd64 / *.arm32v7 / *.arm64v8). They are kept commented (not deleted)
# for reference and rollback. The go-forward path is the buildx section above.
# ===========================================================================
#
# --- dev ---
# docker-build-fsb-dev: vet
# 	GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -o build/_output/bin/mmesim-fsb -gcflags all=-trimpath=${GOPATH} -asmflags all=-trimpath=${GOPATH} -tags=fsb ./cmd/fsb/...
# 	docker buildx build --platform=linux/amd64 . -f build/Dockerfile.mmesim-fsb -t ${IMG_FSB_DEV}
# docker-push-fsb-dev:
# 	docker push ${IMG_FSB_DEV}
# docker-build-gpb-dev: vet
# 	GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -o build/_output/bin/mmesim-gpb -gcflags all=-trimpath=${GOPATH} -asmflags all=-trimpath=${GOPATH} -tags=gpb ./cmd/gpb/...
# 	docker buildx build --platform=linux/amd64 . -f build/Dockerfile.mmesim-gpb -t ${IMG_GPB_DEV}
# docker-push-gpb-dev:
# 	docker push ${IMG_GPB_DEV}
# docker-build-lc-dev: vet
# 	GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -o build/_output/bin/mmesim-lc -gcflags all=-trimpath=${GOPATH} -asmflags all=-trimpath=${GOPATH} -tags=lc ./cmd/lc/...
# 	docker buildx build --platform=linux/amd64 . -f build/Dockerfile.mmesim-lc -t ${IMG_LC_DEV}
# docker-push-lc-dev:
# 	docker push ${IMG_LC_DEV}
# docker-build-ncb-dev: vet
# 	GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -o build/_output/bin/mmesim-ncb -gcflags all=-trimpath=${GOPATH} -asmflags all=-trimpath=${GOPATH} -tags=ncb ./cmd/ncb/...
# 	docker buildx build --platform=linux/amd64 . -f build/Dockerfile.mmesim-ncb -t ${IMG_NCB_DEV}
# docker-push-ncb-dev:
# 	docker push ${IMG_NCB_DEV}
#
# --- AMD64 production ---
# docker-build-fsb-amd64:
# 	GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -o build/_output/amd64/mmesim-fsb -gcflags all=-trimpath=${GOPATH} -asmflags all=-trimpath=${GOPATH} -tags=fsb ./cmd/fsb/...
# 	docker buildx build --platform=linux/amd64 . -f build/Dockerfile.mmesim-fsb.amd64 -t ${IMG_FSB_AMD64}
# docker-push-fsb-amd64:
# 	docker push ${IMG_FSB_AMD64}
# docker-build-gpb-amd64:
# 	GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -o build/_output/amd64/mmesim-gpb -gcflags all=-trimpath=${GOPATH} -asmflags all=-trimpath=${GOPATH} -tags=gpb ./cmd/gpb/...
# 	docker buildx build --platform=linux/amd64 . -f build/Dockerfile.mmesim-gpb.amd64 -t ${IMG_GPB_AMD64}
# docker-push-gpb-amd64:
# 	docker push ${IMG_GPB_AMD64}
# docker-build-lc-amd64:
# 	GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -o build/_output/amd64/mmesim-lc -gcflags all=-trimpath=${GOPATH} -asmflags all=-trimpath=${GOPATH} -tags=lc ./cmd/lc/...
# 	docker buildx build --platform=linux/amd64 . -f build/Dockerfile.mmesim-lc.amd64 -t ${IMG_LC_AMD64}
# docker-push-lc-amd64:
# 	docker push ${IMG_LC_AMD64}
# docker-build-ncb-amd64:
# 	GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -o build/_output/amd64/mmesim-ncb -gcflags all=-trimpath=${GOPATH} -asmflags all=-trimpath=${GOPATH} -tags=ncb ./cmd/ncb/...
# 	docker buildx build --platform=linux/amd64 . -f build/Dockerfile.mmesim-ncb.amd64 -t ${IMG_NCB_AMD64}
# docker-push-ncb-amd64:
# 	docker push ${IMG_NCB_AMD64}
#
# --- ARM32V7 ---
# docker-build-fsb-arm32v7:
# 	GOOS=linux GOARM=7 GOARCH=arm CGO_ENABLED=0 go build -o build/_output/arm32v7/mmesim-fsb -gcflags all=-trimpath=${GOPATH} -asmflags all=-trimpath=${GOPATH} -tags=fsb ./cmd/fsb/...
# 	docker buildx build --platform=linux/arm/v7 . -f build/Dockerfile.mmesim-fsb.arm32v7 -t ${IMG_FSB_ARM32V7}
# docker-push-fsb-arm32v7:
# 	docker push ${IMG_FSB_ARM32V7}
# docker-build-gpb-arm32v7:
# 	GOOS=linux GOARM=7 GOARCH=arm CGO_ENABLED=0 go build -o build/_output/arm32v7/mmesim-gpb -gcflags all=-trimpath=${GOPATH} -asmflags all=-trimpath=${GOPATH} -tags=gpb ./cmd/gpb/...
# 	docker buildx build --platform=linux/arm/v7 . -f build/Dockerfile.mmesim-gpb.arm32v7 -t ${IMG_GPB_ARM32V7}
# docker-push-gpb-arm32v7:
# 	docker push ${IMG_GPB_ARM32V7}
# docker-build-lc-arm32v7:
# 	GOOS=linux GOARM=7 GOARCH=arm CGO_ENABLED=0 go build -o build/_output/arm32v7/mmesim-lc -gcflags all=-trimpath=${GOPATH} -asmflags all=-trimpath=${GOPATH} -tags=lc ./cmd/lc/...
# 	docker buildx build --platform=linux/arm/v7 . -f build/Dockerfile.mmesim-lc.arm32v7 -t ${IMG_LC_ARM32V7}
# docker-push-lc-arm32v7:
# 	docker push ${IMG_LC_ARM32V7}
# docker-build-ncb-arm32v7:
# 	GOOS=linux GOARM=7 GOARCH=arm CGO_ENABLED=0 go build -o build/_output/arm32v7/mmesim-ncb -gcflags all=-trimpath=${GOPATH} -asmflags all=-trimpath=${GOPATH} -tags=ncb ./cmd/ncb/...
# 	docker buildx build --platform=linux/arm/v7 . -f build/Dockerfile.mmesim-ncb.arm32v7 -t ${IMG_NCB_ARM32V7}
# docker-push-ncb-arm32v7:
# 	docker push ${IMG_NCB_ARM32V7}
#
# --- ARM64V8 ---
# docker-build-fsb-arm64v8:
# 	GOOS=linux GOARCH=arm64 CGO_ENABLED=0 go build -o build/_output/arm64v8/mmesim-fsb -gcflags all=-trimpath=${GOPATH} -asmflags all=-trimpath=${GOPATH} -tags=fsb ./cmd/fsb/...
# 	docker buildx build --platform=linux/arm64 . -f build/Dockerfile.mmesim-fsb.arm64v8 -t ${IMG_FSB_ARM64V8}
# docker-push-fsb-arm64v8:
# 	docker push ${IMG_FSB_ARM64V8}
# docker-build-gpb-arm64v8:
# 	GOOS=linux GOARCH=arm64 CGO_ENABLED=0 go build -o build/_output/arm64v8/mmesim-gpb -gcflags all=-trimpath=${GOPATH} -asmflags all=-trimpath=${GOPATH} -tags=gpb ./cmd/gpb/...
# 	docker buildx build --platform=linux/arm64 . -f build/Dockerfile.mmesim-gpb.arm64v8 -t ${IMG_GPB_ARM64V8}
# docker-push-gpb-arm64v8:
# 	docker push ${IMG_GPB_ARM64V8}
# docker-build-lc-arm64v8:
# 	GOOS=linux GOARCH=arm64 CGO_ENABLED=0 go build -o build/_output/arm64v8/mmesim-lc -gcflags all=-trimpath=${GOPATH} -asmflags all=-trimpath=${GOPATH} -tags=lc ./cmd/lc/...
# 	docker buildx build --platform=linux/arm64 . -f build/Dockerfile.mmesim-lc.arm64v8 -t ${IMG_LC_ARM64V8}
# docker-push-lc-arm64v8:
# 	docker push ${IMG_LC_ARM64V8}
# docker-build-ncb-arm64v8:
# 	GOOS=linux GOARCH=arm64 CGO_ENABLED=0 go build -o build/_output/arm64v8/mmesim-ncb -gcflags all=-trimpath=${GOPATH} -asmflags all=-trimpath=${GOPATH} -tags=ncb ./cmd/ncb/...
# 	docker buildx build --platform=linux/arm64 . -f build/Dockerfile.mmesim-ncb.arm64v8 -t ${IMG_NCB_ARM64V8}
# docker-push-ncb-arm64v8:
# 	docker push ${IMG_NCB_ARM64V8}
#
# --- Retired aggregates ---
# docker-build-dev: docker-build-fsb-dev docker-build-gpb-dev docker-build-lc-dev docker-build-ncb-dev
# docker-build-amd64: docker-build-fsb-amd64 docker-build-gpb-amd64 docker-build-lc-amd64 docker-build-ncb-amd64
# docker-build-arm32v7: docker-build-fsb-arm32v7 docker-build-gpb-arm32v7 docker-build-lc-arm32v7 docker-build-ncb-arm32v7
# docker-build-arm64v8: docker-build-fsb-arm64v8 docker-build-gpb-arm64v8 docker-build-lc-arm64v8 docker-build-ncb-arm64v8
# docker-build: fmt vet docker-build-dev docker-build-amd64 docker-build-arm32v7 docker-build-arm64v8
# docker-push-dev: docker-push-fsb-dev docker-push-gpb-dev docker-push-lc-dev docker-push-ncb-dev
# docker-push-amd64: docker-push-fsb-amd64 docker-push-gpb-amd64 docker-push-lc-amd64 docker-push-ncb-amd64
# docker-push-arm32v7: docker-push-fsb-arm32v7 docker-push-gpb-arm32v7 docker-push-lc-arm32v7 docker-push-ncb-arm32v7
# docker-push-arm64v8: docker-push-fsb-arm64v8 docker-push-gpb-arm64v8 docker-push-lc-arm64v8 docker-push-ncb-arm64v8
# docker-push: docker-push-dev docker-push-amd64 docker-push-arm32v7 docker-push-arm64v8
