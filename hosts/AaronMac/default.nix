{ darwinModules, ... }:
{
  imports = [
    "${darwinModules}/common"
  ];

  # Used for backwards compatibility, please read the changelog before changing.
  system.stateVersion = 6;
  ids.gids.nixbld = 30000;
}
