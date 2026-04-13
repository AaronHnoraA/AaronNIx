
{ pkgs, config, ... }:
{
  # 1. 安装需要的包
  home.packages = with pkgs; [
    zsh-powerlevel10k eza bat fzf zoxide pay-respects fastfetch fortune
    nix-index
    nix-search-cli
  ];

  # 2. 把你的配置文件链接到 ~/.config/zsh/my_zshrc
  xdg.configFile."zsh/my_zshrc".source = ./zshrc; 

  # 自动载入 Emacs 配置仓库
  system.activationScripts.cloneZshConfig.text = ''
    TARGET_DIR="/Users/$SUDO_USER/.config/emacs"
    REPO_URL="http://git.pwo101.top/Config/zsh.git"

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

  # 3. 配置 zsh
  programs.zsh = {
    enable = true;
    
    # 使用 initExtra 而不是 initContent
    initContent = ''
      # 加载你的自定义配置
      source ~/.config/zsh/my_zshrc
      # 强制将 Nix profile 路径放在 PATH 最前面
      # 这会在所有其他初始化之后执行，覆盖 path_helper 的设置
      export PATH="$HOME/.nix-profile/bin:/nix/var/nix/profiles/default/bin:$PATH"
      # 移除重复的路径条目
      # >>> conda initialize >>>
      # !! Contents within this block are managed by 'conda init' !!
          __conda_setup="$('/opt/homebrew/anaconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
          if [ $? -eq 0 ]; then
              eval "$__conda_setup"
          else
              if [ -f "/opt/homebrew/anaconda3/etc/profile.d/conda.sh" ]; then
                  . "/opt/homebrew/anaconda3/etc/profile.d/conda.sh"
              else
                  export PATH="/opt/homebrew/anaconda3/bin:$PATH"
              fi
          fi
          unset __conda_setup
          export CONDA_PREFIX="/opt/homebrew/anaconda3/envs/"
      # <<< conda initialize <<<
      typeset -U PATH
    '';
  };
  
  # 或者使用 home.sessionPath（但在 macOS 上可能被 path_helper 覆盖）
  home.sessionPath = [
     "$HOME/.nix-profile/bin"
     "/nix/var/nix/profiles/default/bin"
   ];
  home.file.".zshenv".text = ''
    # Nix
    if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
      . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
    fi
    # 强制优先使用 Nix 的 PATH
    export PATH="$HOME/.nix-profile/bin:/nix/var/nix/profiles/default/bin:$PATH"
  '';
}
