{ pkgs, config, inputs, ... }: {

  # Homebrew 配置
  homebrew = {
    taps = [
      "d12frosted/emacs-plus"
    ];

    brews = [
    ];

    casks = [
      "anaconda"
      "emacs-plus-app@master"
    ];
  };

  # 自动载入 Emacs 配置仓库
  system.activationScripts.cloneEmacsConfig.text = ''
    TARGET_DIR="/Users/$SUDO_USER/.config/emacs"
    REPO_URL="http://git.pwo101.top/Config/Emacs.git"

    if [ ! -d "$TARGET_DIR" ]; then
      echo "Emacs config not found, cloning from $REPO_URL..."
      sudo -u "$SUDO_USER" ${pkgs.git}/bin/git clone "$REPO_URL" "$TARGET_DIR"
    else
      echo "Emacs config already exists at $TARGET_DIR. Skipping clone."
      # 如果你想每次 switch 自动 pull，可以改成：
      # echo "Updating Emacs config..."
      # sudo -u "$SUDO_USER" sh -c 'cd "$TARGET_DIR" && ${pkgs.git}/bin/git pull'
    fi
  '';

  # 你原来的 postActivation
  system.activationScripts.postActivation.text = ''
    echo "Setting up conda environments..."

    if [ -f "/opt/homebrew/anaconda3/bin/conda" ]; then
      echo "Conda setup complete"
    fi
  '';
}
