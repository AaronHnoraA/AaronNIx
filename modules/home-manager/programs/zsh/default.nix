{ pkgs, config, ... }:
{
  # 1. 安装需要的包
  home.packages = with pkgs; [
    zsh-powerlevel10k eza bat fzf zoxide pay-respects fastfetch fortune
  ];

  # 2. 把你的配置文件链接到 ~/.config/zsh/my_zshrc
  xdg.configFile."zsh/my_zshrc".source = ./zshrc; 
  # 这里假设你当前目录下有个 zshrc 文件
  # 如果想直接用绝对路径引用原来的文件而不通过 store：
  # xdg.configFile."zsh/my_zshrc".source = config.lib.file.mkOutOfStoreSymlink "/Users/hc/.dotfiles/zshrc";

  # 3. 让 Home Manager 生成的 .zshrc 去 source 你的文件
  programs.zsh = {
    enable = true;
    # 在生成的 .zshrc 最后一行加上：
    initContent = ''
      source ~/.config/zsh/my_zshrc
    '';
  };
}
