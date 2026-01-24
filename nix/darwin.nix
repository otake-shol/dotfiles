# ========================================
# darwin.nix - nix-darwin macOS設定
# ========================================
# macOS固有の設定をNixで宣言的に管理
#
# 使用方法:
#   darwin-rebuild switch --flake .
#
# 参考: https://daiderd.com/nix-darwin/manual/

{ config, pkgs, lib, ... }:

{
  # ========================================
  # Nix設定
  # ========================================
  nix = {
    # Nix Flakesを有効化
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      # 信頼するユーザー
      trusted-users = [ "@admin" ];
    };

    # ガベージコレクション設定
    gc = {
      automatic = true;
      interval = { Day = 7; };
      options = "--delete-older-than 7d";
    };
  };

  # ========================================
  # システム設定 (macOS defaults)
  # ========================================
  system = {
    # macOSバージョン（互換性のため）
    stateVersion = 4;

    defaults = {
      # Dock設定
      dock = {
        autohide = true;
        autohide-delay = 0.0;
        autohide-time-modifier = 0.5;
        orientation = "bottom";
        show-recents = false;
        tilesize = 48;
        # ホットコーナー（1=無効, 2=Mission Control, 3=アプリウィンドウ, 4=デスクトップ）
        wvous-bl-corner = 1;
        wvous-br-corner = 1;
        wvous-tl-corner = 1;
        wvous-tr-corner = 1;
      };

      # Finder設定
      finder = {
        AppleShowAllExtensions = true;
        AppleShowAllFiles = false;  # 隠しファイルは非表示
        FXEnableExtensionChangeWarning = false;
        FXPreferredViewStyle = "Nlsv";  # リスト表示
        ShowPathbar = true;
        ShowStatusBar = true;
        _FXShowPosixPathInTitle = true;
      };

      # グローバル設定
      NSGlobalDomain = {
        # キーリピート速度
        KeyRepeat = 2;
        InitialKeyRepeat = 15;
        # ダークモード
        AppleInterfaceStyle = "Dark";
        # スクロール
        AppleShowScrollBars = "WhenScrolling";
        # 自動修正
        NSAutomaticCapitalizationEnabled = false;
        NSAutomaticDashSubstitutionEnabled = false;
        NSAutomaticPeriodSubstitutionEnabled = false;
        NSAutomaticQuoteSubstitutionEnabled = false;
        NSAutomaticSpellingCorrectionEnabled = false;
      };

      # スクリーンキャプチャ設定
      screencapture = {
        disable-shadow = true;
        location = "~/Desktop";
        type = "png";
      };

      # トラックパッド設定
      trackpad = {
        Clicking = true;  # タップでクリック
        TrackpadRightClick = true;  # 二本指で右クリック
        TrackpadThreeFingerDrag = true;  # 三本指ドラッグ
      };
    };

    # キーボード設定
    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToControl = true;  # Caps Lock → Control
    };
  };

  # ========================================
  # Homebrew設定（nix-darwinと連携）
  # ========================================
  homebrew = {
    enable = true;

    # 更新時の動作
    onActivation = {
      autoUpdate = true;
      cleanup = "zap";  # 未管理パッケージを削除
      upgrade = true;
    };

    # グローバル設定
    global = {
      brewfile = true;
      lockfiles = false;
    };

    # Taps
    taps = [
      "homebrew/bundle"
      "homebrew/services"
    ];

    # CLI tools (formulae)
    brews = [
      # 基本ツール
      "git"
      "git-lfs"
      "gh"

      # シェル
      "zsh"
      "zsh-completions"

      # モダンCLI
      "eza"
      "bat"
      "fd"
      "ripgrep"
      "fzf"
      "zoxide"
      "atuin"

      # 開発ツール
      "neovim"
      "tmux"
      "direnv"
      "jq"
      "yq"

      # Git
      "delta"
      "lazygit"
      "git-secrets"
      "lefthook"

      # セキュリティ
      "gnupg"
      "age"
      "sops"

      # バージョン管理
      "asdf"
    ];

    # GUIアプリ (casks)
    casks = [
      # ターミナル
      "ghostty"

      # 開発
      "docker"
      "visual-studio-code"

      # ブラウザ
      "arc"
      "google-chrome"

      # ユーティリティ
      "raycast"
      "1password"
      "karabiner-elements"
      "espanso"

      # フォント
      "font-hack-nerd-font"
      "font-jetbrains-mono-nerd-font"
    ];

    # Mac App Store (masApps)
    # mas "App Name" = App ID
    masApps = {
      # "Xcode" = 497799835;
    };
  };

  # ========================================
  # フォント設定
  # ========================================
  fonts = {
    packages = with pkgs; [
      (nerdfonts.override {
        fonts = [
          "JetBrainsMono"
          "Hack"
          "FiraCode"
        ];
      })
    ];
  };

  # ========================================
  # 環境変数
  # ========================================
  environment = {
    # システム環境変数
    variables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
      LANG = "en_US.UTF-8";
    };

    # システムシェル
    shells = with pkgs; [ zsh bash ];

    # システムパッケージ
    systemPackages = with pkgs; [
      coreutils
      gnused
      gawk
      gnugrep
    ];
  };

  # ========================================
  # プログラム設定
  # ========================================
  programs = {
    # zshを有効化
    zsh = {
      enable = true;
      enableCompletion = true;
      enableBashCompletion = true;
    };
  };

  # ========================================
  # セキュリティ設定
  # ========================================
  security = {
    pam = {
      enableSudoTouchIdAuth = true;  # Touch IDでsudo認証
    };
  };

  # ========================================
  # サービス設定
  # ========================================
  services = {
    # nix-daemon
    nix-daemon.enable = true;
  };
}
