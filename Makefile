.PHONY: build cleanup

build:
	./scripts/preflight.sh
	./scripts/build.sh
cleanup:
	docker rm -f bnclight
