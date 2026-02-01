{
  outputs,
  pkgs,
  userConfig,
  ...
}:
{
  # Nixpkgs configuration
  nixpkgs = {
    overlays = [
      outputs.overlays.stable-packages
    ];

    config = {
      allowUnfree = true;
    };
  };

  # Nix settings
  nix = {
    settings = {
      experimental-features = "nix-command flakes";
    };
    optimise.automatic = true;
    package = pkgs.nix;
  };

  # User configuration
  users.users.${userConfig.name} = {
    name = userConfig.name;
    home = "/Users/${userConfig.name}";
  };

  # Add ability to use TouchID for sudo
  security.pam.services.sudo_local.touchIdAuth = true;

  # Passwordless sudo
  security.sudo.extraConfig = "${userConfig.name}    ALL = (ALL) NOPASSWD: ALL";

  # System settings
  system = {
    defaults = {
      controlcenter = {
        BatteryShowPercentage = true;
        NowPlaying = false;
      };
      CustomUserPreferences = {
        "com.apple.symbolichotkeys" = {
          AppleSymbolicHotKeys = {
            "163" = {
              # Set 'Option + N' for Show Notification Center
              enabled = true;
              value = {
                parameters = [
                  110
                  45
                  524288
                ];
                type = "standard";
              };
            };
            "184" = {
              # Set 'Option + Shift + R' for Screenshot and recording options
              enabled = true;
              value = {
                parameters = [
                  114
                  15
                  655360
                ];
                type = "standard";
              };
            };
            "60" = {
              # Disable '^ + Space' for selecting the previous input source
              enabled = false;
            };
            "61" = {
              # Set 'Option + Space' for selecting the next input source
              enabled = 1;
              value = {
                parameters = [
                  32
                  49
                  524288
                ];
                type = "standard";
              };
            };
            "64" = {
              # Disable 'Cmd + Space' for Spotlight Search
              enabled = false;
            };
            "65" = {
              # Disable 'Cmd + Alt + Space' for Finder search window
              enabled = false;
            };
            "238" = {
              # Set 'Control + Command + C' to center focused window
              enabled = true;
              value = {
                parameters = [
                  99
                  8
                  1310720
                ];
                type = "standard";
              };
            };
            "98" = {
              # Disable 'Show Help menu'
              enabled = false;
              value = {
                parameters = [
                  47
                  44
                  1179648
                ];
                type = "standard";
              };
            };
          };
        };
        "com.brave.Browser" = {
          NSUserKeyEquivalents = {
            "Close Tab" = "^w";
            "Find..." = "^f";
            "New Private Window" = "^$n";
            "New Tab" = "^t";
            "Reload This Page" = "^r";
            "Reopen Closed Tab" = "^$t";
            "Reset zoom" = "^0";
            "Zoom In" = "^=";
            "Zoom Out" = "^-";
          };
        };
        "com.dwarvesv.minimalbar" = {
          areSeparatorsHidden = 1;
          isAutoHide = 1;
          isAutoStart = 1;
          isShowPreferences = 0;
          numberOfSecondForAutoHide = 5;
        };
        NSGlobalDomain."com.apple.mouse.linear" = false;
        "-g".NSUserKeyEquivalents = {
          "Lock Screen" = "@^l";
          "Paste and Match Style" = "^$v";
        };
      };
      NSGlobalDomain = {
        "com.apple.sound.beep.volume" = 0.000;
        AppleInterfaceStyle = "Dark";
        ApplePressAndHoldEnabled = false;
        AppleShowAllExtensions = true;
        InitialKeyRepeat = 20;
        KeyRepeat = 2;
        NSAutomaticCapitalizationEnabled = false;
        NSAutomaticDashSubstitutionEnabled = false;
        NSAutomaticQuoteSubstitutionEnabled = false;
        NSAutomaticSpellingCorrectionEnabled = false;
        NSAutomaticWindowAnimationsEnabled = false;
        NSDocumentSaveNewDocumentsToCloud = false;
        NSNavPanelExpandedStateForSaveMode = true;
        PMPrintingExpandedStateForPrint = true;
      };
      LaunchServices = {
        LSQuarantine = false;
      };
      trackpad = {
        TrackpadRightClick = true;
        TrackpadThreeFingerDrag = true;
        Clicking = true;
      };
      finder = {
        AppleShowAllFiles = false;
        CreateDesktop = false;
        FXDefaultSearchScope = "SCcf";
        FXEnableExtensionChangeWarning = false;
        FXPreferredViewStyle = "Nlsv";
        QuitMenuItem = true;
        ShowPathbar = true;
        ShowStatusBar = false;
        _FXShowPosixPathInTitle = true;
        _FXSortFoldersFirst = true;
      };
      dock = {
        autohide = true;                 # 自动隐藏 Dock
        expose-animation-duration = 0.15;# Mission Control 动画时间
        show-recents = false;            # 不显示“最近使用的应用”
        showhidden = true;               # 隐藏的应用图标半透明
        persistent-apps = [
        {app = "/Users/hc/Applications/Home Manager Apps/Brave Browser.app";}
        {app = "/Applications/kitty.app";}
        {app = "/Users/hc/Applications/Home Manager Apps/Emacs.app";}
        {app = "/Applications/TradingView.app";}
        {app = "/Applications/MarginNote 4.app";}
        {app = "/Applications/Zotero.app";}
        {app = "/System/Applications/Music.app";}
        {app = "/Applications/Joplin.app";}
        ];           # 固定在 Dock 里的应用列表
        tilesize = 100;                   # Dock 图标大小
        wvous-bl-corner = 1;             # 热角（左下角）动作
        wvous-br-corner = 1;
        wvous-tl-corner = 1;
        wvous-tr-corner = 1;
      };
      screencapture = {
        location = "/Users/${userConfig.name}/Downloads/";
        type = "png";
        disable-shadow = true;
      };
    };
    keyboard = {
      enableKeyMapping = true;
      # Remap §± to ~
      userKeyMapping = [
        {
          HIDKeyboardModifierMappingDst = 30064771125;
          HIDKeyboardModifierMappingSrc = 30064771172;
        }
      ];
    };
    primaryUser = userConfig.name;
  };

  # Zsh configuration
  programs.zsh.enable = true;

  # Fonts configuration
  fonts.packages = with pkgs; [
    nerd-fonts.meslo-lg
  ];
  imports = [
    ./brew
  ];
}
