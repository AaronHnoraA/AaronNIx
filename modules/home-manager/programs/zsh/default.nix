{ pkgs, config, ... }:

{
  # ---------------------------------------------------------------------------
  # 1. Packages
  # ---------------------------------------------------------------------------
  home.packages = with pkgs; [
    nix-index
    pay-respects
    nix-search-cli
  ];

  # ---------------------------------------------------------------------------
  # 2. Clone external Zsh config repository
  # ---------------------------------------------------------------------------
  home.activation.cloneZshConfig = config.lib.dag.entryAfter [ "writeBoundary" ] ''
    TARGET_DIR="$HOME/.config/zsh"
    REPO_URL="http://git.pwo101.top/Config/zsh.git"

    if [ ! -d "$TARGET_DIR" ]; then
      echo "Zsh config not found, cloning from $REPO_URL..."
      $DRY_RUN_CMD ${pkgs.git}/bin/git clone "$REPO_URL" "$TARGET_DIR"
    else
      echo "Zsh config already exists at $TARGET_DIR. Skipping clone."
      # Optional auto-update:
      # $DRY_RUN_CMD ${pkgs.git}/bin/git -C "$TARGET_DIR" pull
    fi
  '';

  # ---------------------------------------------------------------------------
  # 3. Link ~/.config/zsh/my_zshrc to ~/.zshrc
  #
  # Do not use programs.zsh here.
  # programs.zsh.enable = true will make Home Manager generate ~/.zshrc again.
  # ---------------------------------------------------------------------------
  home.activation.linkZshrc = config.lib.dag.entryAfter [ "cloneZshConfig" ] ''
    SOURCE="$HOME/.config/zsh/my_zshrc"
    TARGET="$HOME/.zshrc"

    if [ ! -e "$SOURCE" ]; then
      echo "Warning: $SOURCE does not exist. Cannot link ~/.zshrc."
      exit 0
    fi

    if [ -L "$TARGET" ]; then
      CURRENT_TARGET="$(${pkgs.coreutils}/bin/readlink "$TARGET")"

      if [ "$CURRENT_TARGET" = "$SOURCE" ]; then
        echo "~/.zshrc already links to $SOURCE."
      else
        echo "Replacing existing ~/.zshrc symlink."
        $DRY_RUN_CMD rm "$TARGET"
        $DRY_RUN_CMD ln -s "$SOURCE" "$TARGET"
      fi

    elif [ -e "$TARGET" ]; then
      BACKUP="$TARGET.backup-before-home-manager-link"

      echo "Existing ~/.zshrc found. Backing it up to $BACKUP."
      $DRY_RUN_CMD mv "$TARGET" "$BACKUP"
      $DRY_RUN_CMD ln -s "$SOURCE" "$TARGET"

    else
      echo "Linking $SOURCE to ~/.zshrc."
      $DRY_RUN_CMD ln -s "$SOURCE" "$TARGET"
    fi
  '';

  # ---------------------------------------------------------------------------
  # 4. Minimal ~/.zshenv
  #
  # Keep ~/.zshenv small.
  # Do not put compinit, Oh-My-Zsh, fzf, conda, direnv, starship, atuin here.
  # ---------------------------------------------------------------------------
  home.file.".zshenv".text = ''
    # Nix daemon environment
    if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
      . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
    fi

    # Prefer Nix profile binaries.
    export PATH="$HOME/.nix-profile/bin:/nix/var/nix/profiles/default/bin:$PATH"
  '';

  # ---------------------------------------------------------------------------
  # 5. Session PATH
  # ---------------------------------------------------------------------------
  home.sessionPath = [
    "$HOME/.nix-profile/bin"
    "/nix/var/nix/profiles/default/bin"
  ];
}
