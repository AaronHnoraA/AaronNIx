{ userConfig, ... }:
{
  # Install git via home-manager module
  programs.git = {
    enable = true;
    settings = {
      user = {
        email = userConfig.email;
        name = userConfig.fullName;
      };
      pull.rebase = "true";
    };
    
    # --- 修改开始 ---
    # 方法1：完全删除 signing 块（最彻底）
    # signing = { ... }; 
    
    # 方法2：显式禁用（推荐，逻辑清晰）
    signing = {
      key = null; # 或者 userConfig.gitKey，如果不签名，key 设不设都无所谓
      signByDefault = false; 
    };
    # --- 修改结束 ---
  };

  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      keep-plus-minus-markers = true;
      light = false;
      line-numbers = true;
      navigate = true;
      width = 280;
    };
  };

  # Enable catppuccin theming for git delta
  catppuccin.delta.enable = true;
}
