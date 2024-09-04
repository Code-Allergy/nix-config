{
  programs.bash = {
    enable = true;
    enableCompletion = true;
    enableVteIntegration = true;
    historyControl = ["ignorespace" "ignoredups"];
    historyFileSize = 100000;
  };
}
