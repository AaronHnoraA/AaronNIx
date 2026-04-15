{ config, lib, pkgs, ... }:
{
  config = lib.mkIf pkgs.stdenv.isDarwin {
    home.packages = [ 
      pkgs.tmux
    ];

    xdg.configFile.tmux = {
      source = ./tmux;
      recursive = true;
      force = true;
    };

    home.file.".tmux" = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.xdg.configHome}/tmux";
      force = true;
    };

    home.file.".tmux.conf" = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.xdg.configHome}/tmux/tmux.conf";
      force = true;
    };
  };
}
