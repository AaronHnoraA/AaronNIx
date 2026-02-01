{ pkgs, config, inputs, ... }: {
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      upgrade = true;
    };
    
    taps = [ 
      "railwaycat/emacsmacport"
    ];
    brews = [ 
      "wget"
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
    casks = [];
  };
}
