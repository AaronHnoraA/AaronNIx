{ lib, pkgs, ... }:
{
  config = lib.mkIf pkgs.stdenv.isDarwin {
    # 安装 aerospace
    home.packages = [ pkgs.aerospace ];

    # 用当前目录里的 aerospace.toml 作为配置
    home.file.".aerospace.toml".source = ./aerospace.toml;
  };
}
