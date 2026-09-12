{ config, lib, pkgs, ... }:

{
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
        hostname        = "ampere"
        platform        = "nixos"
        role            = "ai"
        environment     = "homelab"
      }

      endpoint {
        url = "http://10.10.10.10:9090/api/v1/write"
      }
    }

    loki.write "central" {
      external_labels = {
        hostname        = "ampere"
        platform        = "nixos"
        role            = "ai"
        environment     = "homelab"
      }

      endpoint {
        url = "http://10.10.10.10:3100/loki/api/v1/push"
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
        source = "journal"
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
          __address__ = "127.0.0.1:12345"
          service     = "alloy"
        },
      ]

      scrape_interval = "15s"

      forward_to = [
        prometheus.remote_write.central.receiver,
      ]
    }
  '';
}
