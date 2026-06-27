SHELL := /bin/bash

OS := $(shell awk -F= '$$1=="ID" { print $$2 ;}' /etc/os-release)

ifneq (,$(filter debian ubuntu linuxmint,$(OS)))
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
	@if command -v ansible > /dev/null; then \
		echo "[ansible]: Already installed"; \
	else \
		echo "[ansible]: Installing..." && \
		$(INSTALL) ansible && \
		echo "[ansible]: Done"; \
	fi

ssh: ## Install my ssh keys
	@if [ -d ~/.ssh ]; then \
		echo '[ssh]: Backing up existing "~/.ssh" to "~/.ssh.backup"' && \
		mv ~/.ssh ~/.ssh.backup; \
	fi
	@echo "[ssh]: Installing my keys..."
	@# Copy my keys
	@cp -r .ssh ~/.ssh
	@# Set correct permissions
	@chmod 700 ~/.ssh
	@chmod 600 ~/.ssh/id_ed25519
	@chmod 644 ~/.ssh/id_ed25519.pub
	@# Decrypt my private key
	@echo "[ssh]: Decrypting my private key..."
	@ansible-vault decrypt ~/.ssh/id_ed25519
	@# Move known_hosts, authorized_keys and config back to ~/.ssh
	@if [ -f ~/.ssh.backup/known_hosts ]; then \
		echo '[ssh]: Restoring "known_hosts" from "~/.ssh.backup"' && \
		mv ~/.ssh.backup/known_hosts ~/.ssh; \
	fi
	@if [ -f ~/.ssh.backup/authorized_keys ]; then \
		echo '[ssh]: Restoring "authorized_keys" from "~/.ssh.backup"' && \
		mv ~/.ssh.backup/authorized_keys ~/.ssh; \
	fi
	@if [ -f ~/.ssh.backup/config ]; then \
		echo '[ssh]: Restoring "config" from "~/.ssh.backup"' && \
		mv ~/.ssh.backup/config ~/.ssh; \
	fi

.PHONY: all help ansible ssh
