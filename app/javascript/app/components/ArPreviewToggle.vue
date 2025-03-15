<template>
  <div class="pic-it-button__wrapper">
    <template>
      <div
        @click="toggleArPreview"
        class="pic-it-button pic-it-button--live-preview"
        :disabled="exportingArModel && !isDeskTop()"
        v-loading="exportingArModel && !isDeskTop()"
      >
        <div class="pic-it-button__text">
          {{ $t("ar_preview_toggle.view_in_room") }}
        </div>
        <i class="pic-it-button__icon">
          <svg
            width="16"
            height="16"
            viewBox="0 0 16 16"
            fill="none"
            xmlns="http://www.w3.org/2000/svg"
          >
            <path
              d="M7.24932 3.2763L4.16553 4.98808C3.92503 5.12228 3.7248 5.31837 3.58561 5.55602C3.44643 5.79368 3.37335 6.06424 3.37397 6.33965V9.6603C3.37335 9.93571 3.44643 10.2063 3.58561 10.4439C3.7248 10.6816 3.92503 10.8777 4.16553 11.0119L7.24932 12.7237C7.4789 12.8514 7.73729 12.9185 8.00002 12.9185C8.26276 12.9185 8.52114 12.8514 8.75072 12.7237L11.8345 11.0119C12.075 10.8777 12.2752 10.6816 12.4144 10.4439C12.5536 10.2063 12.6267 9.93571 12.6261 9.6603V6.33965C12.6267 6.06424 12.5536 5.79368 12.4144 5.55602C12.2752 5.31837 12.075 5.12228 11.8345 4.98808L8.75072 3.2763C8.52114 3.14854 8.26276 3.08148 8.00002 3.08148C7.73729 3.08148 7.4789 3.14854 7.24932 3.2763Z"
              stroke="#4A4A4A"
              stroke-width="1.5"
            />
            <path
              d="M12.3128 5.40962L8.00001 8M8.00001 8L3.68726 5.40962M8.00001 8V12.9144"
              stroke="#4A4A4A"
              stroke-width="1.5"
            />
            <path
              d="M15 4.88897V3.33308C15 2.71431 14.7542 2.12088 14.3167 1.68334C13.8791 1.24581 13.2857 1 12.6669 1H10.3331M10.3331 15H12.6669C13.2857 15 13.8791 14.7542 14.3167 14.3167C14.7542 13.8791 15 13.2857 15 12.6669V11.1103M1 11.111V12.6669C1 13.2857 1.24581 13.8791 1.68334 14.3167C2.12088 14.7542 2.71431 15 3.33308 15H5.66692M5.66692 1H3.33308C2.71431 1 2.12088 1.24581 1.68334 1.68334C1.24581 2.12088 1 2.71431 1 3.33308V4.88973"
              stroke="#4A4A4A"
              stroke-width="1.5"
              stroke-linecap="round"
              stroke-linejoin="round"
            />
          </svg>
        </i>
      </div>
    </template>

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
      <div class="qr-code-modal" v-if="qrCodeData.show">
        <div class="qr-code-modal__container">
          <div class="pic-it-button pic-it-button--icon-only" @click="closeQrCode">
            <i class="pic-it-button__icon">
              <svg height="20" viewBox="0 0 20 20" width="20" xmlns="http://www.w3.org/2000/svg">
                <g fill="none" fill-rule="evenodd" stroke="currentColor" stroke-width="1.5">
                  <path d="m5 15 10-10" />
                  <path d="m5 5 10 10" />
                </g>
              </svg>
            </i>
          </div>
          <div class="qr-code-modal__text">
            <p class="qr-code-modal__title" :dir="htmlTagDirection">
              {{ $t("ar_preview_toggle.qr_code_title") }}
            </p>
            <p class="qr-code-modal__description">
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
      qrCodeData: {
        show: false,
        url: "",
      },
      exportingArModel: false,
    };
  },
  async mounted() {
    if (this.parentUrl) {
      const parentSearchParams = new URL(this.parentUrl).searchParams;
      const viewInRoom = parentSearchParams.get("view_in_room");
      if (viewInRoom === "true") {
        this.toggleArPreview();
      }
    }
  },
  // watch: {
  //   item: (newVal, oldVal) => {
  //     console.log('item', {
  //       newVal,
  //       oldVal
  //     });
  //   }
  // },
  methods: {
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
      this.qrCodeData.show = false;
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
