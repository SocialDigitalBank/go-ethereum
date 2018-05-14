# This Makefile is meant to be used by people that do not usually work
# with Go source code. If you know what GOPATH is then you probably
# don't need to bother with make.

.PHONY: gsdb android ios gsdb-cross swarm evm all test clean
.PHONY: gsdb-linux gsdb-linux-386 gsdb-linux-amd64 gsdb-linux-mips64 gsdb-linux-mips64le
.PHONY: gsdb-linux-arm gsdb-linux-arm-5 gsdb-linux-arm-6 gsdb-linux-arm-7 gsdb-linux-arm64
.PHONY: gsdb-darwin gsdb-darwin-386 gsdb-darwin-amd64
.PHONY: gsdb-windows gsdb-windows-386 gsdb-windows-amd64

GOBIN = $(shell pwd)/build/bin
GO ?= latest

gsdb:
	build/env.sh go run build/ci.go install ./cmd/gsdb
	@echo "Done building."
	@echo "Run \"$(GOBIN)/gsdb\" to launch gsdb."

swarm:
	build/env.sh go run build/ci.go install ./cmd/swarm
	@echo "Done building."
	@echo "Run \"$(GOBIN)/swarm\" to launch swarm."

all:
	build/env.sh go run build/ci.go install

android:
	build/env.sh go run build/ci.go aar --local
	@echo "Done building."
	@echo "Import \"$(GOBIN)/gsdb.aar\" to use the library."

ios:
	build/env.sh go run build/ci.go xcode --local
	@echo "Done building."
	@echo "Import \"$(GOBIN)/Gsdb.framework\" to use the library."

test: all
	build/env.sh go run build/ci.go test

lint: ## Run linters.
	build/env.sh go run build/ci.go lint

clean:
	rm -fr build/_workspace/pkg/ $(GOBIN)/*

# The devtools target installs tools required for 'go generate'.
# You need to put $GOBIN (or $GOPATH/bin) in your PATH to use 'go generate'.

devtools:
	env GOBIN= go get -u golang.org/x/tools/cmd/stringer
	env GOBIN= go get -u github.com/kevinburke/go-bindata/go-bindata
	env GOBIN= go get -u github.com/fjl/gencodec
	env GOBIN= go get -u github.com/golang/protobuf/protoc-gen-go
	env GOBIN= go install ./cmd/abigen
	@type "npm" 2> /dev/null || echo 'Please install node.js and npm'
	@type "solc" 2> /dev/null || echo 'Please install solc'
	@type "protoc" 2> /dev/null || echo 'Please install protoc'

# Cross Compilation Targets (xgo)

gsdb-cross: gsdb-linux gsdb-darwin gsdb-windows gsdb-android gsdb-ios
	@echo "Full cross compilation done:"
	@ls -ld $(GOBIN)/gsdb-*

gsdb-linux: gsdb-linux-386 gsdb-linux-amd64 gsdb-linux-arm gsdb-linux-mips64 gsdb-linux-mips64le
	@echo "Linux cross compilation done:"
	@ls -ld $(GOBIN)/gsdb-linux-*

gsdb-linux-386:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=linux/386 -v ./cmd/gsdb
	@echo "Linux 386 cross compilation done:"
	@ls -ld $(GOBIN)/gsdb-linux-* | grep 386

gsdb-linux-amd64:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=linux/amd64 -v ./cmd/gsdb
	@echo "Linux amd64 cross compilation done:"
	@ls -ld $(GOBIN)/gsdb-linux-* | grep amd64

gsdb-linux-arm: gsdb-linux-arm-5 gsdb-linux-arm-6 gsdb-linux-arm-7 gsdb-linux-arm64
	@echo "Linux ARM cross compilation done:"
	@ls -ld $(GOBIN)/gsdb-linux-* | grep arm

gsdb-linux-arm-5:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=linux/arm-5 -v ./cmd/gsdb
	@echo "Linux ARMv5 cross compilation done:"
	@ls -ld $(GOBIN)/gsdb-linux-* | grep arm-5

gsdb-linux-arm-6:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=linux/arm-6 -v ./cmd/gsdb
	@echo "Linux ARMv6 cross compilation done:"
	@ls -ld $(GOBIN)/gsdb-linux-* | grep arm-6

gsdb-linux-arm-7:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=linux/arm-7 -v ./cmd/gsdb
	@echo "Linux ARMv7 cross compilation done:"
	@ls -ld $(GOBIN)/gsdb-linux-* | grep arm-7

gsdb-linux-arm64:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=linux/arm64 -v ./cmd/gsdb
	@echo "Linux ARM64 cross compilation done:"
	@ls -ld $(GOBIN)/gsdb-linux-* | grep arm64

gsdb-linux-mips:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=linux/mips --ldflags '-extldflags "-static"' -v ./cmd/gsdb
	@echo "Linux MIPS cross compilation done:"
	@ls -ld $(GOBIN)/gsdb-linux-* | grep mips

gsdb-linux-mipsle:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=linux/mipsle --ldflags '-extldflags "-static"' -v ./cmd/gsdb
	@echo "Linux MIPSle cross compilation done:"
	@ls -ld $(GOBIN)/gsdb-linux-* | grep mipsle

gsdb-linux-mips64:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=linux/mips64 --ldflags '-extldflags "-static"' -v ./cmd/gsdb
	@echo "Linux MIPS64 cross compilation done:"
	@ls -ld $(GOBIN)/gsdb-linux-* | grep mips64

gsdb-linux-mips64le:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=linux/mips64le --ldflags '-extldflags "-static"' -v ./cmd/gsdb
	@echo "Linux MIPS64le cross compilation done:"
	@ls -ld $(GOBIN)/gsdb-linux-* | grep mips64le

gsdb-darwin: gsdb-darwin-386 gsdb-darwin-amd64
	@echo "Darwin cross compilation done:"
	@ls -ld $(GOBIN)/gsdb-darwin-*

gsdb-darwin-386:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=darwin/386 -v ./cmd/gsdb
	@echo "Darwin 386 cross compilation done:"
	@ls -ld $(GOBIN)/gsdb-darwin-* | grep 386

gsdb-darwin-amd64:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=darwin/amd64 -v ./cmd/gsdb
	@echo "Darwin amd64 cross compilation done:"
	@ls -ld $(GOBIN)/gsdb-darwin-* | grep amd64

gsdb-windows: gsdb-windows-386 gsdb-windows-amd64
	@echo "Windows cross compilation done:"
	@ls -ld $(GOBIN)/gsdb-windows-*

gsdb-windows-386:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=windows/386 -v ./cmd/gsdb
	@echo "Windows 386 cross compilation done:"
	@ls -ld $(GOBIN)/gsdb-windows-* | grep 386

gsdb-windows-amd64:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=windows/amd64 -v ./cmd/gsdb
	@echo "Windows amd64 cross compilation done:"
	@ls -ld $(GOBIN)/gsdb-windows-* | grep amd64
