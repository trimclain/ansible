SHELL := /bin/bash

all:
	@# Installing everything
	@echo "Done"

help: ## Print this help menu
	@cat $(MAKEFILE_LIST) | grep -E '^[a-zA-Z_-]+:.*?## .*$$' | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

ssh: ## Install my ssh keys
	@if [ -d ~/.ssh ]; then echo 'Found existing "~/.ssh", renaming it to "~/.ssh.backup"' &&\
		mv ~/.ssh ~/.ssh.backup; fi
	@# Copy my keys
	@cp -r .ssh ~/.ssh
	@# Set correct permissions
	@chmod 600 ~/.ssh/id_rsa
	@chmod 644 ~/.ssh/id_rsa.pub
	@# Decrypt my private key
	@ansible-vault decrypt ~/.ssh/id_rsa

.PHONY: all help ssh
