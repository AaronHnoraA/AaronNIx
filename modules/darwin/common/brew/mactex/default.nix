{ pkgs, config, inputs, ... }: {
  
  # 1. 在这里引入 nix-homebrew 模块
  # 因为我们在 flake.nix 里传递了 inputs，所以这里能读到


  # 3. 配置具体的包 (Homebrew 自身配置)
  homebrew = {
    taps = [ 
    ];
    brews = [ 
      "mactex"
    ];
    casks = [
    ];
  };
  home.sessionPath = [
    "/Library/TeX/texbin"
  ]
}
