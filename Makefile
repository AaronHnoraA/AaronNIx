# Variables (override these as needed)
HOSTNAME ?= $(shell hostname)
FLAKE ?= .#$(HOSTNAME)
HOME_TARGET ?= $(FLAKE)
EXPERIMENTAL ?= --extra-experimental-features "nix-command flakes"

# Update allowlists. Keep sensitive inputs out of the default lists, and update
# them only through explicit protected targets below.
APPROVED_NIX_INPUTS ?= nixpkgs nixpkgs-stable home-manager hardware catppuccin noctalia darwin nix-homebrew homebrew-core homebrew-cask
PROTECTED_NIX_INPUTS ?= emacs-overlay
BREW_UPGRADE_PROTECTED ?= /run/current-system/sw/bin/brew-upgrade-protected
USER_TOOLS_UPDATE ?= $(CURDIR)/modules/home-manager/scripts/bin/nix-darwin-update-user-tools

.PHONY: help install-nix install-nix-darwin darwin-rebuild nixos-rebuild \
	home-manager-switch nix-gc flake-update flake-update-protected \
	flake-update-emacs brew-update brew-update-protected brew-update-emacs \
	user-tools-update user-tools-update-full daily-update \
	controlled-full-update full-update flake-check bootstrap-mac

help:
	@echo "Available targets:"
	@echo "  install-nix          - Install the Nix package manager"
	@echo "  install-nix-darwin   - Install nix-darwin using flake $(FLAKE)"
	@echo "  darwin-rebuild       - Rebuild the nix-darwin configuration"
	@echo "  nixos-rebuild        - Rebuild the NixOS configuration"
	@echo "  home-manager-switch  - Switch the Home Manager configuration using flake $(HOME_TARGET)"
	@echo "  nix-gc               - Run Nix garbage collection"
	@echo "  flake-update         - Update approved flake inputs"
	@echo "  flake-update-protected - Update protected flake inputs"
	@echo "  flake-update-emacs   - Alias for flake-update-protected"
	@echo "  brew-update          - Update all Homebrew packages except protected items"
	@echo "  brew-update-protected - Update protected Homebrew items"
	@echo "  brew-update-emacs    - Alias for brew-update-protected"
	@echo "  user-tools-update    - Update npm/cargo/conda user tools"
	@echo "  daily-update         - Controlled brew + user tools + darwin + home"
	@echo "  controlled-full-update - Approved flake update + daily update"
	@echo "  full-update          - Native full update without protection"
	@echo "  flake-check          - Check the flake for issues"
	@echo "  bootstrap-mac        - Install Nix and nix-darwin sequentially"
	@echo "  clean        - Free space"

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

nixos-rebuild:
	@echo "Rebuilding NixOS configuration..."
	@sudo nixos-rebuild switch --flake $(FLAKE)
	@echo "NixOS rebuild complete."

home-manager-switch:
	@echo "Switching Home Manager configuration..."
	@home-manager switch --flake ".#Aaron.hc@AaronMac"
	@echo "Home Manager switch complete."

nix-gc:
	@echo "Collecting Nix garbage..."
	@nix-collect-garbage -d
	@echo "Garbage collection complete."

flake-update:
	@echo "Updating approved flake inputs: $(APPROVED_NIX_INPUTS)"
	@nix flake update $(APPROVED_NIX_INPUTS)
	@echo "Approved flake update complete."

flake-update-protected:
	@echo "Updating protected flake inputs: $(PROTECTED_NIX_INPUTS)"
	@nix flake update $(PROTECTED_NIX_INPUTS)
	@echo "Protected flake update complete."

flake-update-emacs: flake-update-protected

brew-update:
	@$(MAKE) darwin-rebuild

brew-update-protected:
	@if [ ! -x "$(BREW_UPGRADE_PROTECTED)" ]; then $(MAKE) darwin-rebuild; fi
	@$(BREW_UPGRADE_PROTECTED)

brew-update-emacs: brew-update-protected

user-tools-update:
	@$(USER_TOOLS_UPDATE) daily

user-tools-update-full:
	@$(USER_TOOLS_UPDATE) full

daily-update:
	@$(MAKE) darwin-rebuild
	@$(MAKE) home-manager-switch
	@$(MAKE) user-tools-update

controlled-full-update:
	@$(MAKE) flake-update
	@$(MAKE) daily-update

full-update:
	@echo "Running native Homebrew update/upgrade without protected skips..."
	@brew update
	@brew upgrade
	@brew upgrade --cask
	@echo "Updating all flake inputs..."
	@nix flake update
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
