{ pkgs, ... }:
{
  # Neovim text editor configuration
  programs.neovim = {
    enable = true;
    package = pkgs.neovim-unwrapped;
    defaultEditor = true;
    withNodeJs = true;
    withPython3 = true;
    withRuby = true;

    extraPackages = with pkgs; [
      black
      golangci-lint
      gopls
      gotools
      hadolint
      isort
      lua-language-server
      markdownlint-cli
      nixd
      nixfmt
      nodePackages.bash-language-server
      nodePackages.prettier
      pyright
      ruff
      shellcheck
      shfmt
      stylua
      terraform-ls
      tflint
      tree-sitter
      vscode-langservers-extracted
      yaml-language-server
    ];
  };

  home.activation.cloneEmacsConfig = config.lib.dag.entryAfter ["writeBoundary"] ''
    # 定义目标目录 (注意：XDG 标准是 ~/.config/emacs)
    TARGET_DIR="$HOME/.config/nvim"
    REPO_URL="http://git.pwo101.top/Config/Nvim.git"

    # 检查目录是否存在
    if [ ! -d "$TARGET_DIR" ]; then
      echo "Emacs config not found, cloning from $REPO_URL..."
      # 使用 $DRY_RUN_CMD 确保在 home-manager build --dry-run 时不执行
      $DRY_RUN_CMD ${pkgs.git}/bin/git clone "$REPO_URL" "$TARGET_DIR"
    else
      echo "Emacs config already exists at $TARGET_DIR. Skipping clone."
      # 可选：如果你希望每次 switch 都自动 pull 更新，可以解开下面注释
      # echo "Updating Emacs config..."
      #$DRY_RUN_CMD cd "$TARGET_DIR" && ${pkgs.git}/bin/git pull
    fi
  '';
}


