{
  outputs,
  pkgs,
	lib,
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
				"com.apple.symbolichotkeys" = let
					disabled = { enabled = false; };

					std = p1: p2: p3: {
						enabled = true;
						value = {
							parameters = [ p1 p2 p3 ];
							type = "standard";
						};
					};

					shift = 131072;
					ctrl  = 262144;
					alt   = 524288;
					cmd   = 1048576;

					arrowBase = 2097152;

					mods4 = ctrl + alt + shift + cmd;  # ^⌥⇧⌘
					mods3 = ctrl + shift + cmd;        # ^⇧⌘

					keep = {
						# Mission Control: ^⌥⇧⌘↑
						"32" = std 65535 126 (arrowBase + mods4);
						"34" = std 65535 126 (arrowBase + mods4 + shift);

						# Move left a space: ^⇧⌘←
						"79" = std 65535 123 (arrowBase + mods3);
						"80" = std 65535 123 (arrowBase + mods3 + shift);

						# Move right a space: ^⇧⌘→
						"81" = std 65535 124 (arrowBase + mods3);
						"82" = std 65535 124 (arrowBase + mods3 + shift);

						# Switch to Desktop 1..10: ^⌥⇧⌘1..0
						"118" = std 49 18 mods4;  # 1
						"119" = std 50 19 mods4;  # 2
						"120" = std 51 20 mods4;  # 3
						"121" = std 52 21 mods4;  # 4
						"122" = std 53 23 mods4;  # 5
						"123" = std 54 22 mods4;  # 6
						"124" = std 55 26 mods4;  # 7
						"125" = std 56 28 mods4;  # 8
						"126" = std 57 25 mods4;  # 9
						"127" = std 48 29 mods4;  # 0 => Desktop 10
					};

					disableIds = [
						7 8 9 10 11 12 13
						27 28 29 30 31
						32 34 35 36 37
						51 52 57
						60 61 64 65
						79 80 81 82
						98
						118 119 120 121 122 123 124 125 126 127 128 129 130 131 132 133
						160 163 175
						181 182 184
					];
				in {
					AppleSymbolicHotKeys =
						(builtins.listToAttrs (map (id: {
							name = toString id;
							value = disabled;
						}) disableIds))
						// keep;
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
        CreateDesktop = true;
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
        {app = "/Applications/Brave Browser.app";}
        {app = "/Applications/kitty.app";}
        #{app = "/Users/hc/Applications/Home Manager Apps/Emacs.app";}
        {app = "/Applications/Emacs.app";}
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
