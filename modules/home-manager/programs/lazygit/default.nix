{ ... }:
{
  # 用 Home Manager 装 lazygit
  programs.lazygit.enable = true;

  # 从当前目录读取 config.yml，并放到标准位置
  xdg.configFile."lazygit/config.yml".source = ./config.yml;
}
