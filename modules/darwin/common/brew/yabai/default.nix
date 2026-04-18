{ pkgs, config, inputs, ... }: {

  # Homebrew 配置
	homebrew = {
		taps = [
			"asmvik/formulae"
		];

		brews = [
			"asmvik/formulae/yabai"
			"asmvik/formulae/skhd"
		];

		casks = [
		];
	};

  # 自动载入 Emacs 配置仓库
  system.activationScripts.cloneYabaiConfig.text = ''
    TARGET_DIR="/Users/$SUDO_USER/.config/yabai"
    REPO_URL="http://git.pwo101.top/Config/yabai.git"

    if [ ! -d "$TARGET_DIR" ]; then
      echo "Emacs config not found, cloning from $REPO_URL..."
      sudo -u "$SUDO_USER" ${pkgs.git}/bin/git clone "$REPO_URL" "$TARGET_DIR"
			mkdir ~/.config/skhd/ 
			ln -sL ~/.config/yabai/skhdrc ~/.config/skhd/skhdrc
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
