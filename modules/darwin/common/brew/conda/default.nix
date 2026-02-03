{ pkgs, config, inputs, ... }: {
  
  # 1. 在这里引入 nix-homebrew 模块
  # 因为我们在 flake.nix 里传递了 inputs，所以这里能读到
  imports = [
    inputs.nix-homebrew.darwinModules.nix-homebrew
  ];


  # 3. 配置具体的包 (Homebrew 自身配置)
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      upgrade = true;
    };
    
    taps = [ 
    ];
    brews = [ 
      "aaanaconda"
    ];
    casks = [
    ];
  };
  # 在 homebrew 安装完成后执行
  system.activationScripts.postUserActivation.text = ''
    # 等待 conda 可用
    if [ -f "/opt/homebrew/anaconda3/bin/conda" ]; then
      echo "Setting up conda environments..."
      # 初始化 conda
      eval "$(/opt/homebrew/anaconda3/bin/conda shell.bash hook)"
      echo "Conda setup complete"
    fi
  '';
  # go to zsh config for setting up conda env
}
