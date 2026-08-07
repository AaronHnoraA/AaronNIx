{
  config,
  lib,
  pkgs,
  ...
}:
let
  user = config.system.primaryUser;
  home = config.users.users.${user}.home;
  targetDir = "${home}/.config/emacs";
  repoUrl = "https://github.com/AaronHnoraA/AaronEmacs.git";
in
{
  homebrew = {
    casks = [
      "emacs-app"
    ];
  };

  system.activationScripts.cloneEmacsConfig.text = ''
    target_dir=${lib.escapeShellArg targetDir}
    repo_url=${lib.escapeShellArg repoUrl}

    if [ ! -e "$target_dir" ]; then
      echo "Emacs config not found, cloning from $repo_url..."
      sudo \
        --user=${lib.escapeShellArg user} \
        --set-home \
        ${pkgs.git}/bin/git clone "$repo_url" "$target_dir"
    else
      echo "Emacs config already exists at $target_dir. Skipping clone."
    fi
  '';
}
