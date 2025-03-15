<template>
  <div class="pic-it-qr__wrapper">
    <a
      href=""
      id="ar-hook"
      rel="ar"
      class="ar-modal-button"
      style="display: none"
      ref="previewArModal"
      download=""
    >
      <img class="ar-button-bg-img" id="ar-img" loading="eager" style="display: none" />
      <div style="text-decoration: none !important; padding: 0px 30px">Preview in AR</div>
    </a>

    <transition name="fade">
      <div v-if="showNotificationBlock" class="notification">
        <img src="../assets/notify-image.jpg" class="notification-image" />
        <div @click="closeQrCode" class="notification-icon">
          <svg height="20" viewBox="0 0 20 20" width="20" xmlns="http://www.w3.org/2000/svg">
            <g fill="none" fill-rule="evenodd" stroke="currentColor" stroke-width="1.5">
              <path d="m5 15 10-10" />
              <path d="m5 5 10 10" />
            </g>
          </svg>
        </div>

        <div class="notification-wrap">
          <div class="notification-title">{{ $t("notification.title") }}</div>
          <div v-if="!isWebView">
            <div class="notification-description">{{ $t("notification.description") }}</div>
            <div class="notification-button" @click="toggleArPreview">
              {{ $t("notification.button") }}
            </div>
          </div>

          <div v-else class="notification-internal">
            <div>{{ $t("notification.internal") }}</div>
          </div>
        </div>
      </div>
    </transition>

    <transition name="fade">
      <div class="qr-code-preview" v-if="qrCodeData.show">
        <div class="qr-code-preview__container">
          <div class="qr-code-preview__text">
            <div class="qr-code-preview__title-wrapper">
              <div class="qr-code-preview__title-text">
                <p class="qr-code-preview__title" :dir="htmlTagDirection">
                  {{ $t("ar_preview_toggle.qr_code_title") }}
                </p>
              </div>
              <div class="pic-it-button__qr pic-it-button--icon-only" @click="closeQrCode">
                <i class="pic-it-button__icon">
                  <svg
                    height="20"
                    viewBox="0 0 20 20"
                    width="20"
                    xmlns="http://www.w3.org/2000/svg"
                  >
                    <g fill="none" fill-rule="evenodd" stroke="currentColor" stroke-width="1.5">
                      <path d="m5 15 10-10" />
                      <path d="m5 5 10 10" />
                    </g>
                  </svg>
                </i>
              </div>
            </div>
            <p class="qr-code-preview__description">
              {{ $t("ar_preview_toggle.qr_code_description") }}
            </p>
          </div>

          <vue-qrcode :value="qrCodeData.url" :options="{ width: 200 }"></vue-qrcode>
        </div>
      </div>
    </transition>
  </div>
</template>
<script>
import { mapGetters } from "vuex";
import VueQrcode from "@chenfengyuan/vue-qrcode";
import * as THREE from "three";
import { GLTFExporter } from "three/examples/jsm/exporters/GLTFExporter.js";
import { USDZExporter } from "three/examples/jsm/exporters/USDZExporter.js";

import axios from "axios";

const arData = {
  modelUrl: null,
  downloadFileType: null,
};

