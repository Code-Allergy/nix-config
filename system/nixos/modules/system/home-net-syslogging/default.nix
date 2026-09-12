{ config, lib, ... }:
let
  cfg = config.neer.modules.system.home-net-syslogging;
  labels = lib.concatStringsSep "\n" (
    lib.mapAttrsToList (name: value: "${builtins.toJSON name} = ${builtins.toJSON value},") (
      cfg.extraLabels
      // {
        hostname = config.networking.hostName;
        platform = "nixos";
        environment = "homelab";
      }
    )
  );
in
{
  options.neer.modules.system.home-net-syslogging = {
    enable = lib.mkEnableOption "home-network journal logging and host metrics via Grafana Alloy";

    extraLabels = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = { };
      description = "Additional host labels attached to logs and metrics.";
    };

    prometheusUrl = lib.mkOption {
      type = lib.types.str;
      default = "https://prometheus.duckduck112.duckdns.org/api/v1/write";
      description = "Home-network Prometheus remote-write endpoint.";
    };

    lokiUrl = lib.mkOption {
      type = lib.types.str;
      default = "https://loki.duckduck112.duckdns.org/loki/api/v1/push";
      description = "Home-network Loki push endpoint.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.alloy = {
      enable = true;

      extraFlags = [
        "--server.http.listen-addr=127.0.0.1:12345"
        "--disable-reporting"
      ];
    };

    environment.etc."alloy/config.alloy".text = ''
      logging {
        level  = "info"
        format = "logfmt"
      }

      // -------------------------------------------------------------------------
      // Central outputs
      // -------------------------------------------------------------------------

      prometheus.remote_write "central" {
        external_labels = {
          ${labels}
        }

        endpoint {
          url = ${builtins.toJSON cfg.prometheusUrl}
        }
      }

      loki.write "central" {
        external_labels = {
          ${labels}
        }

        endpoint {
          url = ${builtins.toJSON cfg.lokiUrl}
        }
      }

      // -------------------------------------------------------------------------
      // Host metrics
      // -------------------------------------------------------------------------

      prometheus.exporter.unix "host" {
        systemd {
          enable_restarts = true
          start_time      = true
        }

        filesystem {
          fs_types_exclude = "^(autofs|binfmt_misc|bpf|cgroup2?|configfs|debugfs|devpts|devtmpfs|efivarfs|fusectl|hugetlbfs|mqueue|nsfs|overlay|proc|procfs|pstore|rpc_pipefs|securityfs|sysfs|tracefs)$"

          mount_points_exclude = "^/(dev|proc|run/credentials/.+|sys)($|/)"
        }

        netclass {
          ignored_devices = "^(veth.*|podman.*|cni.*)$"
        }

        netdev {
          device_exclude = "^(veth.*|podman.*|cni.*)$"
        }
      }

      prometheus.scrape "host" {
        targets         = prometheus.exporter.unix.host.targets
        scrape_interval = "15s"

        forward_to = [
          prometheus.remote_write.central.receiver,
        ]
      }

      // -------------------------------------------------------------------------
      // NixOS / systemd journal
      // -------------------------------------------------------------------------

      loki.relabel "journal" {
        forward_to = [
          loki.write.central.receiver,
        ]

        rule {
          source_labels = ["__journal__systemd_unit"]
          regex         = "(.+)"
          target_label  = "service_name"
          replacement   = "$1"
        }

        rule {
          source_labels = ["__journal_syslog_identifier"]
          regex         = "(.+)"
          target_label  = "syslog_identifier"
          replacement   = "$1"
        }

        rule {
          source_labels = ["__journal_priority_keyword"]
          regex         = "(.+)"
          target_label  = "severity"
          replacement   = "$1"
        }
      }

      loki.source.journal "system" {
        // Avoid replaying old journal data into Loki on first startup.
        max_age = "24h"

        labels = {
          source = "journal",
        }

        relabel_rules = loki.relabel.journal.rules

        forward_to = [
          loki.write.central.receiver,
        ]
      }

      // -------------------------------------------------------------------------
      // Alloy's own metrics
      // -------------------------------------------------------------------------

      prometheus.scrape "alloy" {
        targets = [
          {
            __address__ = "127.0.0.1:12345",
            service     = "alloy",
          },
        ]

        scrape_interval = "15s"

        forward_to = [
          prometheus.remote_write.central.receiver,
        ]
      }
    '';
  };
}
