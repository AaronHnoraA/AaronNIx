{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  brewUpgrade = pkgs.writeShellScript "brew-upgrade-all" ''
    set -euo pipefail

    brew update
    brew upgrade
    brew upgrade --cask
  '';
in
{
  imports = [
    inputs.nix-homebrew.darwinModules.nix-homebrew
    ./conda
    ./emacs
    ./mactex
    ./yabai
  ];

  config = {
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
        # Brewfile installs stay declarative. Upgrades are handled by the
        # post-activation script so unmanaged Homebrew packages are updated too.
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
        "deno"
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
        "anaconda"
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
      echo "Running full Homebrew update/upgrade..."

      if [ -x "${config.homebrew.prefix}/bin/brew" ]; then
        sudo \
          --preserve-env=PATH \
          --user=${lib.escapeShellArg config.homebrew.user} \
          --set-home \
          env \
            PATH="${config.homebrew.prefix}/bin:${lib.makeBinPath [ pkgs.mas ]}:$PATH" \
            HOMEBREW_NO_AUTO_UPDATE=1 \
            ${brewUpgrade}
      else
        echo "Homebrew is not installed, skipping Homebrew upgrade."
      fi
    '';
  };
}
