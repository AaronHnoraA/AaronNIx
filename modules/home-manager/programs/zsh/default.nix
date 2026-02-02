
{ pkgs, config, ... }:
{
  # 1. 安装需要的包
  home.packages = with pkgs; [
    zsh-powerlevel10k eza bat fzf zoxide pay-respects fastfetch fortune
  ];

  # 2. 把你的配置文件链接到 ~/.config/zsh/my_zshrc
  xdg.configFile."zsh/my_zshrc".source = ./zshrc; 

  # 3. 配置 zsh
  programs.zsh = {
    enable = true;
    
    # 使用 initExtra 而不是 initContent
    initExtra = ''
      # 强制将 Nix profile 路径放在 PATH 最前面
      # 这会在所有其他初始化之后执行，覆盖 path_helper 的设置
      export PATH="$HOME/.nix-profile/bin:/nix/var/nix/profiles/default/bin:$PATH"
      
      # 移除重复的路径条目
      typeset -U PATH
      
      # 加载你的自定义配置
      source ~/.config/zsh/my_zshrc
    '';
  };
  
  # 或者使用 home.sessionPath（但在 macOS 上可能被 path_helper 覆盖）
  # home.sessionPath = [
  #   "$HOME/.nix-profile/bin"
  #   "/nix/var/nix/profiles/default/bin"
  # ];
}
