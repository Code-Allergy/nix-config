{ ... }: final: prev: {
  lact = prev.lact.override {
    libdisplay-info = final.libdisplay-info_0_3;
  };
}
