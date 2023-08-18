SHELL := /bin/bash -euo pipefail
export ROOT_DIR := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
export REFERENCE_DIR ?= $(ROOT_DIR)/git_delete_stale_branches

export PROJECT ?= git_delete_stale_branches

export USER_UID := $(shell id -u)
export USER_GID := $(shell id -g)

REC_FILES := $(shell find . -iname '*.rec')

ENTRYPOINT := ./git_delete_stale_branches/usr/local/bin/git_delete_stale_branches
LIB := ./git_delete_stale_branches/usr/local/lib/git_delete_stale_branches/git_delete_stale_branches

TEMPLATED_FILES := $(patsubst %.jinja,%,$(shell find . -iname '*.jinja'))

IS_PACKAGING ?= false

all: $(TEMPLATED_FILES) check package test

dev:
	cp ./other/git/hooks/pre-commit ./.git/hooks/pre-commit
	chmod a+x ./other/git/hooks/pre-commit ./.git/hooks/pre-commit
	@#
	git config --global commit.cleanup strip
	test -d .git
	cp $(HOME)/dev/pud/my_templates/code/git/hooks/prepare-commit-msg ./.git/hooks/prepare-commit-msg
	chmod a+x ./.git/hooks/prepare-commit-msg

check_recutils: $(REC_FILES)
	echo $(REC_FILES) | xargs -n 1 -- recfix --check --
	echo $(REC_FILES) | xargs -n 1 -- recfix --sort --

clean:
	set -x ; ! [[ $$(realpath --relative-base="/tmp" -- "$$(pwd)") =~ ^/ ]]
ifeq ($(IS_PACKAGING), true)
	git reset --hard || true
	git clean -xfd || true
	git submodule foreach --recursive git clean -xfd || true
	rm -rf ./submodules || true
	mkdir ./submodules || true
	git submodule update --init --recursive || true
endif

check: check_recutils check_shell

# ???: use own documentation/standards for it.
# ???: `shfmt`.
# We have false positive errors, hence `|| true`.
check_shell:
	{ git ls | grep -E '.*sh$$' ; git ls | grep --invert-match -E 'makefile' | xargs grep --files-with-matches -E 'filetype=sh' ; } \
        | sort -u \
        | parallel --verbose -- shellcheck --check-sourced --enable all || true
	@# tomdoc.sh --markdown /home/felipev/dev/pud/gnu_make_api/bin/git_delete_stale_branches

test: build_prepare test_host test_docker .FORCE

build_prepare: other/test/data/fake_repos_01.tar

other/test/data/fake_repos_01.tar: ./other/test/data/create_tarballs .FORCE
	bash -xv ./other/test/data/create_tarballs

test_host: .FORCE
	bash -xv ./other/test/docker/host_test
	@# bash $(ENTRYPOINT) --test
	@# bash $(ENTRYPOINT) --test --verbose
	@# not bash $(ENTRYPOINT)

# <https://asic-linux.com.mx/~izto/checkinstall/docs/README>.
package:
	bash ./other/package/package

install:
	cptar $(REFERENCE_DIR) / || true

release:
	make package
	sort -u <(find . -iname '*.deb' | one | xargs -- sha512sum) <(cat ./other/package/releases.md5) | sponge ./other/package/releases.md5
	gpg2 --yes --batch --clearsign --local-user felipev@telnyx.com -- ./other/package/releases.md5

# Formatting section. --- {{{

format: format_yaml format_json

format_yaml:
	find $(ROOT_DIR) \( -iname '*.yml' -o -iname '*.yaml' -o -iname '.yamlfmt' \) -type f -print0 | xargs -0 -n 100 -- yamlfmt

format_json:
	find . -iname '*.json' -print0 | parallel --null --max-args 1 -- 'python3 -m json.tool --sort-keys {} > /tmp/$(PROJECT)_{}_ {}'

#  --- }}}

# `docker` section. --- {{{

DOCKER_COMPOSE_FILE := ./compose.yaml

DOCKER_BUILD_ARGS = \
    --build-arg USER_UID='$(USER_UID)' \
    --build-arg USER_GID='$(USER_GID)' \
    --build-arg GIT_COMMIT='$(or $(shell git show -s --format=%H), no_git)' \
    --build-arg GIT_COMMIT_DATE='$(or $(shell git show -s --date=iso8601 --format=%ci), no_git)' \
    --build-arg IMAGE_NAME='$(PROJECT)' \
    --build-arg BUILD_DATE='$(shell date --iso-8601=seconds)'

ifndef DOCKER_CMD_RUN
    DOCKER_CMD_RUN := bash
endif

test_docker: package build .FORCE
	DOCKER_CMD_RUN='/usr/local/bin/docker_test' make docker_run

build: build_prepare readme.md .FORCE
	docker-compose --file $(DOCKER_COMPOSE_FILE) build $(DOCKER_BUILD_ARGS)

docker_run:
	docker-compose \
        --file $(DOCKER_COMPOSE_FILE) \
        run \
        --rm \
        --entrypoint '' \
        git_delete_stale_branches \
        $(DOCKER_CMD_RUN)

down:
	docker-compose --file $(DOCKER_COMPOSE_FILE) down --remove-orphans

#  --- }}}

# "Specifics" section. --- {{{

%: %.jinja
	jinja \
        --define users $(shell seq 0 10 | paste --serial --delimiters ',') \
        -- \
    $< | sponge $@

readme.md: readme.md.jinja docs/manpage.md.clean
	jinja \
        --define users $(shell seq 0 10 | paste --serial --delimiters ',') \
        --define disclaimer '<!--                          DO NOT EDIT THIS FILE                          -->' \
        -- \
    $< | sponge $@
	rm docs/manpage.md.clean

docs/manpage.md.clean: docs/manpage.md
	pandoc2 --strip-comments --shift-heading-level-by 2 --from markdown --to markdown_github $< | sponge $@

#  --- }}}

git_delete_stale_branches: .FORCE
	git_delete_stale_branches --delete --git-directory . --config-directory ./other/git/branches

.FORCE:

# vim: set filetype=make fileformat=unix nowrap spell spelllang=en :
