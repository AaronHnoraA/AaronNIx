{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.local.homebrew;

  controlledBrewUpgrade = pkgs.writeShellScript "brew-upgrade-controlled" ''
    set -euo pipefail

    protected_formulae=(${lib.escapeShellArgs cfg.protectedFormulae})
    protected_casks=(${lib.escapeShellArgs cfg.protectedCasks})

    is_protected() {
      local needle="$1"
      shift

      local item
      for item in "$@"; do
        if [ "$needle" = "$item" ]; then
          return 0
        fi
      done

      return 1
    }

    brew update

    while IFS= read -r item; do
      [ -n "$item" ] || continue

      if is_protected "$item" "''${protected_formulae[@]}"; then
        echo "Skipping protected Homebrew formula: $item"
        continue
      fi

      brew upgrade "$item"
    done < <(brew outdated --formula --quiet || true)

    while IFS= read -r item; do
      [ -n "$item" ] || continue

      if is_protected "$item" "''${protected_casks[@]}"; then
        echo "Skipping protected Homebrew cask: $item"
        continue
      fi

      brew upgrade --cask "$item"
    done < <(brew outdated --cask --quiet || true)

    ${lib.optionalString ((cfg.protectedFormulae ++ cfg.protectedCasks) != [ ]) ''
      echo "Protected Homebrew items skipped by controlled upgrade: ${lib.escapeShellArgs (cfg.protectedFormulae ++ cfg.protectedCasks)}"
    ''}
  '';

  protectedBrewUpgrade = pkgs.writeShellScriptBin "brew-upgrade-protected" ''
    set -euo pipefail

    protected_formulae=(${lib.escapeShellArgs cfg.protectedFormulae})
    protected_casks=(${lib.escapeShellArgs cfg.protectedCasks})

    brew update

    for item in "''${protected_formulae[@]}"; do
      [ -n "$item" ] || continue
      if brew list --formula "$item" >/dev/null 2>&1; then
        brew upgrade "$item"
      else
        echo "Skipping uninstalled protected Homebrew formula: $item"
      fi
    done

    for item in "''${protected_casks[@]}"; do
      [ -n "$item" ] || continue
      if brew list --cask "$item" >/dev/null 2>&1; then
        brew upgrade --cask "$item"
      else
        echo "Skipping uninstalled protected Homebrew cask: $item"
      fi
    done
  '';
in
{
  imports = [
    inputs.nix-homebrew.darwinModules.nix-homebrew
    ./conda
    ./mactex
    ./emacs
    ./yabai
  ];

  options.local.homebrew = {
    protectedFormulae = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Homebrew formulae skipped by the automatic controlled upgrade.";
    };

    protectedCasks = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "emacs-plus-app@master"
      ];
      description = "Homebrew casks skipped by the automatic controlled upgrade.";
    };
  };

  config = {
    environment.systemPackages = [
      protectedBrewUpgrade
    ];

    nix-homebrew = {
      enable = true;
      enableRosetta = true;
      user = config.system.primaryUser;
      autoMigrate = true;
      mutableTaps = true;
    };

    homebrew = {
      enable = true;
      onActivation = {
        # Brewfile installs stay declarative. Upgrades are handled below so the
        # protected lists can be skipped while unmanaged Homebrew packages are
        # still updated.
        autoUpdate = false;
        upgrade = false;
        cleanup = "none";
      };

      taps = [
        "homebrew/services"
        "felixkratz/formulae"
        "zegervdv/zathura"
      ];
      brews = [
        "aria2"
        "bat"
        "bash-completion"
        "bitwarden-cli"
        "cmake"
        "direnv"
        "entr"
        "eza"
        "fastfetch"
        "fd"
        "felixkratz/formulae/borders"
        "fzf"
        "fortune"
        "git-delta"
        "gnu-sed"
        "go"
        "gum"
        "highlight"
        "htop"
        "httpie"
        "jq"
        "jupytext"
        "lazygit"
        "llvm"
        "m-cli"
        "media-info"
        "mkcert"
        "mosh"
        "navi"
        "ncdu"
        "neovim"
        "node"
        "ocrmypdf"
        "openconnect"
        "openssl@3"
        "pandoc"
        "pkgconf"
        "pngpaste"
        "pv"
        "python@3.14"
        "ripgrep"
        "rust"
        "rust-analyzer"
        "rustup"
        "sevenzip"
        "smartmontools"
        "speedtest-cli"
        "telnet"
        "tesseract-lang"
        "thefuck"
        "tmux"
        "trash"
        "tree"
        "typst"
        "vips"
        "wakeonlan"
        "watch"
        "wget"
        "yazi"
        "zegervdv/zathura/zathura-pdf-mupdf"
        "zegervdv/zathura/zathura-pdf-poppler"
        "zoxide"
        "zsh"
        "zsh-syntax-highlighting"
      ];
      casks = [
        "android-platform-tools"
        "cc-switch"
        "font-hack-nerd-font"
        "font-jetbrains-mono-nerd-font"
        "font-stix-two-math"
        "font-symbols-only-nerd-font"
        "goldendict"
        "homerow"
        "karabiner-elements"
        "kitty"
        "lulu"
        "obsidian"
        "qlstephen"
        "raycast"
        "sioyek"
        "vagrant"
        "zerotier-one"
      ];
    };

    system.activationScripts.postActivation.text = lib.mkAfter ''
      echo "Running Homebrew update/upgrade, excluding protected items..."

      if [ -x "${config.homebrew.prefix}/bin/brew" ]; then
        sudo \
          --preserve-env=PATH \
          --user=${lib.escapeShellArg config.homebrew.user} \
          --set-home \
          env \
            PATH="${config.homebrew.prefix}/bin:${lib.makeBinPath [ pkgs.mas ]}:$PATH" \
            HOMEBREW_NO_AUTO_UPDATE=1 \
            ${controlledBrewUpgrade}
      else
        echo "Homebrew is not installed, skipping controlled upgrade."
      fi
    '';
  };
}
