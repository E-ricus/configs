# Work tools — Slack, graphite, AWS CLI, postgresql, insomnia, TeamViewer.
{den, ...}: {
  den.aspects.work-tools = {
    nixos = {
      pkgs,
      lib,
      ...
    }: {
      environment.systemPackages = with pkgs; [
        slack
        graphite-cli
        awscli2
        postgresql
        insomnia
      ];
      # For Slack in Wayland
      environment.sessionVariables.NIXOS_OZONE_WL = "1";
      # TeamViewer daemon (manual start only: sudo systemctl start teamviewerd)
      services.teamviewer.enable = true;
      systemd.services.teamviewerd.wantedBy = lib.mkForce [];
    };
  };
}
