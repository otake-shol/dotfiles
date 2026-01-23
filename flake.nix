{
  description = "Cross-platform dotfiles with Nix flakes";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # home-manager
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # nix-darwin (macOS)
    darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # flake-utils for multi-platform support
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, home-manager, darwin, flake-utils, ... }@inputs:
    let
      # サポートするシステム
      supportedSystems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];

      # システムごとの設定を生成
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

      # nixpkgsの設定
      nixpkgsFor = forAllSystems (system: import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      });

      # 共通パッケージ
      commonPackages = pkgs: with pkgs; [
        # シェル
        zsh
        starship
        zoxide
        atuin
        direnv

        # ファイル操作
        eza
        bat
        fd
        ripgrep
        fzf
        zellij
        yazi

        # Git
        git
        gh
        delta
        lazygit
        git-lfs

        # 開発ツール
        neovim
        tmux
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
        sops
      ];

    in
    {
      # macOS設定
      darwinConfigurations = {
        # Intel Mac
        "x86_64-darwin" = darwin.lib.darwinSystem {
          system = "x86_64-darwin";
          modules = [
            ./nix/darwin.nix
            home-manager.darwinModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.${builtins.getEnv "USER"} = import ./home.nix;
            }
          ];
        };

        # Apple Silicon Mac
        "aarch64-darwin" = darwin.lib.darwinSystem {
          system = "aarch64-darwin";
          modules = [
            ./nix/darwin.nix
            home-manager.darwinModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.${builtins.getEnv "USER"} = import ./home.nix;
            }
          ];
        };
      };

      # home-manager standalone設定
      homeConfigurations = forAllSystems (system:
        home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgsFor.${system};
          modules = [ ./home.nix ];
        }
      );

      # 開発シェル
      devShells = forAllSystems (system:
        let
          pkgs = nixpkgsFor.${system};
        in
        {
          default = pkgs.mkShell {
            buildInputs = commonPackages pkgs ++ (with pkgs; [
              # 開発用追加ツール
              nodejs_20
              python311
              rustup
            ]);

            shellHook = ''
              echo "🚀 dotfiles 開発環境に入りました"
              echo "利用可能なコマンド:"
              echo "  make test    - テスト実行"
              echo "  make lint    - Lint実行"
              echo "  make install - dotfilesインストール"
            '';
          };
        }
      );

      # パッケージ
      packages = forAllSystems (system:
        let
          pkgs = nixpkgsFor.${system};
        in
        {
          default = pkgs.buildEnv {
            name = "dotfiles-packages";
            paths = commonPackages pkgs;
          };
        }
      );
    };
}
