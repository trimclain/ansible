SHELL := /bin/bash

OS := $(shell awk -F= '$$1=="ID" { print $$2 ;}' /etc/os-release)

ifeq ($(OS), ubuntu)
	INSTALL = sudo apt install -y
else
	INSTALL = sudo pacman -S --noconfirm --needed
endif

all: ansible ssh ## Install ansible and my ssh keys
	@# Installing everything
	@echo "Installation finished"

help: ## Print this help menu
	@cat $(MAKEFILE_LIST) | grep -E '^[a-zA-Z_-]+:.*?## .*$$' | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

ansible: ## Install ansible
	@echo "==================================================================="
	@if [ -f /usr/bin/ansible ]; then echo "[ansible]: Already installed";\
		else echo "Installing ansible..." && $(INSTALL) ansible; fi

ssh: ## Install my ssh keys
	@echo "==================================================================="
	@echo "Installing ssh keys..."
	@if [ -d ~/.ssh ]; then echo 'Found existing "~/.ssh", renaming it to "~/.ssh.backup"' &&\
		mv ~/.ssh ~/.ssh.backup; fi
	@# Copy my keys
	@cp -r .ssh ~/.ssh
	@# Set correct permissions
	@chmod 700 ~/.ssh
	@chmod 600 ~/.ssh/id_rsa
	@chmod 644 ~/.ssh/id_rsa.pub
	@# Decrypt my private key
	@ansible-vault decrypt ~/.ssh/id_rsa
	@# Move known_hosts and authorized_keys back to ~/.ssh
	@if [ -f ~/.ssh.backup/known_hosts ]; then echo 'Found existing "~/.ssh.backup/known_hosts", moving it to "~/.ssh"' &&\
		mv ~/.ssh.backup/known_hosts ~/.ssh; fi
	@if [ -f ~/.ssh.backup/authorized_keys ]; then echo 'Found existing "~/.ssh.backup/authorized_keys", moving it to "~/.ssh"' &&\
		mv ~/.ssh.backup/authorized_keys ~/.ssh; fi

.PHONY: all help ansible ssh
