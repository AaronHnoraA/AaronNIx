{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  tapName = tap: if builtins.isString tap then tap else tap.name;
  declaredThirdPartyTaps = builtins.filter
    (name: !(lib.hasPrefix "homebrew/" name))
    (map tapName config.homebrew.taps);
  declaredThirdPartyTapArgs = lib.escapeShellArgs declaredThirdPartyTaps;
  brewUpgrade = pkgs.writeShellScript "brew-upgrade-all" ''
    set -euo pipefail
    export HOMEBREW_REQUIRE_TAP_TRUST=1

    brew update
    brew upgrade
    brew upgrade --cask
  '';
in
{
  imports = [
    inputs.nix-homebrew.darwinModules.nix-homebrew
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
        "keith/formulae"
        "homebrew-zathura/zathura"
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
        "jupyterlab"
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
        "opencode"
        "openconnect"
        "openssl@3"
        "pandoc"
        "pkgconf"
        "pngpaste"
        "pv"
        "python@3.14"
        "python-lsp-server"
        "pyright"
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
        "homebrew-zathura/zathura/zathura-pdf-mupdf"
        "homebrew-zathura/zathura/zathura-pdf-poppler"
        "zoxide"
        "zsh"
        "zsh-syntax-highlighting"
        "keith/formulae/reminders-cli"
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

    # Homebrew 6 requires explicit trust before loading third-party Ruby tap
    # definitions. Trust every already-installed tap automatically, plus taps
    # declared by Nix that may not have been installed yet. No duplicate trust
    # list needs to be maintained.
    system.activationScripts.preActivation.text = lib.mkAfter ''
      if [ -x "${config.homebrew.prefix}/bin/brew" ]; then
        echo "Trusting installed and Nix-declared Homebrew taps..."

        while IFS= read -r tap; do
          [ -n "$tap" ] || continue
          sudo \
            --preserve-env=PATH \
            --user=${lib.escapeShellArg config.homebrew.user} \
            --set-home \
            env \
              PATH="${config.homebrew.prefix}/bin:$PATH" \
              HOMEBREW_NO_AUTO_UPDATE=1 \
              brew trust --tap "$tap"
        done < <(
          sudo \
            --preserve-env=PATH \
            --user=${lib.escapeShellArg config.homebrew.user} \
            --set-home \
            env \
              PATH="${config.homebrew.prefix}/bin:$PATH" \
              HOMEBREW_NO_AUTO_UPDATE=1 \
              brew tap
        )

        sudo \
          --preserve-env=PATH \
          --user=${lib.escapeShellArg config.homebrew.user} \
          --set-home \
          env \
            PATH="${config.homebrew.prefix}/bin:$PATH" \
            HOMEBREW_NO_AUTO_UPDATE=1 \
            brew trust --tap ${declaredThirdPartyTapArgs}
      fi

      # This export remains active for nix-darwin's later `brew bundle` step.
      export HOMEBREW_REQUIRE_TAP_TRUST=1
    '';

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
            HOMEBREW_REQUIRE_TAP_TRUST=1 \
            ${brewUpgrade}
      else
        echo "Homebrew is not installed, skipping Homebrew upgrade."
      fi
    '';
  };
}
