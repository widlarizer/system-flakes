{ config, pkgs, ... }:

{
  home.stateVersion = "25.05";
  home.sessionVariables = {
    EDITOR = "nvim";
  };
  programs.git = {
    enable = true;
    userName  = "Emil J. Tywoniak";
    userEmail = "emil" + "@" + "tywoniak.eu";
    aliases = {
      	lol = "log --graph --oneline --all";
      	meme = "!f() { current=$(git branch --show-current) && git checkout $1 && git rebase $current && git checkout $current && git merge --ff-only $1; }; f";
        mememe = "meme";
    };
    extraConfig = {
      core.editor = "nvim";
      push.autoSetupRemote = true;
      merge.conflictstyle = "diff3";
    };
    delta.enable = true;
    maintenance.enable = true;
    maintenance.repositories = [ "/home/emil/pulls/yosys" ];
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
  };
}
