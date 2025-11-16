{ config, pkgs, ... }:

{
  home.stateVersion = "25.05";
  home.sessionVariables = {
    EDITOR = "nvim";
  };
  programs.git = {
    enable = true;
    settings = {
      user = {
        name  = "Emil J. Tywoniak";
        email = "emil" + "@" + "tywoniak.eu";
      };
      aliases = {
          lol = "log --graph --oneline --all";
          meme = "!f() { current=$(git branch --show-current) && git checkout $1 && git rebase $current && git checkout $current && git merge --ff-only $1; }; f";
          mememe = "meme";
      };
      core.editor = "nvim";
      push.autoSetupRemote = true;
      merge.conflictstyle = "diff3";
    };
    maintenance.enable = true;
    maintenance.repositories = [ "/home/emil/pulls/yosys" ];
  };
  programs.delta = {
    enable = true;
    enableGitIntegration = true;
  };
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/html" = "firefox.desktop";
      "x-scheme-handler/http" = "firefox.desktop";
      "x-scheme-handler/https" = "firefox.desktop";
      "x-scheme-handler/about" = "firefox.desktop";
      "x-scheme-handler/unknown" = "firefox.desktop";
    };
  };
  programs.wofi.enable = true;
  wayland.windowManager.sway.config  = {
    terminal = "alacritty";
    menu = "wofi";
  };
  programs.fish.interactiveShellInit = ''
    any-nix-shell fish | source
  '';
  dconf.settings = {
        "org/gnome/desktop/peripherals/mouse" = { natural-scroll = true; };
  };
}
