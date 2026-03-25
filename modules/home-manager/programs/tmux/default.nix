{ lib, pkgs, ... }:
{
  config = lib.mkIf pkgs.stdenv.isDarwin {
    home.packages = [ 
      pkgs.tmux
    ];

    # 3. 配置 kitty
    xdg.configFile.tmux = {
      source = ./tmux;
      recursive = true; # 递归链接内部文件，方便后续混合管理或避免目录被只读锁定
    };
  };
}
