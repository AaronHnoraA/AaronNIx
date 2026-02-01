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
  xdg.configFile = {
    "emacs" = {
      source = ./emacs; # 确保你的 flake 目录下有 emacs 文件夹
      recursive = true; # 递归链接，防止只链接目录导致只读问题
    };
  };

  # 必要的外部依赖
  home.packages = with pkgs; [ 
    git 
    ripgrep 
    fd 
    cmake   # vterm 编译通常需要
    libtool # 某些 native 模块编译需要
    pngpaste # Mac 上粘贴图片必备
  ];
}
