{ config, pkgs, lib, ... }:

{
  programs.emacs = {
    enable = true;

    # 核心修改：使用 override 开启特性
    # 推荐使用 emacs29 或更高版本，native-comp 支持更成熟
    package = pkgs.emacs30.override {
      withNativeCompilation = true; # 开启 Native Compilation (JIT)
      withXwidgets = true;          # 开启 xwidgets (WebKit 支持)
    };

    # 这里是你原来的配置
    extraPackages = epkgs: [
      epkgs.vterm # 强烈推荐在 Mac 上安装 vterm，性能比 shell 好很多
      epkgs.treesit-grammars.with-all-grammars # 如果用 Emacs 29+，这是内置 treesitter 必备
    ];
  };

  xdg.configFile = {
    "emacs" = {
      source = ./emacs;
      recursive = true;
    };
  };

  # 补充依赖：
  # 1. libtool/cmake/gcc: 编译 native-comp 需要
  # 2. pngpaste: 在 Mac 上实现从剪贴板粘贴图片到 org-mode
  home.packages = with pkgs; [
    git
    ripgrep
    fd
    binutils       # native-comp 编译需要
    cmake          # vterm 编译需要
    libtool        # libtool
    pngpaste       # Mac 专属：支持粘贴图片
  ];
}
