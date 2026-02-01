{ config, pkgs, ... }:

{
  # 确保系统里有 git
  home.packages = [ pkgs.git ];

  home.activation.setupEmacs = config.lib.dag.entryAfter ["writeBoundary"] ''
    TARGET="$HOME/.emacs.d"
    REPO_URL="http://git.pwo101.top/Config/Emacs.git"

    if [ ! -d "$TARGET" ]; then
      # 如果目录不存在，直接 clone
      ${pkgs.git}/bin/git clone "$REPO_URL" "$TARGET"
    else
      # 如果已经存在，你可以选择自动 pull 最新的，或者干脆跳过
      echo "Emacs config already exists at $TARGET, skipping clone."
      # 想自动更新可以取消下面这行的注释：
      # cd "$TARGET" && ${pkgs.git}/bin/git pull
    fi
  '';
}
