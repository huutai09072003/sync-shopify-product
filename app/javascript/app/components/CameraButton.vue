<template>
  <div class="pic-it-camera-options">
    <template v-if="hasCameraOptions">
      
      <div v-if="livePreview" @click="disableLivePreview" class="pic-it-button">
        <div class="pic-it-button__text">
          Live View Off
        </div>
        <i class="fal fa-video-slash"></i>
      </div>

      <div v-else @click="toggleCameraOptions" class="pic-it-button">
        <div class="pic-it-button__text">
          Set image
        </div>
        <i class="pic-it-button__icon">
          <svg height="20" viewBox="0 0 20 20" width="20" xmlns="http://www.w3.org/2000/svg"><g fill="none" fill-rule="evenodd" stroke="currentColor" stroke-width="1.5"><path d="m1.5 3.5h17v13h-17z"/><path d="m2 11.763 3.018-2.263 4 3 2-1 2 1h5" transform="matrix(-1 0 0 1 20.018 0)"/><circle cx="6" cy="7.5" r="1.25"/></g></svg>
        </i>
      </div>
    </template>
    <template v-else>
      <image-uploader />
    </template>
  </div>
</template>
<script>
import { mapGetters } from "vuex"
import ImageUploader from "../components/ImageUploader"

export default {

  components: { ImageUploader },

  computed: {
    ...mapGetters(['showCameraOptions', 'livePreviewCapable', 'touchscreen', 'livePreview']),

    hasCameraOptions: function() {
      return this.livePreviewCapable && this.touchscreen;
    }
  },

  methods: {
    toggleCameraOptions() {
      const self = this;
      this.$store.dispatch('setState', ['showCameraOptions', !self.showCameraOptions])
    },

    disableLivePreview () {
      this.$store.dispatch('setState', ['livePreview', false])
    }
  }
}
</script>
