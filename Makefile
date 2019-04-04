
# Image URL to use all building/pushing image targets
VERSION_V1   ?= 0.1.0
IMG_FSB      ?= hack4easy/mmesim-fsb-dev:v${VERSION_V1}
IMG_GPB      ?= hack4easy/mmesim-gpb-dev:v${VERSION_V1}
IMG_LC       ?= hack4easy/mmesim-lc-dev:v${VERSION_V1}
IMG_NCB      ?= hack4easy/mmesim-ncb-dev:v${VERSION_V1}

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

unittest: setup fmt vet-v1
	go test ./pkg/... ./cmd/... -coverprofile cover.out

# Run go fmt against code
fmt: setup
	go fmt ./pkg/... ./cmd/...

vet: fmt
	go vet -composites=false -tags=fsb ./pkg/... ./cmd/...

docker-build-fsb: vet
	GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -o build/_output/bin/mmesim-fsb -gcflags all=-trimpath=${GOPATH} -asmflags all=-trimpath=${GOPATH} -tags=fsb ./cmd/fsb/...
	docker build . -f build/Dockerfile.mmesim-fsb -t ${IMG_FSB}

docker-push-fsb:
	docker push ${IMG_FSB}

docker-build-gpb: vet
	GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -o build/_output/bin/mmesim-gpb -gcflags all=-trimpath=${GOPATH} -asmflags all=-trimpath=${GOPATH} -tags=gpb ./cmd/gpb/...
	docker build . -f build/Dockerfile.mmesim-gpb -t ${IMG_GPB}

docker-push-gpb:
	docker push ${IMG_GPB}

docker-build-lc: vet
	GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -o build/_output/bin/mmesim-lc -gcflags all=-trimpath=${GOPATH} -asmflags all=-trimpath=${GOPATH} -tags=lc ./cmd/lc/...
	docker build . -f build/Dockerfile.mmesim-lc -t ${IMG_LC}

docker-push-lc:
	docker push ${IMG_LC}

docker-build-ncb: vet
	GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -o build/_output/bin/mmesim-ncb -gcflags all=-trimpath=${GOPATH} -asmflags all=-trimpath=${GOPATH} -tags=ncb ./cmd/ncb/...
	docker build . -f build/Dockerfile.mmesim-ncb -t ${IMG_NCB}

docker-push-ncb:
	docker push ${IMG_NCB}

# Build the docker image
docker-build: fmt docker-build-fsb docker-build-gpb docker-build-lc docker-build-ncb

# Push the docker image
docker-push: docker-push-fsb docker-push-gpb docker-push-lc docker-push-ncb
