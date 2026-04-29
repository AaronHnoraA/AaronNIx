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
- Homebrew taps, formulae, casks, and controlled upgrade behavior.
- Home Manager programs such as kitty, atuin, bat, btop, fzf, Git, GPG, lazygit, Neovim, starship, tmux, and zsh.
- Shared CLI packages and local scripts under `modules/home-manager/scripts/bin`.
- Update workflows that separate routine updates from high-risk updates such as Emacs.
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

Run the daily controlled update flow:

```sh
make daily-update
```

Update approved flake inputs, then run the daily flow:

```sh
make controlled-full-update
```

Run a full native update without protected skips:

```sh
make full-update
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
nix-darwin brew-update-emacs
```

The helper command dispatches to the corresponding `Makefile` targets.

## Update Strategy

Routine updates and high-risk updates are intentionally separated.

`daily-update` rebuilds nix-darwin, switches Home Manager, runs controlled Homebrew updates, and updates user-level tools such as npm, Cargo, and Conda. Controlled Homebrew updates skip protected items.

The default protected Homebrew cask is:

```nix
local.homebrew.protectedCasks = [
  "emacs-plus-app@master"
];
```

Protected Homebrew items can still be updated explicitly:

```sh
nix-darwin brew-update-protected
nix-darwin brew-update-emacs
```

The protected flake input is:

```make
PROTECTED_NIX_INPUTS = emacs-overlay
```

See [docs/nix-darwin-update.md](./docs/nix-darwin-update.md) for the full update policy.

## Homebrew

Homebrew remains the source of truth for macOS GUI applications and some CLI tools. The main Homebrew module is:

```text
modules/darwin/common/brew/default.nix
```

It declares taps, formulae, casks, protected packages, and the controlled upgrade script used during nix-darwin activation.

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
