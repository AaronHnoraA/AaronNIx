# Variables (override these as needed)
HOSTNAME ?= $(shell hostname)
FLAKE ?= .#$(HOSTNAME)
HOME_TARGET ?= $(FLAKE)
EXPERIMENTAL ?= --extra-experimental-features "nix-command flakes"
USER_TOOLS_UPDATE ?= $(CURDIR)/modules/home-manager/scripts/bin/nix-darwin-update-user-tools

.PHONY: help install-nix install-nix-darwin darwin-rebuild \
	home-manager-switch nix-gc flake-update brew-update user-tools-update \
	user-tools-update-full daily-update controlled-full-update \
	full-update flake-check bootstrap-mac clean git

help:
	@echo "Available targets:"
	@echo "  install-nix          - Install the Nix package manager"
	@echo "  install-nix-darwin   - Install nix-darwin using flake $(FLAKE)"
	@echo "  darwin-rebuild       - Rebuild the nix-darwin configuration"
	@echo "  home-manager-switch  - Switch the Home Manager configuration using flake $(HOME_TARGET)"
	@echo "  nix-gc               - Run Nix garbage collection"
	@echo "  flake-update         - Update all flake inputs"
	@echo "  brew-update          - Update all Homebrew packages"
	@echo "  user-tools-update    - Update npm/cargo/conda user tools"
	@echo "  daily-update         - Alias for full-update"
	@echo "  controlled-full-update - Alias for full-update"
	@echo "  full-update          - Full Homebrew + flake + system + user tools update"
	@echo "  flake-check          - Check the flake for issues"
	@echo "  bootstrap-mac        - Install Nix and nix-darwin sequentially"
	@echo "  clean                - Free space"

install-nix:
	@echo "Installing Nix..."
	@sudo curl -L https://nixos.org/nix/install | sh -s -- --daemon --yes
	@echo "Nix installation complete."

install-nix-darwin:
	@echo "Installing nix-darwin..."
	@sudo nix run nix-darwin $(EXPERIMENTAL) -- switch --flake $(FLAKE)
	@echo "nix-darwin installation complete."

darwin-rebuild:
	@echo "Rebuilding darwin configuration..."
	@sudo darwin-rebuild switch --flake $(FLAKE)
	@echo "Darwin rebuild complete."

home-manager-switch:
	@echo "Switching Home Manager configuration..."
	@home-manager switch --flake ".#Aaron.hc@AaronMac"
	@echo "Home Manager switch complete."

nix-gc:
	@echo "Collecting Nix garbage..."
	@nix-collect-garbage -d
	@echo "Garbage collection complete."

flake-update:
	@echo "Updating all flake inputs..."
	@nix flake update
	@echo "Flake update complete."

brew-update:
	@echo "Running native Homebrew update/upgrade..."
	@brew update
	@brew upgrade
	@brew upgrade --cask

user-tools-update:
	@$(USER_TOOLS_UPDATE) daily

user-tools-update-full:
	@$(USER_TOOLS_UPDATE) full

daily-update: full-update

controlled-full-update: full-update

full-update:
	@$(MAKE) brew-update
	@$(MAKE) flake-update
	@$(MAKE) darwin-rebuild
	@$(MAKE) home-manager-switch
	@$(MAKE) user-tools-update-full

flake-check:
	@echo "Checking flake..."
	@nix flake check
	@echo "Flake check complete."

git:
	@lazygit

clean:
	@echo "Cleaning ..."
	@home-manager expire-generations "-7 days" || true
	@nix profile wipe-history --older-than 7d || true
	@sudo nix-collect-garbage -d
	@sudo nix-store --optimise
	@echo "Clean complete."

bootstrap-mac: install-nix install-nix-darwin
