include Makefile

.PHONY: build-ocp
build-ocp:
	CGO_ENABLED=0 go build -mod=vendor -a -o manager ./cmd
