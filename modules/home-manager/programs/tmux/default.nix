{ config, lib, pkgs, ... }:
{
  config = lib.mkIf pkgs.stdenv.isDarwin {
    home.packages = [ 
      pkgs.tmux
    ];

    xdg.configFile.tmux = {
      source = ./tmux;
      recursive = true;
    };

    home.file.".tmux.conf".source =
      config.lib.file.mkOutOfStoreSymlink "${config.xdg.configHome}/tmux/tmux.conf";

    home.file.".tmux.conf.local".source =
      config.lib.file.mkOutOfStoreSymlink "${config.xdg.configHome}/tmux/tmux.conf.local";
  };
}
