<template>
  <div class="pic-it-main">
    <div class="pic-it-main__content">
      <ar-preview-qr-code />
    </div>
  </div>
</template>
<script>
import { mapGetters } from "vuex";
import Loader from "./components/Loader";
import LayoutHeader from "./layout/Header";
import LayoutBodyStatic from "./layout/BodyStaticBg";
import LayoutBodyAr from "./layout/BodyAR";
import LayoutFooter from "./layout/Footer";

import Debug from "./debug";
import ArPreviewQrCode from "./components/ArPreviewQrCode";

export default {
  components: {
    Loader,
    LayoutHeader,
    LayoutBodyStatic,
    LayoutBodyAr,
    LayoutFooter,
    ArPreviewQrCode,
  },

  data() {
    return {
      show_options: true,
      current_path: window.location.pathname,
    };
  },

  watch: {
    show_options: function (state) {
      this.$store.dispatch("setState", ["showBackgroundOptions", !state]);
    },
  },

  created() {
    if (window.pictureItApp && window.pictureItApp.config) {
      this.$store.dispatch("setState", ["config", window.pictureItApp.config]);

      if (
        window.pictureItApp.config.preferences &&
        window.pictureItApp.config.preferences.preview_show_full_background !== undefined
      ) {
        this.$store.dispatch("setState", [
          "showFullBackground",
          window.pictureItApp.config.preferences.preview_show_full_background,
        ]);
      }
    }

    if (window.pictureItApp && window.pictureItApp.item) {
      this.$store.dispatch("setState", ["item", window.pictureItApp.item]);
    }

    if (window.pictureItApp && window.pictureItApp.parentUrl) {
      this.$store.dispatch("setState", [
        "parentUrl",
        window.pictureItApp.parentUrl.replace(/&amp;/g, "&"),
      ]);
    }

    // Set locale of app
    this.$i18n.locale = this.config.language;

    let htmlTagDirection = "ltr";
    if (["ar"].includes(this.config.language)) {
      htmlTagDirection = "rtl";
    }
    this.$store.dispatch("setState", ["htmlTagDirection", htmlTagDirection]);

    const touchscreen =
      "ontouchstart" in window || navigator.MaxTouchPoints > 0 || navigator.msMaxTouchPoints > 0;

    if ("mediaDevices" in navigator && "getUserMedia" in navigator.mediaDevices) {
      this.$store.dispatch("setState", ["livePreviewCapable", true]);
      Debug.log("Let's get this party started");
    } else {
      this.$store.dispatch("setState", ["livePreviewCapable", false]);
      Debug.log("mediaDevices && getUserMedia not found");
    }

    // old school - probably don't need this one (or fully support it)
    let videoSupported =
      navigator.getUserMedia ||
      navigator.webkitGetUserMedia ||
      navigator.mozGetUserMedia ||
      navigator.msGetUserMedia;
    if (!videoSupported) {
      Debug.log("No old school support");
    }

    this.$store.dispatch("setState", ["touchscreen", touchscreen]);

    window.picture_it_app_vmessage.$on("track", (event) => {
      this.track(event);
    });

    this.track("preview");

    this.addCssTextToHead(this.config.preferences.custom_css);
  },

  computed: {
    ...mapGetters([
      "config",
      "livePreview",
      "loading",
      "touchscreen",
      "item",
      "livePreviewCapable",
    ]),
  },

  methods: {
    track(event) {
      Debug.log("Picture It: tracking", event);
      let paramsString = "?";
      paramsString += `event_type=${event}`;
      paramsString += `&product_id=${this.item.external_id}`;
      this.$http.get(`${this.config.api_url}/events/new${paramsString}`);
    },

    addCssTextToHead(cssText) {
      var head = document.head || document.getElementsByTagName("head")[0];
      var style = document.createElement("style");
      style.type = "text/css";
      if (style.styleSheet) {
        style.styleSheet.cssText = cssText;
      } else {
        style.appendChild(document.createTextNode(cssText));
      }
      head.appendChild(style);
    },
  },
};
</script>
