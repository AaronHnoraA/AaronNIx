
{ pkgs, lib, config, ... }:

{
  # 1. 安装必要的包（fzf, zoxide, eza, etc.）
  home.packages = with pkgs; [
    zsh-powerlevel10k
    eza
    bat
    fzf
    zoxide
    thefuck
    fastfetch
    fortune
    # 如果你在 macOS 上，brew 装过的 gcc/llvm 可以不在这里装
    # 但建议尽量用 nix 里的包，比如:
    # cmake
    # ninja
  ];

  # 2. 如果你有现成的 .p10k.zsh，把它放当前目录并引用
  # 也可以直接把 .p10k.zsh 内容贴在 initExtra 里，但那样太长了
  home.file.".p10k.zsh".source = ./p10k.zsh;

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    # 3. Oh My Zsh 配置
    oh-my-zsh = {
      enable = true;
      theme = "robbyrussell"; # 后面会被 p10k 覆盖，这里随便填一个或者不填
      plugins = [
        "git"
        "github"
        "sudo"
        "vscode"
        "z"
        "command-not-found"
        "colored-man-pages"
        "vi-mode"
        "extract"
        "cp"
        "per-directory-history"
        "safe-paste"
        "history-substring-search"
      ];
    };

    # 4. 别名 (Aliases)
    shellAliases = {
      # 常用
      ff = "fastfetch";
      open = "xdg-open";
      c = "clear";

      # git
      gaa = "git add --all";
      gcam = "git commit --all --message";
      gcl = "git clone";
      gco = "git checkout";
      ggl = "git pull";
      ggp = "git push";
      lg = "lazygit";
      repo = "cd $HOME/Documents/repositories";

      # kubectl
      k = "kubectl";
      kctx = "kubectx";
      # ... (你其他的 kubectl 别名照样写在这里) ...

      # editor
      v = "nvim";
      vi = "nvim";
      vim = "nvim";
      neovim = "nvim";
      code = "vs";
      zshconfig = "vim ~/.zshrc";
      ohmyzsh = "vim ~/.oh-my-zsh";

      # eza
      ls = "eza --icons always";
      ll = "eza -bhl --icons --group-directories-first";
      la = "eza -abhl --icons --group-directories-first";
      lt = "eza --tree --level=2 --icons";
      tree = "eza -T";

      # tools
      cat = "bat";
      rm = "trash-put";
      undo-rm = "trash-restore";
      rml = "trash-list";
      rmc = "trash-empty";
      total_rm = "trash-rm";

      # macOS specific
      chrome = "/Applications/Google\\ Chrome.app/Contents/MacOS/Google\\ Chrome";
      nix-darwin = "sudo darwin-rebuild --flake /Users/hc/.nixpkgs/.#AaronMac"; # 记得改对主机名

      # 其他别名...
      CMAKE = "cmake -GNinja -DCMAKE_C_COMPILER=/opt/homebrew/bin/gcc-15 -DCMAKE_CXX_COMPILER=/opt/homebrew/bin/g++-15";
      config-nvim = "yazi ~/.config/nvim/lua/";
      obsidian = "cd ~/HC/Obsidian/";
      org = "yazi ~/.emacs.d/Org";
    };

    # 5. 放在 .zshrc 最前面的内容
    initExtraFirst = ''
      # Powerlevel10k 瞬时提示符（必须在最前）
      if [[ -r "${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme" ]]; then
        source "${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme"
      fi
      # 加载 p10k 配置
      [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
    '';

    # 6. 放在 .zshrc 最后面的内容
    initExtra = ''
      # 每日一句 + 系统信息
      fastfetch
      fortune
      echo "
                      (__)
                       (oo)
                 /------\\/
                / |    ||
               *  /\\---/\\
                  ~~   ~~
      ...\"Have you mooed today?\"..."

      # Homebrew
      if [[ -f /opt/homebrew/bin/brew ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
      fi

      # 环境变量
      export PATH="$HOME/bin:/usr/local/bin:$HOME/.bin:/opt/homebrew/opt/llvm/bin:/opt/homebrew/opt/ruby/bin:$PATH:/Library/TeX/texbin"
      export ZSH="$HOME/.oh-my-zsh"
      export LANG=en_US.UTF-8
      export DYLD_LIBRARY_PATH="$DYLD_LIBRARY_PATH:/opt/homebrew/opt/llvm/lib:/Library/Frameworks/Maple.framework/Versions/2024/bin.APPLE_ARM64_MACOS"
      export LIBRARY_PATH="$LIBRARY_PATH:/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr/lib"
      export LDFLAGS="-L/opt/homebrew/opt/ruby/lib"
      export CPPFLAGS="-I/opt/homebrew/opt/ruby/include"
      export PKG_CONFIG_PATH="/opt/homebrew/opt/ruby/lib/pkgconfig"
      export VCPKG_ROOT="/Users/hc/Hc/SOURCE/vcpkg"
      export NIX_PATH="/Users/hc/.nixpkgs:/nix/var/nix/profiles/per-user/root/channels"
      export MYGIT="ssh://Aaron-git"
      export MAPLE="/Library/Frameworks/Maple.framework/Versions/2024"

      # 键位绑定
      bindkey -e
      bindkey '^H' backward-delete-word
      bindkey '^[[1;5C' forward-word
      bindkey '^[[1;5D' backward-word
      bindkey "^v" edit-command-line
      bindkey '^P' history-substring-search-up
      bindkey '^N' history-substring-search-down
      ${lib.optionalString pkgs.stdenv.isDarwin ''
        bindkey 'ć' fzf-cd-widget
      ''}

      # 各种工具初始化
      # kubectl auto-complete
      source <(kubectl completion zsh)

      # thefuck
      eval $(thefuck --alias)

      # zoxide
      eval "$(zoxide init --cmd cd zsh)"

      # fzf
      [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
      source <(fzf --zsh)

      # conda
      __conda_setup="$('/opt/homebrew/anaconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
      if [ $? -eq 0 ]; then
          eval "$__conda_setup"
      else
          if [ -f "/opt/homebrew/anaconda3/etc/profile.d/conda.sh" ]; then
              . "/opt/homebrew/anaconda3/etc/profile.d/conda.sh"
          else
              export PATH="/opt/homebrew/anaconda3/bin:$PATH"
          fi
      fi
      unset __conda_setup

      # 自定义函数
      function y() {
        local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
        yazi "$@" --cwd-file="$tmp"
        if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
          builtin cd -- "$cwd"
        fi
        rm -f -- "$tmp"
      }

      vterm_printf() {
        if [ -n "$TMUX" ] && { [ "${TERM%%-*}" = "tmux" ] || [ "${TERM%%-*}" = "screen" ]; }; then
            printf "\ePtmux;\e\e]%s\007\e\\" "$1"
        elif [ "${TERM%%-*}" = "screen" ]; then
            printf "\eP\e]%s\007\e\\" "$1"
        else
            printf "\e]%s\e\\" "$1"
        fi
      }
    '';
  };
}
