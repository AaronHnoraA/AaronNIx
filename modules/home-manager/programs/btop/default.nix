{ pkgs, ... }:
{
  # 1. 启用 btop，但不要在这里写 settings
  programs.btop.enable = true;

  # 2. 直接链接 btop.conf 到目标位置
  xdg.configFile."btop/btop.conf".source = ./btop.conf;

  # 3. 链接 themes 目录（如果有自定义主题）
  xdg.configFile."btop/themes".source = ./themes;
  
  # 如果你确实需要 catppuccin 覆盖部分设置，保留它也没问题，
  # 但注意它生成的配置可能会和上面直接 source btop.conf 冲突。
  # 推荐做法：如果你决定用 source ./btop.conf，就尽量全在 btop.conf 里改，
  # 或者确认 catppuccin 模块是否只是写入 themes 目录而不强占 btop.conf。
  catppuccin.btop.enable = true; 
}
