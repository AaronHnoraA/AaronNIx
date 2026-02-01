{ lib, pkgs, ... }:
{
  config = lib.mkIf pkgs.stdenv.isDarwin {
    home.packages = [ 
      pkgs.kitty 
    ];

    # 3. 配置 kitty
    # 将当前目录下的 ./kitty 文件夹链接到 ~/.config/kitty
    xdg.configFile.kitty = {
      source = ./kitty;
      recursive = true; # 递归链接内部文件，方便后续混合管理或避免目录被只读锁定
    };
  };
}
