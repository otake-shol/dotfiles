{ config, pkgs, lib, ... }:

{
  # Home Manager設定
  home.username = builtins.getEnv "USER";
  home.homeDirectory = builtins.getEnv "HOME";
  home.stateVersion = "23.11";

  # パッケージ
  home.packages = with pkgs; [
    # シェル関連
    zsh
    zoxide
    atuin
    direnv
    starship

    # ファイル操作
    eza
    bat
    fd
    ripgrep
    fzf
    yazi

    # Git
    git
    gh
    delta
    lazygit

    # エディタ
    neovim

    # ターミナル多重化
    tmux
    zellij

    # JSON/YAML
    jq
    yq

    # モダンCLI
    dust
    procs
    bottom
    hyperfine
    tokei
    tealdeer

    # ネットワーク
    curl
    wget
    httpie

    # セキュリティ
    gnupg
    age
  ];

  # プログラム設定
  programs = {
    # Home Manager自体を有効化
    home-manager.enable = true;

    # Git
    git = {
      enable = true;
      delta.enable = true;
      extraConfig = {
        init.defaultBranch = "main";
        pull.rebase = true;
        push.autoSetupRemote = true;
        core.editor = "nvim";
        diff.colorMoved = "default";
        merge.conflictstyle = "diff3";
      };
      ignores = [
        ".DS_Store"
        "*.swp"
        ".direnv/"
        ".envrc"
        "node_modules/"
        "__pycache__/"
        ".venv/"
      ];
    };

    # Zsh
    zsh = {
      enable = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
      history = {
        size = 50000;
        save = 50000;
        ignoreDups = true;
        ignoreAllDups = true;
        ignoreSpace = true;
        share = true;
      };
      shellAliases = {
        ls = "eza";
        ll = "eza -la";
        la = "eza -a";
        lt = "eza --tree";
        cat = "bat";
        grep = "rg";
        find = "fd";
        vim = "nvim";
        vi = "nvim";
      };
    };

    # Starship プロンプト
    starship = {
      enable = true;
      settings = {
        add_newline = true;
        character = {
          success_symbol = "[❯](bold green)";
          error_symbol = "[❯](bold red)";
        };
        directory = {
          truncation_length = 3;
          truncate_to_repo = true;
        };
        git_branch = {
          symbol = " ";
        };
        git_status = {
          conflicted = "🏳";
          ahead = "⇡";
          behind = "⇣";
          diverged = "⇕";
          untracked = "?";
          stashed = "📦";
          modified = "!";
          staged = "+";
          renamed = "»";
          deleted = "✘";
        };
      };
    };

    # Zoxide
    zoxide = {
      enable = true;
      enableZshIntegration = true;
    };

    # Atuin
    atuin = {
      enable = true;
      enableZshIntegration = true;
      settings = {
        auto_sync = false;
        sync_frequency = "0";
        search_mode = "fuzzy";
        filter_mode = "global";
        style = "compact";
      };
    };

    # Direnv
    direnv = {
      enable = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;
    };

    # Fzf
    fzf = {
      enable = true;
      enableZshIntegration = true;
      defaultOptions = [
        "--height 60%"
        "--layout=reverse"
        "--border=rounded"
        "--info=inline"
      ];
      colors = {
        fg = "#c0caf5";
        bg = "#1a1b26";
        hl = "#bb9af7";
        "fg+" = "#c0caf5";
        "bg+" = "#292e42";
        "hl+" = "#7dcfff";
        info = "#7aa2f7";
        prompt = "#7dcfff";
        pointer = "#7dcfff";
        marker = "#9ece6a";
        spinner = "#9ece6a";
        header = "#9ece6a";
      };
    };

    # Bat
    bat = {
      enable = true;
      config = {
        theme = "TwoDark";
        style = "numbers,changes,header";
      };
    };

    # Neovim
    neovim = {
      enable = true;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;
    };

    # Tmux
    tmux = {
      enable = true;
      shortcut = "a";
      keyMode = "vi";
      mouse = true;
      terminal = "screen-256color";
      historyLimit = 50000;
      plugins = with pkgs.tmuxPlugins; [
        sensible
        yank
        resurrect
        continuum
      ];
    };
  };

  # ファイル管理（dotfilesのシンボリックリンク）
  # 注: 既存のbootstrap.shとの競合を避けるため、
  # Nixで管理しないファイルはコメントアウト
  # home.file = {
  #   ".zshrc".source = ./stow/zsh/.zshrc;
  #   ".gitconfig".source = ./stow/git/.gitconfig;
  # };
}
