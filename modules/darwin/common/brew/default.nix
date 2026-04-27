{ config, inputs, ... }: {
  imports = [
    inputs.nix-homebrew.darwinModules.nix-homebrew
    ./conda
    ./mactex
    ./emacs
    ./yabai
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
      autoUpdate = true;
      upgrade = true;
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
}
