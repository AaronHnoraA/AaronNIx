{ config, pkgs, ... }:

{
  programs.emacs = {
    enable = true;
    
    # 使用 emacs-git (对应 emacs-plus --HEAD)
    # Overlay 里的 emacs-git 默认已开启 native-comp
    package = pkgs.emacs-git.override { 
      withXwidgets = true; # 显式开启 xwidgets 支持
    };

    # 可选：在这个 block 里安装一些基础包，
    # 但由于你下面使用了 config linking，通常由 Doom/Spacemacs 内部管理包
    extraPackages = epkgs: [ epkgs.vterm ]; 
  };

  # 链接你的配置文件
  home.activation.cloneEmacsConfig = config.lib.dag.entryAfter ["writeBoundary"] ''
    # 定义目标目录 (注意：XDG 标准是 ~/.config/emacs)
    TARGET_DIR="$HOME/.config/emacs"
    REPO_URL="http://git.nas/Config/Emacs.git"

    # 检查目录是否存在
    if [ ! -d "$TARGET_DIR" ]; then
      echo "Emacs config not found, cloning from $REPO_URL..."
      # 使用 $DRY_RUN_CMD 确保在 home-manager build --dry-run 时不执行
      $DRY_RUN_CMD ${pkgs.git}/bin/git clone "$REPO_URL" "$TARGET_DIR"
    else
      echo "Emacs config already exists at $TARGET_DIR. Skipping clone."
      # 可选：如果你希望每次 switch 都自动 pull 更新，可以解开下面注释
      # echo "Updating Emacs config..."
      #$DRY_RUN_CMD cd "$TARGET_DIR" && ${pkgs.git}/bin/git pull
    fi
  '';

  # 必要的外部依赖
  home.packages = with pkgs; [ 
    git 
    ripgrep 
    fd 
    fzf
    cmake   # vterm 编译通常需要
    libtool # 某些 native 模块编译需要
    pngpaste # Mac 上粘贴图片必备
    clang
  ];
}
