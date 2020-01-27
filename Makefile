GO_SRC=$(shell find . -name \*.go)
COMMIT_HASH=$(shell git describe --always --tags)
COMMIT=$(if $(shell git status --porcelain --untracked-files=no),$(COMMIT_HASH)-dirty,$(COMMIT_HASH))
TEST?=$(patsubst test/%.bats,%,$(wildcard test/*.bats))

atomfs: $(GO_SRC)
	go build -buildmode=pie -ldflags "-X main.version=$(COMMIT)" -o atomfs ./cmd/...

.PHONY: vendorup
vendorup:
	go get -u

.PHONY: clean
clean:
	-rm atomfs

.PHONY: check
check:
	go fmt ./... && ([ -z $(TRAVIS) ] || git diff --quiet)
	go test ./...
	sudo -E bats -t $(patsubst %,test/%.bats,$(TEST))
