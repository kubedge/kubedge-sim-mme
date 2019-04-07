
# Image URL to use all building/pushing image targets
VERSION_V1                  ?= 0.1.0
IMG_BUSINESSLOGIC_DEV       ?= hack4easy/mmesim-fsb-dev:v${VERSION_V1}
IMG_ENRICHMENT_DEV          ?= hack4easy/mmesim-gpb-dev:v${VERSION_V1}
IMG_FRONTEND_DEV            ?= hack4easy/mmesim-lc-dev:v${VERSION_V1}
IMG_LOADBALANCER_DEV        ?= hack4easy/mmesim-ncb-dev:v${VERSION_V1}

IMG_BUSINESSLOGIC_AMD64     ?= hack4easy/mmesim-fsb-amd64:v${VERSION_V1}
IMG_ENRICHMENT_AMD64        ?= hack4easy/mmesim-gpb-amd64:v${VERSION_V1}
IMG_FRONTEND_AMD64          ?= hack4easy/mmesim-lc-amd64:v${VERSION_V1}
IMG_LOADBALANCER_AMD64      ?= hack4easy/mmesim-ncb-amd64:v${VERSION_V1}

IMG_BUSINESSLOGIC_ARM64V8   ?= hack4easy/mmesim-fsb-arm64v8:v${VERSION_V1}
IMG_ENRICHMENT_ARM64V8      ?= hack4easy/mmesim-gpb-arm64v8:v${VERSION_V1}
IMG_FRONTEND_ARM64V8        ?= hack4easy/mmesim-lc-arm64v8:v${VERSION_V1}
IMG_LOADBALANCER_ARM64V8    ?= hack4easy/mmesim-ncb-arm64v8:v${VERSION_V1}

IMG_BUSINESSLOGIC_ARM32V7   ?= hack4easy/mmesim-fsb-arm32v7:v${VERSION_V1}
IMG_ENRICHMENT_ARM32V7      ?= hack4easy/mmesim-gpb-arm32v7:v${VERSION_V1}
IMG_FRONTEND_ARM32V7        ?= hack4easy/mmesim-lc-arm32v7:v${VERSION_V1}
IMG_LOADBALANCER_ARM32V7    ?= hack4easy/mmesim-ncb-arm32v7:v${VERSION_V1}

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
	docker build . -f build/Dockerfile.mmesim-fsb -t ${IMG_BUSINESSLOGIC_DEV}

docker-push-fsb-dev:
	docker push ${IMG_BUSINESSLOGIC_DEV}

docker-build-gpb-dev: vet
	GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -o build/_output/bin/mmesim-gpb -gcflags all=-trimpath=${GOPATH} -asmflags all=-trimpath=${GOPATH} -tags=gpb ./cmd/gpb/...
	docker build . -f build/Dockerfile.mmesim-gpb -t ${IMG_ENRICHMENT_DEV}

docker-push-gpb-dev:
	docker push ${IMG_ENRICHMENT_DEV}

docker-build-lc-dev: vet
	GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -o build/_output/bin/mmesim-lc -gcflags all=-trimpath=${GOPATH} -asmflags all=-trimpath=${GOPATH} -tags=lc ./cmd/lc/...
	docker build . -f build/Dockerfile.mmesim-lc -t ${IMG_FRONTEND_DEV}

docker-push-lc-dev:
	docker push ${IMG_FRONTEND_DEV}

docker-build-ncb-dev: vet
	GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -o build/_output/bin/mmesim-ncb -gcflags all=-trimpath=${GOPATH} -asmflags all=-trimpath=${GOPATH} -tags=ncb ./cmd/ncb/...
	docker build . -f build/Dockerfile.mmesim-ncb -t ${IMG_LOADBALANCER_DEV}

docker-push-ncb-dev:
	docker push ${IMG_LOADBALANCER_DEV}

# AMD64 production
docker-build-fsb-amd64:
	GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -o build/_output/amd64/mmesim-fsb -gcflags all=-trimpath=${GOPATH} -asmflags all=-trimpath=${GOPATH} -tags=fsb ./cmd/fsb/...
	docker build . -f build/Dockerfile.mmesim-fsb.amd64 -t ${IMG_BUSINESSLOGIC_AMD64}

docker-push-fsb-amd64:
	docker push ${IMG_BUSINESSLOGIC_AMD64}

docker-build-gpb-amd64:
	GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -o build/_output/amd64/mmesim-gpb -gcflags all=-trimpath=${GOPATH} -asmflags all=-trimpath=${GOPATH} -tags=gpb ./cmd/gpb/...
	docker build . -f build/Dockerfile.mmesim-gpb.amd64 -t ${IMG_ENRICHMENT_AMD64}

docker-push-gpb-amd64:
	docker push ${IMG_ENRICHMENT_AMD64}

docker-build-lc-amd64:
	GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -o build/_output/amd64/mmesim-lc -gcflags all=-trimpath=${GOPATH} -asmflags all=-trimpath=${GOPATH} -tags=lc ./cmd/lc/...
	docker build . -f build/Dockerfile.mmesim-lc.amd64 -t ${IMG_FRONTEND_AMD64}

