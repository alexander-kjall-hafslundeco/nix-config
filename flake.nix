{
  description = "My system configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin = {
        url = "github:LnL7/nix-darwin";
        inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs }:

  let
    pkgs = import <nixpkgs> {};
    rust-toolchain = pkgs.symlinkJoin {
      name = "rust-toolchain";
      paths = [pkgs.rustc pkgs.cargo pkgs.rustPlatform.rustcSrc];
    };
  in
  let
    configuration = {pkgs, ... }: {

      #services.nix-daemon.enable = true;
      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility. please read the changelog
      # before changing: `darwin-rebuild changelog`.
      system.stateVersion = 4;

      # The platform the configuration will be used on.
      # If you're on an Intel system, replace with "x86_64-darwin"
      nixpkgs.hostPlatform = "aarch64-darwin";

      # group id of the nix stuff
      ids.gids.nixbld = 350;

      # Declare the user that will be running `nix-darwin`.
      users.users."alexander.kjall" = {
        name = "alexander.kjall";
        home = "/Users/alexander.kjall";
      };

      # Create /etc/zshrc that loads the nix-darwin environment.
      programs.zsh.enable = true;

      fonts.packages = [
        pkgs.nerd-fonts.fira-code
      ];

      environment.systemPackages = [ pkgs.neofetch pkgs.emacs pkgs.git pkgs.cargo pkgs.sequoia-sq pkgs.sequoia-chameleon-gnupg rust-toolchain pkgs.ripgrep pkgs.bat pkgs.alacritty pkgs.starship pkgs.lsd pkgs.postgresql_17 pkgs.emacsPackages.nix-mode pkgs.bashInteractive pkgs.bash-completion pkgs.nix-bash-completions pkgs.zizmor pkgs.yamllint pkgs.azure-cli ];

      # enable touch-id for sudo
      security.pam.services.sudo_local.touchIdAuth = true;
    };
  in {
    darwinConfigurations."MBP-DVTK72MJYW" = nix-darwin.lib.darwinSystem {
      modules = [
        configuration
      ];
    };
  };
}

