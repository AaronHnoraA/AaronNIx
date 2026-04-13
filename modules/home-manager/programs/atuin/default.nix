{ ... }:
{
  # Install atuin via home-manager module
	programs.atuin = {
    enable = true;
    flags = [ "--disable-up-arrow" ];

    settings = {
      inline_height = 25;
      invert = true;
      search_mode = "skim";
      secrets_filter = true;
      style = "compact";
      sync_address = "https://atuin.pwo101.top";

      sync = {
        records = true;
      };
    };
  };
}
