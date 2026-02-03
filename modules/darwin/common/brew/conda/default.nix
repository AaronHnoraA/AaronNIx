{ pkgs, config, inputs, ... }: {
  
  # 1. 在这里引入 nix-homebrew 模块
  # 因为我们在 flake.nix 里传递了 inputs，所以这里能读到


  # 3. 配置具体的包 (Homebrew 自身配置)
  homebrew = {
    taps = [ 
    ];
    brews = [ 
    ];
    casks = [
      "anaconda"
    ];
  };
  # 使用 postActivation 并通过 sudo 以用户身份运行
  system.activationScripts.postActivation.text = ''
    echo "Setting up conda environments..."
    # 获取当前用户
    
    if [ -f "/opt/homebrew/anaconda3/bin/conda" ]; then
      # 以用户身份运行 conda 命令
      echo "Conda setup complete"
    fi
  '';
}
