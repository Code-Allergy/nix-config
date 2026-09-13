let
  operatorRecipients = [
    "age13xy0jr2s8l0lrxnq585zlukehlgw9xd8xdwdwqhshwy42elhaupse0dtvm"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG6a8XtV9urGE58KfJuzc7bra8yRrD2bdFCcAEvgiXLK"
  ];
  ampereRecipients =
    operatorRecipients
    ++ [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGjTWYMnDr1CBGP6vlVX+KQpChl5dnZhqb4sQyb57khc"
    ];
  optimusRecipients =
    operatorRecipients
    ++ [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKP0sHbfhwdWQsFLZsR6pB664rgHyhuZQRqmMfH6lFyU"
    ];
in {
  "ai-ampere-worker.env.age".publicKeys = ampereRecipients;
  "ai-open-webui.env.age".publicKeys = ampereRecipients;
  "ai-litellm.env.age".publicKeys = ampereRecipients;
  "ai-litellm-postgres.env.age".publicKeys = ampereRecipients;

  "ai-optimus-worker.env.age".publicKeys = optimusRecipients;
}
