{ config, pkgs, userConfig, ... }:

{
  # --- 1. Homebrew 软件安装部分 ---
  homebrew = {
    # 确保 tap 存在
    taps = [ "d12frosted/emacs-plus" ];
    brews = [
      # 必要的依赖
      "libgccjit"
      "gcc"
      
      # Emacs 本体 (JSON 结构)
      {
        name = "emacs-plus";
        args = [
          "with-xwidgets"
        ];
      }
    ];
  };

  # --- 2. 配置文件链接部分 (通过 Home Manager) ---
  # 注意：这里假设你的主配置已经正确集成了 Home Manager
  # 并且把 users.users.${userConfig.name} 传进来了
  
  users.users.${userConfig.name} = {
    # 链接本地的 ./emacs 文件夹到 ~/.emacs.d
    home.file.".emacs.d" = {
      # source 指向你当前 Nix 配置目录下的 emacs 文件夹
      # 确保你真的在同级目录下有个叫 emacs 的文件夹
      source = ./emacs; 
      
      # 递归链接：这样你可以单独修改里面的文件而不用重新生成整个目录
      # 如果你希望整个文件夹是一个软链，设为 false (默认通常是 symlink directory)
      # 推荐设为 true 以便只管理文件，或者直接 symlink 整个目录
      recursive = true; 
    };
  };
}
