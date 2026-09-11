let
  # Local unattended identity: ~/.config/agenix/keys.txt (never commit it).
  # The SSH recipient provides recovery using the passphrase-protected key.
  recipients = [
    "age13xy0jr2s8l0lrxnq585zlukehlgw9xd8xdwdwqhshwy42elhaupse0dtvm"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG6a8XtV9urGE58KfJuzc7bra8yRrD2bdFCcAEvgiXLK"
  ];
in
{
  "mcp-chief-jira.age".publicKeys = recipients;
  "mcp-trilium-notes.age".publicKeys = recipients;
}
