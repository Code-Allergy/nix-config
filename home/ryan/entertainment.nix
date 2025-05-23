{ pkgs, ... }:
{
  home.packages = with pkgs; [
    jellyfin-media-player
    jellycli
    # feishin TODO: BROKEN 
    spotube
    youtube-music
    vlc
  ];

  programs.freetube = {
    enable = true;
    settings = {
      allowDashAv1Formats = true;
      checkForUpdates = false;
      defaultQuality = "1440";
      baseTheme = "catppuccinMocha";
    };
  };

  # home.file.".config/YouTube Music/config.json".text = ''
  #   {
  #   	"window-size": {
  #   		"width": 1280,
  #   		"height": 1415
  #   	},
  #   	"window-maximized": true,
  #   	"window-position": {
  #   		"x": 0,
  #   		"y": 0
  #   	},
  #   	"url": "https://music.youtube.com",
  #   	"options": {
  #   		"removeUpgradeButton": true,
  #   		"likeButtons": "hide",
  #   		"startingPage": "New Releases",
  #   		"tray": true,
  #   		"appVisible": true,
  #   		"resumeOnStart": true,
  #   		"hideMenu": true,
  #   		"hideMenuWarned": true,
  #       "themes": [
  #         "/home/ryan/.config/YouTube Music/theme.css"
  #       ]
  #   	},
  #   	"plugins": {
  #   		"notifications": {
  #   			"enabled": true
  #   		},
  #   		"video-toggle": {
  #   			"mode": "custom"
  #   		},
  #   		"precise-volume": {
  #   			"globalShortcuts": {}
  #   		},
  #   		"discord": {
  #   			"listenAlong": true,
  #   			"enabled": true,
  #   			"autoReconnect": true,
  #   			"activityTimeoutEnabled": true,
  #   			"activityTimeoutTime": 600000,
  #   			"playOnYouTubeMusic": true,
  #   			"hideGitHubButton": false,
  #   			"hideDurationLeft": false
  #   		},
  #   		"downloader": {
  #   			"enabled": true,
  #   			"downloadFolder": "/home/ryan/Downloads",
  #   			"selectedPreset": "mp3 (256kbps)",
  #   			"customPresetSetting": {
  #   				"extension": "mp3",
  #   				"ffmpegArgs": [
  #   					"-b:a",
  #   					"256k"
  #   				]
  #   			},
  #   			"skipExisting": false
  #   		},
  #   		"album-color-theme": {
  #   			"enabled": true
  #   		},
  #   		"album-actions": {
  #   			"enabled": true
  #   		},
  #   		"in-app-menu": {
  #   			"enabled": true
  #   		},
  #   		"music-together": {
  #   			"enabled": true
  #   		},
  #   		"lyrics-genius": {
  #   			"enabled": true
  #   		},
  #   		"sponsorblock": {
  #   			"enabled": true
  #   		},
  #   		"compact-sidebar": {
  #   			"enabled": false
  #   		}
  #   	},
  #   	"__internal__": {
  #   		"migrations": {
  #   			"version": "3.3.6"
  #   		}
  #   	}
  #   }
  # '';
  # home.file.".config/YouTube Music/theme.css".text = ''
  #   html:not(.style-scope) {
  #     --accentColor: #cba6f7;

  #     --dark-background: #181825;
  #     --dark-foreground: #1e1e2e;

  #     --light-foreground: #cdd6f4;
  #     --light-foreground-2: #bac2de;
  #     --light-foreground-3: #a6adc8;

  #     --scrollWidth: 0px;

  #     --idk-yet: inherit !important;

  #     --ytmusic-color-black1: var(--dark-foreground) !important;
  #     --ytmusic-color-black4: var(--dark-background) !important;

  #     --ytmusic-color-blackpure: var(--idk-yet) !important;
  #     --ytmusic-color-blackpure-alpha0: var(--idk-yet) !important;
  #     --ytmusic-color-blackpure-alpha10: var(--idk-yet) !important;
  #     --ytmusic-color-blackpure-alpha60: var(--idk-yet) !important;

  #     --ytmusic-color-grey1: var(--light-foreground-3) !important;
  #     --ytmusic-color-grey2: var(--light-foreground-2) !important;
  #     --ytmusic-color-grey3: var(--light-foreground) !important;
  #     --ytmusic-color-grey4: var(--light-foreground-3) !important;
  #     --ytmusic-color-grey5: var(--light-foreground) !important;

  #     --ytmusic-color-white1: var(--light-foreground) !important;
  #     --ytmusic-color-white1-alpha10: var(--light-foreground-3) !important;
  #     --ytmusic-color-white1-alpha15: var(--light-foreground-3) !important;
  #     --ytmusic-color-white1-alpha20: var(--light-foreground-3) !important;
  #     --ytmusic-color-white1-alpha30: var(--light-foreground-3) !important;
  #     --ytmusic-color-white1-alpha50: var(--light-foreground-3) !important;
  #     --ytmusic-color-white1-alpha70: var(--light-foreground) !important;

  #     --ytmusic-static-brand-red: var(--light-foreground) !important;

  #     /*loadingbar*/
  #     --yt-spec-themed-blue: var(--light-foreground-3) !important;
  #     --yt-spec-dark-blue: var(--light-foreground) !important;
  #     --yt-spec-text-secondary: var(--light-foreground) !important;
  #     --ytmusic-setting-item-toggle-active: var(--light-foreground-2) !important;

  #     --ytmusic-brand-link-text: var(--idk-yet) !important;
  #     --ytmusic-overlay-background-brand: var(--idk-yet) !important;
  #     --ytmusic-focus-active: var(--idk-yet) !important;

  #     --ytmusic-detail-header: var(--idk-yet) !important;
  #     --ytmusic-dialog-background-color: var(--dark-background) !important;
  #     --yt-spec-brand-link-text: var(--light-foreground) !important;

  #     --ytmusic-caption-1_-_color: var(--light-foreground) !important;

  #     --ytmusic-scrollbar-width: var(--scrollWidth) !important;
  #     --ytd-scrollbar-width: var(--scrollWidth) !important;
  #     --ytd-scrollbar-scrubber_-_background: var(---dark-background);
  #   }

  #   /*Unique to the desktop ytmdesktop app*/
  #   i.material-icons/*The icons they added; not present on the web version*/ {
  #     color: var(--light-foreground) !important;
  #   }
  #   i.material-icons:hover {
  #     color: var(--light-foreground) !important;
  #   }
  #   /*Unique to the desktop ytmdesktop app*/
  #   body {
  #     background: var(--dark-background) !important;
  #   }

  #   ytmusic-nav-bar {
  #     background: var(--dark-foreground) !important;
  #   }

  #   /*hide the youtube logo at the top left*/
  #   .yt-simple-endpoint[aria-label="Home"] {
  #     visibility: hidden !important;
  #   }

  #   /*Home, Explore, Library colors*/
  #   ytmusic-pivot-bar-item-renderer:hover,
  #     ytmusic-pivot-bar-item-renderer.iron-selected/*highlighted word*/ {
  #     color: var(--light-foreground-3) !important;
  #   }
  #   ytmusic-pivot-bar-item-renderer/*non-selected item*/ {
  #     color: var(--light-foreground-3) !important;
  #   }

  #   ytmusic-search-box,
  #   ytmusic-search-box *:not([id="placeholder"]) {
  #     color: var(--light-foreground) !important;
  #     --iron-icon-fill-color: var(--accentColor) !important;
  #   }

  #   ytmusic-search-box input::placeholder {
  #     color: var(--light-foreground-2) !important;
  #   }

  #   ytmusic-search-box #placeholder {
  #     color: var(--light-foreground-3) !important;
  #   }

  #   /*Next and previous button colors*/
  #   .ytmusic-search-box .navigation-icon .iron-icon .iron-icon path {
  #     color: var(--light-foreground-3) !important;
  #   }

  #   /*color 'new recommendations' pop-up*/
  #   a.ytmusic-content-update-chip {
  #     color: var(--ytmusic-color-black4) !important;
  #     background-color: var(--ytmusic-color-grey2) !important;
  #   }

  #   ytmusic-detail-header-renderer {
  #     background-color: var(--ytmusic-color-black4) !important;
  #   }

  #   .title.ytmusic-detail-header-renderer {
  #     color: var(--light-foreground) !important;
  #   }

  #   ytmusic-player-page {
  #     background-color: var(--ytmusic-color-black4) !important;
  #   }
  #   ytmusic-data-bound-header-renderer {
  #     background-color: var(--dark-foreground) !important;
  #   }
  #   ytmusic-list-item-renderer {
  #     background-color: var(--ytmusic-color-black1) !important;
  #   }
  #   ytmusic-responsive-list-item-renderer {
  #     background-color: var(--ytmusic-color-black1) !important;
  #   }
  #   ytmusic-player-queue-item {
  #     background-color: var(--ytmusic-color-black1) !important;
  #   }
  #   paper-tab.iron-selected.ytmusic-player-page/*Up Next color*/ {
  #     /*depriciated*/
  #     color: var(--light-foreground) !important;
  #   }
  #   tp-yt-paper-tab.iron-selected.ytmusic-player-page/*ammended up next color Update*/ {
  #     color: var(--light-foreground) !important;
  #   }
  #   tp-yt-paper-tab.ytmusic-player-page {
  #     color: var(--light-foreground) !important;
  #   }
  #   tp-yt-paper-toast {
  #     background-color: var(--dark-foreground) !important;
  #     color: var(--light-foreground);
  #   }

  #   paper-tabs.ytmusic-player-page/*up next line color*/ {
  #     --paper-tabs-selection-bar-color: var(--light-foreground) !important;
  #   }
  #   #selectionBar.tp-yt-paper-tabs/*ammended up next line color Update*/ {
  #     border-bottom: 2px solid var(--light-foreground) !important;
  #   }

  #   yt-formatted-string.byline.style-scope.ytmusic-player-queue-item/*artist part in queue*/ {
  #     color: var(--light-foreground) !important;
  #   }
  #   yt-formatted-string.duration.style-scope.ytmusic-player-queue-item/*length of songs in queue*/ {
  #     color: var(--light-foreground-3) !important;
  #   }

  #   /*color of the play bar background*/
  #   ytmusic-player-bar {
  #     background: var(--dark-foreground) !important;
  #   }

  #   /*color of the progressbar slider*/
  #   #progress-bar.ytmusic-player-bar {
  #     --paper-slider-active-color: var(--ytmusic-color-white1) !important;
  #   }
  #   #progress-bar.ytmusic-player-bar[focused],
  #   ytmusic-player-bar:hover #progress-bar.ytmusic-player-bar {
  #     --paper-slider-knob-color: var(--ytmusic-color-white1) !important;
  #     --paper-slider-knob-start-color: var(--ytmusic-color-white1) !important;
  #     --paper-slider-knob-start-border-color: var(
  #       --ytmusic-color-white1
  #     ) !important;
  #   }
  #   /*volume slider*/
  #   paper-slider#volume-slider {
  #     --paper-slider-container-color: var(--light-foreground-3) !important;
  #     --paper-slider-active-color: var(--light-foreground) !important;
  #     --paper-slider-knob-color: var(--light-foreground) !important;
  #   }
  #   .volume-slider.ytmusic-player-bar,
  #     .expand-volume-slider.ytmusic-player-bar/*ammended volume slider color for Update*/ {
  #     --paper-slider-container-color: var(--light-foreground-3) !important;
  #     --paper-slider-active-color: var(--light-foreground) !important;
  #     --paper-slider-knob-color: var(--light-foreground) !important;
  #   }

  #   /*play/pause/skip*/
  #   paper-icon-button#play-pause-button {
  #     --iron-icon-fill-color: var(--accentColor) !important;
  #   }
  #   tp-yt-iron-icon#icon/*ammended play-pause button colors for Update*/ {
  #     --iron-icon-fill-color: var(--accentColor) !important;
  #   }

  #   .left-controls.ytmusic-player-bar paper-icon-button.ytmusic-player-bar,
  #   .left-controls.ytmusic-player-bar .spinner-container.ytmusic-player-bar,
  #   .toggle-player-page-button.ytmusic-player-bar {
  #     --iron-icon-fill-color: var(--light-foreground) !important;
  #   }
  #   /*nav bar menu icon*/
  #   .menu.ytmusic-player-bar {
  #     --iron-icon-fill-color: var(--light-foreground) !important;
  #   }

  #   /*nav bar right button icon colors*/
  #   .right-controls-buttons.ytmusic-player-bar paper-icon-button.ytmusic-player-bar,
  #   ytmusic-player-expanding-menu.ytmusic-player-bar
  #     paper-icon-button.ytmusic-player-bar {
  #     --paper-icon-button_-_color: var(--light-foreground) !important;
  #   }

  #   .style-scope.yt-icon-button[aria-label="Add to playlist"]/*add to playlist button Update*/ {
  #     color: var(--light-foreground);
  #   }

  #   /*color of titles*/
  #   .title.ytmusic-carousel-shelf-basic-header-renderer,
  #   .autoplay.ytmusic-tab-renderer .title.ytmusic-tab-renderer,
  #   .song-title.ytmusic-player-queue-item,
  #   .content-info-wrapper.ytmusic-player-bar .title.ytmusic-player-bar,
  #   .text.ytmusic-menu-navigation-item-renderer,
  #   .text.ytmusic-menu-service-item-renderer,
  #   .text.ytmusic-toggle-menu-service-item-renderer {
  #     color: var(--light-foreground) !important;
  #   }

  #   /*Now playing circle*/
  #   div.content-wrapper.style-scope.ytmusic-play-button-renderer {
  #     background: var(--accentColor) !important;
  #   }

  #   /*lyrics*/
  #   .description.ytmusic-description-shelf-renderer {
  #     color: var(--light-foreground) !important;
  #   }

  #   /*subscribe button*/
  #   ytmusic-subscribe-button-renderer {
  #     --ytmusic-subscribe-button-color: var(--accentColor) !important;
  #   }

  #   yt-button-renderer[is-paper-button] {
  #     background-color: var(--ytmusic-color-white1-alpha70) !important;
  #   }

  #   paper-icon-button {
  #     --paper-icon-button_-_color: var(--ytmusic-color-white1) !important;
  #   }
  #   /*shuffle and radio buttons*/
  #   .play-button.ytmusic-immersive-header-renderer,
  #   .radio-button.ytmusic-immersive-header-renderer {
  #     background-color: var(--light-foreground) !important;
  #     color: var(--dark-foreground) !important;
  #   }
  #   /*add to library button*/
  #   ytmusic-data-bound-top-level-menu-item.ytmusic-data-bound-menu-renderer:not(:first-child) {
  #     --yt-button-color: var(--ytmusic-color-white1) !important;
  #     border: 1px solid var(--ytmusic-color-white1) !important;
  #     border-radius: 5px !important;
  #   }
  #   /*shuffle playlist button*/
  #   yt-button-renderer.watch-button.ytmusic-menu-renderer {
  #     color: var(--ytmusic-color-white1) !important;
  #     background-color: var(--ytmusic-color-white1-alpha70) !important;
  #   }
  #   /*edit playlist button*/
  #   #top-level-buttons.ytmusic-menu-renderer
  #     > .outline-button.ytmusic-menu-renderer,
  #   .edit-playlist-button.ytmusic-menu-renderer,
  #   ytmusic-toggle-button-renderer.ytmusic-menu-renderer {
  #     --yt-button-color: var(--ytmusic-color-white1) !important;
  #   }

  #   /*explicit badge*/
  #   yt-icon.ytmusic-inline-badge-renderer {
  #     color: var(--light-foreground) !important;
  #   }

  #   /*headers that aren't links*/
  #   .title.ytmusic-carousel-shelf-basic-header-renderer,
  #   .subtitle.ytmusic-tab-renderer,
  #   .icon.ytmusic-menu-navigation-item-renderer,
  #   .time-info.ytmusic-player-bar {
  #     color: var(--light-foreground-2) !important;
  #   }
  #   /*Songs header*/
  #   .title.ytmusic-header-renderer {
  #     color: var(--light-foreground-3) !important;
  #   }
  #   yt-formatted-string.strapline.text.style-scope.ytmusic-carousel-shelf-basic-header-renderer {
  #     color: var(--light-foreground-3) !important;
  #   }

  #   /*Links*/
  #   yt-formatted-string[has-link-only_]:not([force-default-style])
  #     a.yt-simple-endpoint.yt-formatted-string {
  #     color: var(--light-foreground) !important;
  #   }
  #   yt-formatted-string[has-link-only_]:not([force-default-style])
  #     a.yt-simple-endpoint.yt-formatted-string:hover {
  #     color: var(--light-foreground-2) !important;
  #   }
  #   .title.ytmusic-two-row-item-renderer {
  #     color: var(--light-foreground) !important;
  #   }

  #   .av-toggle.ytmusic-av-toggle {
  #     background-color: var(--dark-background) !important;
  #   }

  #   ytmusic-av-toggle[playback-mode="ATV_PREFERRED"]
  #     .song-button.ytmusic-av-toggle {
  #     color: var(--dark-foreground) !important;
  #   }

  #   ytmusic-av-toggle[playback-mode="OMV_PREFERRED"]
  #     .video-button.ytmusic-av-toggle {
  #     color: var(--dark-foreground) !important;
  #   }

  #   ytmusic-av-toggle[playback-mode="ATV_PREFERRED"]
  #     .video-button.ytmusic-av-toggle {
  #     background-color: var(--dark-foreground) !important;
  #     color: var(--light-foreground) !important;
  #   }

  #   ytmusic-av-toggle[playback-mode="OMV_PREFERRED"]
  #     .song-button.ytmusic-av-toggle {
  #     background-color: var(--dark-foreground) !important;
  #     color: var(--light-foreground) !important;
  #   }

  #   /* scroll left and right carousel buttons */
  #   .previous-items-button.ytmusic-carousel,
  #   .next-items-button.ytmusic-carousel {
  #     background-color: var(--ytmusic-color-white1-alpha70) !important;
  #     color: var(--ytmusic-color-black1) !important;
  #   }

  #   /* play button that pops up over album art to play immediately */
  #   .content-wrapper.ytmusic-play-button-renderer,
  #   ytmusic-play-button-renderer:hover
  #     .content-wrapper.ytmusic-play-button-renderer,
  #   ytmusic-play-button-renderer:focus
  #     .content-wrapper.ytmusic-play-button-renderer {
  #     background: var(--ytmusic-color-white1-alpha70) !important;
  #     --ytmusic-play-button-icon-color: var(--ytmusic-color-black1) !important;
  #     --paper-spinner-color: var(--yt-spec-themed-blue) !important;
  #   }

  #   /* like button color */
  #   paper-icon-button.ytmusic-like-button-renderer {
  #     color: var(--light-foreground) !important;
  #   }

  #   /*settings highlighted*/
  #   .category-menu-item.iron-selected.ytmusic-settings-page {
  #     background-color: var(--light-foreground) !important;
  #   }

  #   /* some dropdown menus*/
  #   .dropdown-content {
  #     background-color: var(--dark-foreground) !important;
  #   }

  # '';
}
