{ ... }:
{
  # kitty is managed outside Nix/Home Manager on macOS.
  xdg.configFile = {
    "kitty" = {
      source = ./kitty;
      recursive = true;
    };
  };
}
