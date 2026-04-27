include Makefile

.PHONY: build-ocp
build-ocp: clean fmt
	CGO_ENABLED=1 $(GO_BUILD_ENV) go build $(COMMON_BUILD_ARGS) -tags=strictfipsruntime -mod=vendor -a -o manager ./cmd

apply-override-snapshot:
	oc apply -f .konflux_release/snapshot
.PHONY: apply-override-snapshot

apply-releaseplan:
	oc apply -f .konflux_release/releasePlan
.PHONY: apply-releaseplan

apply-releases:
	oc apply -f .konflux_release/releases
.PHONY: apply-releases
