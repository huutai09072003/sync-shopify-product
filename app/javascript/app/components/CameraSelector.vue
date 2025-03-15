<template>
  <div>
    <div v-show="showCameraOptions" class="pic-it-button-group pic-it-button-group--right">
      <div @click='toggleCameraOptions' class="pic-it-button pic-it-button--with-mobile-text">
        <div class="pic-it-button__text">
          {{ $t('buttons.cancel') }}
        </div>
        <i class="pic-it-button__icon">
          <svg height="20" viewBox="0 0 20 20" width="20" xmlns="http://www.w3.org/2000/svg"><g fill="none" fill-rule="evenodd" stroke="currentColor" stroke-width="1.5"><path d="m5 15 10-10"/><path d="m5 5 10 10"/></g></svg>
        </i>
      </div>
    </div>

    <transition name="slide">
      <div v-show="showCameraOptions">
        <div class="pic-it-camera-selector">
          <div @click='toggleLivePreview' class="pic-it-button pic-it-button--with-mobile-text">
            <div class="pic-it-button__text">
              {{ $t('buttons.live_view') }}
            </div>
            <i class="fal fa-vr-cardboard"></i>
          </div>

          <image-uploader :label="$t('buttons.photo_or_upload')" />

        </div>
      </div>
    </transition>
  </div>
</template>
<script>
import { mapGetters } from 'vuex'      
import ImageUploader from "../components/ImageUploader"
  

export default {
  
  components: { ImageUploader },

  computed: {
    ...mapGetters(['showCameraOptions'])
  },

  methods: {
    toggleCameraOptions() {
      const self = this;
      this.$store.dispatch('setState', ['showCameraOptions', !self.showCameraOptions])
    },

    toggleLivePreview () {
      const self = this;
      if (!self.livePreview) {
        this.$store.dispatch('setState', ['backgroundImage', ''])  
      }

      this.toggleCameraOptions();

      this.$store.dispatch('setState', ['livePreview', !self.livePreview])
    }
  }
}
</script>
