{ config, pkgs, ... }:
{
  home.activation.cloneNvimConfig = config.lib.dag.entryAfter ["writeBoundary"] ''
    # 定义 Neovim 配置目录
    TARGET_DIR="$HOME/.config/nvim"
    REPO_URL="http://git.pwo101.top/Config/Nvim.git"

    # 检查目录是否存在
    if [ ! -d "$TARGET_DIR" ]; then
      echo "Neovim config not found, cloning from $REPO_URL..."
      # 使用 $DRY_RUN_CMD 确保在 home-manager build --dry-run 时不执行
      $DRY_RUN_CMD ${pkgs.git}/bin/git clone "$REPO_URL" "$TARGET_DIR"
    else
      echo "Neovim config already exists at $TARGET_DIR. Updating if it is a git checkout."
      if [ -d "$TARGET_DIR/.git" ]; then
        $DRY_RUN_CMD ${pkgs.git}/bin/git -C "$TARGET_DIR" pull --ff-only
      fi
      # 可选：如果你希望每次 switch 都自动 pull 更新，可以解开下面注释
      # echo "Updating Neovim config..."
      #$DRY_RUN_CMD cd "$TARGET_DIR" && ${pkgs.git}/bin/git pull
    fi
  '';

  home.packages = with pkgs; [ 
    git 
    ripgrep 
    fd 
    fzf
    cmake   # vterm 编译通常需要
    libtool # 某些 native 模块编译需要
    pngpaste # Mac 上粘贴图片必备
    clang
    vscode-langservers-extracted
  ];
}


