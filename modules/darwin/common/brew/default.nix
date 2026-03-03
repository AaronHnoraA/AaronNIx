{ pkgs, config, inputs, ... }: {
  
  # 1. 在这里引入 nix-homebrew 模块
  # 因为我们在 flake.nix 里传递了 inputs，所以这里能读到
  imports = [
    inputs.nix-homebrew.darwinModules.nix-homebrew
    ./conda
    ./mactex
  ];

  # 2. 配置 nix-homebrew
  nix-homebrew = {
    enable = true;
    enableRosetta = true; # M1/M2/M3 必需
    user = "hc";   # 或者使用 config.users.primaryUser 动态获取
    autoMigrate = true;   # 接管现有的 brew
    
    # 可选：配置 taps 的所有权，防止权限问题
    # mutableTaps = false; 
  };

  # 3. 配置具体的包 (Homebrew 自身配置)
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      upgrade = true;
    };
    
    taps = [ 
      "homebrew/services" 
    ];
    brews = [ 
      "wget"
      "vips"
      "zoxide"
      "trash"
      "jupytext"
      "pandoc"
      "rust"
      "rust-analyzer"
    ];
    casks = [
      "aerospace"
    ];
  };
}
