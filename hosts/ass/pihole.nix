{
  services.pihole-ftl = {
    enable = true;
    openFirewallDNS = true;
    openFirewallWebserver = true;
    queryLogDeleter.enable = true;
    lists = [
      {
        url = "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts";
        description = "Steven Black's unified adlist";
      }
    ];
    settings.dns = {
      interface = "eno1";
      listeningMode = "LOCAL";
      upstreams = [ "1.1.1.1" "9.9.9.9" ];
    };
  };

  services.pihole-web = {
    enable = true;
    ports = [ 80 ];
  };
}
