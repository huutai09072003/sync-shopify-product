<template>
  <div class="pic-it-main">
    <div class="pic-it-main__content">
      <loader />

      <!-- <div class="picture-it-main-options-toggle">
        <span @click="show_options=!show_options" class="picture-it-main-options-toggle-label" v-html="show_options ? 'Hide Controls' : 'Show Controls'"></span>
        <el-switch v-model="show_options"></el-switch>
      </div> -->

      <layout-header>
        <div class="pic-it-header__toggle">
          <!-- <div class="picture-it-toggle__label" @click="show_options = !show_options" v-html="show_options ? 'Hide Controls' : 'Show Controls'"></div>
          <el-switch v-model="show_options"></el-switch> -->

          <!-- <o-toggle v-model="show_options" label="Show interface"></o-toggle> -->
          <pic-it-toggle v-model="show_options" :label="$t('toggles.interface')"></pic-it-toggle>
        </div>

        <!-- <span @click="show_options=!show_options" class="picture-it-main-options-toggle-label" v-html="show_options ? 'Hide Controls' : 'Show Controls'"></span>
        <el-switch v-model="show_options"></el-switch> -->
      </layout-header>

      <layout-body-ar v-if="livePreview" />
      <layout-body-static :current_path="current_path" v-else />

      <layout-footer v-if="!loading && show_options" />
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

export default {
  components: { Loader, LayoutHeader, LayoutBodyStatic, LayoutBodyAr, LayoutFooter },

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

  async mounted() {
    window.addEventListener("message", this.handleMessage);
  },

  methods: {
    handleMessage(event) {
      if (event.data.type !== "font-styles-for-child-window") return;

      document.body.style.fontFamily = event.data.fontBodyFamily;

      if (event.data.fontBodyFamily) {
        const buttons = document.querySelectorAll(".pic-it-button");
        buttons.forEach((button) => {
          button.style.fontFamily = event.data.fontBodyFamily;
        });
      }
    },

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
