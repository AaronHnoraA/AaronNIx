{ config, pkgs, userConfig, ... }:

{

  home.file.".emacs.d" = {
    source = ./.;  # 指向你 Flake 中的 emacs 文件夹
    recursive = true;  # 开启递归链接！
  };
}