docker-push-lc-amd64:
	docker push ${IMG_FRONTEND_AMD64}

docker-build-ncb-amd64:
	GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -o build/_output/amd64/mmesim-ncb -gcflags all=-trimpath=${GOPATH} -asmflags all=-trimpath=${GOPATH} -tags=ncb ./cmd/ncb/...
	docker build . -f build/Dockerfile.mmesim-ncb.amd64 -t ${IMG_LOADBALANCER_AMD64}

docker-push-ncb-amd64:
	docker push ${IMG_LOADBALANCER_AMD64}

#ARM32V7
docker-build-fsb-arm32v7:
	GOOS=linux GOARM=7 GOARCH=arm CGO_ENABLED=0 go build -o build/_output/arm32v7/mmesim-fsb -gcflags all=-trimpath=${GOPATH} -asmflags all=-trimpath=${GOPATH} -tags=fsb ./cmd/fsb/...
	docker build . -f build/Dockerfile.mmesim-fsb.arm32v7 -t ${IMG_BUSINESSLOGIC_ARM32V7}

docker-push-fsb-arm32v7:
	docker push ${IMG_BUSINESSLOGIC_ARM32V7}

docker-build-gpb-arm32v7:
	GOOS=linux GOARM=7 GOARCH=arm CGO_ENABLED=0 go build -o build/_output/arm32v7/mmesim-gpb -gcflags all=-trimpath=${GOPATH} -asmflags all=-trimpath=${GOPATH} -tags=gpb ./cmd/gpb/...
	docker build . -f build/Dockerfile.mmesim-gpb.arm32v7 -t ${IMG_ENRICHMENT_ARM32V7}

docker-push-gpb-arm32v7:
	docker push ${IMG_ENRICHMENT_ARM32V7}

docker-build-lc-arm32v7:
	GOOS=linux GOARM=7 GOARCH=arm CGO_ENABLED=0 go build -o build/_output/arm32v7/mmesim-lc -gcflags all=-trimpath=${GOPATH} -asmflags all=-trimpath=${GOPATH} -tags=lc ./cmd/lc/...
	docker build . -f build/Dockerfile.mmesim-lc.arm32v7 -t ${IMG_FRONTEND_ARM32V7}

docker-push-lc-arm32v7:
	docker push ${IMG_FRONTEND_ARM32V7}

docker-build-ncb-arm32v7:
	GOOS=linux GOARM=7 GOARCH=arm CGO_ENABLED=0 go build -o build/_output/arm32v7/mmesim-ncb -gcflags all=-trimpath=${GOPATH} -asmflags all=-trimpath=${GOPATH} -tags=ncb ./cmd/ncb/...
	docker build . -f build/Dockerfile.mmesim-ncb.arm32v7 -t ${IMG_LOADBALANCER_ARM32V7}

docker-push-ncb-arm32v7:
	docker push ${IMG_LOADBALANCER_ARM32V7}

#ARM64V8
docker-build-fsb-arm64v8:
	GOOS=linux GOARCH=arm64 CGO_ENABLED=0 go build -o build/_output/arm64v8/mmesim-fsb -gcflags all=-trimpath=${GOPATH} -asmflags all=-trimpath=${GOPATH} -tags=fsb ./cmd/fsb/...
	docker build . -f build/Dockerfile.mmesim-fsb.arm64v8 -t ${IMG_BUSINESSLOGIC_ARM64V8}

docker-push-fsb-arm64v8:
	docker push ${IMG_BUSINESSLOGIC_ARM64V8}

docker-build-gpb-arm64v8:
	GOOS=linux GOARCH=arm64 CGO_ENABLED=0 go build -o build/_output/arm64v8/mmesim-gpb -gcflags all=-trimpath=${GOPATH} -asmflags all=-trimpath=${GOPATH} -tags=gpb ./cmd/gpb/...
	docker build . -f build/Dockerfile.mmesim-gpb.arm64v8 -t ${IMG_ENRICHMENT_ARM64V8}

docker-push-gpb-arm64v8:
	docker push ${IMG_ENRICHMENT_ARM64V8}

docker-build-lc-arm64v8:
	GOOS=linux GOARCH=arm64 CGO_ENABLED=0 go build -o build/_output/arm64v8/mmesim-lc -gcflags all=-trimpath=${GOPATH} -asmflags all=-trimpath=${GOPATH} -tags=lc ./cmd/lc/...
	docker build . -f build/Dockerfile.mmesim-lc.arm64v8 -t ${IMG_FRONTEND_ARM64V8}

docker-push-lc-arm64v8:
	docker push ${IMG_FRONTEND_ARM64V8}

docker-build-ncb-arm64v8:
	GOOS=linux GOARCH=arm64 CGO_ENABLED=0 go build -o build/_output/arm64v8/mmesim-ncb -gcflags all=-trimpath=${GOPATH} -asmflags all=-trimpath=${GOPATH} -tags=ncb ./cmd/ncb/...
	docker build . -f build/Dockerfile.mmesim-ncb.arm64v8 -t ${IMG_LOADBALANCER_ARM64V8}

docker-push-ncb-arm64v8:
	docker push ${IMG_LOADBALANCER_ARM64V8}

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