export default {
  components: {
    VueQrcode,
  },
  computed: {
    ...mapGetters(["config", "item", "parentUrl", "htmlTagDirection"]),
  },
  data() {
    return {
      showNotificationBlock: false,
      qrCodeData: {
        show: false,
        url: "",
      },
      exportingArModel: false,
      isWebView: this.checkIfWebView(),
    };
  },
  async mounted() {
    window.addEventListener("message", this.handleMessage);

    if (this.isDeskTop()) {
      this.toggleArPreview();
    } else {
      this.showNotificationBlock = true;
    }
  },

  methods: {
    checkIfWebView() {
      const userAgent = window.navigator.userAgent || window.navigator.vendor || window.opera;
      return (
        /wv|WebView|Crosswalk|FBAN|FBAV|Instagram/i.test(userAgent) ||
        !/Safari|Chrome|Chromium|Opera|Firefox/i.test(userAgent)
      );
    },
    handleMessage(event) {
      if (event.data.type !== "font-styles-for-child-window") return;

      document.body.style.fontFamily = event.data.fontBodyFamily;
    },
    isIOS() {
      return /iPad|iPhone|iPod/.test(navigator.userAgent) && !window.MSStream;
    },
    isAndroid() {
      return /Android/.test(navigator.userAgent);
    },
    isDeskTop() {
      return !this.isIOS() && !this.isAndroid();
    },
    showArModal(arModelUrl, downloadFileType) {
      const previewArModal = this.$refs.previewArModal;
      previewArModal.href = arModelUrl;
      previewArModal.download = `asset.${downloadFileType}`;
      previewArModal.click();

      setTimeout(() => {
        this.closeQrCode();
      }, 100);
    },
    showQrCode() {
      let result = "";
      if (this.parentUrl) {
        const url = new URL(this.parentUrl);
        url.searchParams.set("view_in_room", "true");
        result = url.toString();
      }

      this.qrCodeData = {
        show: true,
        url: result,
      };
    },
    closeQrCode() {
      parent.postMessage("pitcure-it-close-modal", "*");
    },
    async showArModelWithDataGetFromItem() {
      if (this.exportingArModel) {
        return;
      }

      this.exportingArModel = true;

      if (this.isIOS()) {
        const response = await axios({
          url: this.item.usdz_url,
          method: "GET",
          responseType: "blob", // Important for dealing with binary data
        });
        const blob = new Blob([response.data], { type: "model/vnd.usdz+zip" });
        const modelUrl = URL.createObjectURL(blob);

        arData.modelUrl = modelUrl;
        arData.downloadFileType = "usdz";
      } else if (this.isAndroid()) {
        arData.modelUrl = this.generateAndroidARIntent(this.item.gltf_url);
        arData.downloadFileType = "gltf";
      }

      this.exportingArModel = false;
      this.showArModal(arData.modelUrl, arData.downloadFileType);
    },
    toggleArPreview() {
      if (this.isDeskTop()) {
        this.showQrCode();
      } else {
        if (arData.modelUrl) {
          this.showArModal(arData.modelUrl, arData.downloadFileType);
        } else if (this.item.gltf_url && this.item.usdz_url) {
          this.showArModelWithDataGetFromItem();
        } else {
          this.exportArModel();
        }
      }
    },
    exportArModel() {
      if (this.exportingArModel) {
        return;
      }

      this.exportingArModel = true;

      // Get the image URL from the global variable
      const imageUrl = window.pictureItApp.itemFeaturedImageURL;
      if (!imageUrl) {
        console.error("No image found");
        this.exportingArModel = false;
        return;
      }

      // Create a scene
      const scene = new THREE.Scene();

      // Load the image texture
      const textureLoader = new THREE.TextureLoader();
      textureLoader.load(imageUrl, (texture) => {
        // Once the texture is loaded, create a plane geometry with dimensions matching the image aspect ratio
        const aspectRatio = texture.image.width / texture.image.height;
        let imageWidth = 0.2 * aspectRatio; // default width is 0.2 meters * aspect ratio
        let imageHeight = 0.2; // default height is 0.2 meters
        if (this.item.width_in_mm && this.item.height_in_mm) {
          imageWidth = this.item.width_in_mm / 1000;
          imageHeight = this.item.height_in_mm / 1000;
        }
        const geometry = new THREE.PlaneGeometry(imageWidth, imageHeight); // the dimensions are in meters

        // Apply image as texture
        const material = new THREE.MeshStandardMaterial({
          map: texture,
          transparent: true, // Enable transparency
          opacity: 1, // Adjust opacity level, 0 is fully transparent and 1 is fully opaque
        });
        const plane = new THREE.Mesh(geometry, material);
        scene.add(plane);

        // Create a camera
        const camera = new THREE.PerspectiveCamera(
          75,
          window.innerWidth / window.innerHeight,
          0.1,
          1000,
        );
        camera.position.z = 2;

        // Create a renderer
        const renderer = new THREE.WebGLRenderer();
        renderer.setSize(window.innerWidth, window.innerHeight);

        // Render the scene with the camera
        const animate = () => {
          requestAnimationFrame(animate);
          renderer.render(scene, camera);
        };
        animate();

        this.exportToGLTF(scene);
        this.exportToUSDZ(scene);
      });
    },
    generateAndroidARIntent(modelUrl) {
      const encodedModelUrl = encodeURIComponent(modelUrl);
      return `intent://arvr.google.com/scene-viewer/1.0?file=${encodedModelUrl}&mode=ar_preferred#Intent;scheme=https;package=com.google.ar.core;action=android.intent.action.VIEW;end`;
    },
    async exportToGLTF(scene) {
      const self = this;
      const exporter = new GLTFExporter();
      await exporter.parse(
        scene,
        (gltf) => {
          const gltfString = JSON.stringify(gltf);
          const blob = new Blob([gltfString], { type: "model/gltf+json" });
          const downloadFileType = "gltf";

          self.saveARModel(blob, downloadFileType, (response) => {
            const gltf_url = response.data.gltf_url;
            self.$store.dispatch("setState", ["item", { ...self.item, gltf_url }]);

            if (self.isAndroid()) {
              const modelUrl = self.generateAndroidARIntent(gltf_url);

              arData.modelUrl = modelUrl;
              arData.downloadFileType = downloadFileType;
              self.exportingArModel = false;
              self.showArModal(arData.modelUrl, arData.downloadFileType);
            }
          });
        },
        {},
      );
    },
    async exportToUSDZ(scene) {
      const self = this;
      const exporter = new USDZExporter();
      const arrayBuffer = await exporter.parse(scene);
      const blob = new Blob([arrayBuffer], { type: "model/vnd.usdz+zip" });
      const modelUrl = URL.createObjectURL(blob);
      const downloadFileType = "usdz";

      if (self.isIOS()) {
        arData.modelUrl = modelUrl;
        arData.downloadFileType = downloadFileType;
        self.exportingArModel = false;
        self.showArModal(arData.modelUrl, arData.downloadFileType);
      }

      self.saveARModel(blob, downloadFileType, (response) => {
        const usdz_url = response.data.usdz_url;
        self.$store.dispatch("setState", ["item", { ...self.item, usdz_url }]);
      });
    },
    saveARModel(blob, fileType, callback) {
      const productId = this.item.ar_product_id;
      if (!productId) {
        console.error("No AR product ID found");
        return;
      }

      const formData = new FormData();
      const fileParamsName = fileType === "usdz" ? "usdz_file" : "gltf_file";
      formData.append(fileParamsName, blob, `picture_it_product_${productId}_model.${fileType}`);
      formData.append("product_id", productId);
      const token = document.querySelector('meta[name="csrf-token"]').content;
      formData.append("authenticity_token", token);

      const endpoint = fileType === "usdz" ? "upload_usdz_file" : "upload_gltf_file";
      axios
        .post(`/augmented_realities/${endpoint}`, formData, {
          headers: {
            "Content-Type": "multipart/form-data",
          },
        })
        .then((response) => {
          callback(response);
        })
        .catch((error) => {
          this.exportingArModel = false;
          console.error("Error generating USDZ file:", error);
        });
    },
  },
};
</script>
