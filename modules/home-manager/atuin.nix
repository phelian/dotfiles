{pkgs, ...}: {
  programs.atuin = {
    enable = true;
    package = pkgs.atuin.overrideAttrs {doCheck = false;};
    settings = {
      auto_sync = true;
      sync_frequency = "5m";
      sync_address = "https://api.atuin.sh";
      search_mode = "fuzzy";
      filter_mode = "directory";
      flags = [ "--disable-up-arrow" ];
    };
  };
}
