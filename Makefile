.DEFAULT_GOAL := help
.PHONY: help

ENV = dev
PWD = $(shell pwd)
RUN_TIMESTAMP = $(shell date +%Y.%m.%d.%H%M)
PLAYBOOK ?=

## Get dependencies
# Example: make deps
deps:
	ansible-galaxy install -p ansible/vendor -r ansible/roles.yml

## Clean up
clean:
	rm -rf ansible/vendor/*

## Configures application
# Examples: make configure ENV=dev ROLE=sanfilippoinitiative
configure:
	ansible-playbook -i ansible/inventory/mydevil \
		--extra-vars hosts=s2 \
		--extra-vars env=$(ENV) \
		--extra-vars pwd=$(PWD) \
		--extra-vars @ansible/vars/environment/$(ENV)/services.yml \
		--extra-vars @ansible/vars/environment/$(ENV)/secrets.yml \
		--tags configure \
		$(EXTRAS) \
		ansible/playbooks/$(ROLE).yml

## Runs any playbook
# Examples: make playbook PLAYBOOK=support/backup.yml
#           make playbook PLAYBOOK=support/restore.yml ENV=dev EXTRAS='-ebackup_name=dev'
playbook:
	ansible-playbook -i ansible/inventory/mydevil \
		--extra-vars hosts=s2 \
		--extra-vars env=$(ENV) \
		--extra-vars pwd=$(PWD) \
		--extra-vars run_timestamp=$(RUN_TIMESTAMP) \
		--extra-vars @ansible/vars/environment/$(ENV)/services.yml \
		--extra-vars @ansible/vars/environment/$(ENV)/secrets.yml \
		$(EXTRAS) \
		ansible/playbooks/$(PLAYBOOK)

## Prints this help
help:
	@grep -h -E '^#' -A 1 $(MAKEFILE_LIST) | grep -v "-" | \
	awk 'BEGIN{ doc_mode=0; doc=""; doc_h=""; FS="#" } { \
		if (""!=$$3) { doc_mode=2 } \
		if (match($$1, /^[%.a-zA-Z_-]+:/) && doc_mode==1) { sub(/:.*/, "", $$1); printf "\033[34m%-30s\033[0m\033[1m%s\033[0m %s\n\n", $$1, doc_h, doc; doc_mode=0; doc="" } \
		if (doc_mode==1) { $$1=""; doc=doc "\n" $$0 } \
		if (doc_mode==2) { doc_mode=1; doc_h=$$3 } }'

# creates empty `.make` if it does not exist
# run `make deps` if you want to auto generate `.make` file
.make:
	echo "" > .make
