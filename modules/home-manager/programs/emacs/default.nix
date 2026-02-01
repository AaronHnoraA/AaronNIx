{ config, pkgs, ... }:

{
  # 确保系统里有 git
  home.packages = [ pkgs.git ];

  home.activation.setupEmacs = config.lib.dag.entryAfter ["writeBoundary"] ''
    TARGET="$HOME/.emacs.d"
    REPO_URL="http://git.pwo101.top/Config/Emacs.git"

    if [ ! -d "$TARGET" ]; then
      ${pkgs.git}/bin/git clone "$REPO_URL" "$TARGET"
    else
      echo "Emacs config already exists at $TARGET, skipping clone."
      cd "$TARGET" && ${pkgs.git}/bin/git pull
    fi
  '';
}
