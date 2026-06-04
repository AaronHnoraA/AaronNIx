# Nix Configuration

This is my personal Nix configuration repository. The active focus is my macOS workstation and Home Manager user environment, with some NixOS/Linux configuration kept for reference and continuity.

The repository is built around flakes, nix-darwin, Home Manager, and Homebrew. Its goal is to keep system settings, command-line tools, GUI applications, editor-related tooling, custom scripts, and update workflows in one place.

This is not intended to be a drop-in configuration for other machines. It contains my usernames, hostnames, Homebrew choices, Dock layout, editor preferences, paths, and local scripts.

## Targets

- `AaronMac`: current main macOS machine, managed with nix-darwin.
- `Aaron.hc@AaronMac`: Home Manager environment for the macOS machine.
- `energy`: retained NixOS host configuration, mainly kept as Linux configuration history.
- `home/nabokikh/energy`: retained Linux Home Manager configuration.

## What This Manages

- macOS system defaults, Finder, Dock, keyboard behavior, trackpad settings, screenshots, fonts, and Touch ID for sudo.
- Homebrew taps, formulae, casks, and full upgrade behavior.
- Home Manager programs such as kitty, atuin, bat, btop, fzf, Git, GPG, lazygit, Neovim, starship, tmux, and zsh.
- Shared CLI packages and local scripts under `modules/home-manager/scripts/bin`.
- Full update workflows for Homebrew, flakes, nix-darwin, Home Manager, and user-level tools.
- Retained NixOS and Linux desktop configuration used by earlier or secondary setups.

## Repository Layout

```text
flake.nix          Flake inputs and outputs
flake.lock         Locked dependency graph
Makefile           Local command entrypoint
hosts/             Host-level system configurations
home/              Home Manager user entries
modules/darwin/    macOS and nix-darwin modules
modules/home-manager/
                   User environment, program modules, and scripts
modules/nixos/     NixOS modules
overlays/          Custom overlays
files/             Static assets such as wallpaper and avatar
docs/              Additional documentation
```

## Common Commands

Install Nix and nix-darwin on macOS:

```sh
make install-nix
make install-nix-darwin
```

Apply the macOS system configuration and Home Manager configuration:

```sh
make darwin-rebuild
make home-manager-switch
```

Run the full update flow:

```sh
make full-update
```

Compatibility aliases for the same full update flow:

```sh
make daily-update
make controlled-full-update
```

Check the flake:

```sh
make flake-check
```

Clean old generations and optimize the Nix store:

```sh
make clean
```

## Global Command

Home Manager exposes a helper command at:

```text
~/.local/bin/nix-darwin
```

It assumes this repository lives at:

```text
~/.nixpkgs
```

If the repository moves, set:

```sh
export NIX_DARWIN_CONFIG=/path/to/config
```

Examples:

```sh
nix-darwin daily
nix-darwin controlled-full
nix-darwin full
```

All three update commands dispatch to `make full-update`.

## Update Strategy

There is no protected Emacs update path anymore. `full-update` performs:

- native Homebrew update and upgrade for formulae and casks
- full `nix flake update`
- nix-darwin rebuild
- Home Manager switch
- full user-tool update mode

The update flow does not run Neovim plugin updates. Neovim plugins are managed from inside Neovim when needed.

See [docs/nix-darwin-update.md](./docs/nix-darwin-update.md) for the full update policy.

## Homebrew

Homebrew remains the source of truth for macOS GUI applications and some CLI tools. The main Homebrew module is:

```text
modules/darwin/common/brew/default.nix
```

It declares taps, formulae, casks, and the Homebrew upgrade script used during nix-darwin activation.

## Home Manager

The shared Home Manager environment starts at:

```text
modules/home-manager/common/default.nix
```

It imports the program modules and links scripts from:

```text
modules/home-manager/scripts/bin
```

This is where most user-level tools and shell workflow customizations are assembled.

## Notes

This repository is optimized for my own machines and workflow. It may be useful as a reference for organizing a pragmatic nix-darwin setup, but reuse requires changing usernames, hostnames, Homebrew applications, paths, and personal scripts.

## License

MIT. See [LICENSE](./LICENSE).
