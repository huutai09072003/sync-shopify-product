<template>
  <div class="pic-it-button--upload__wrapper">
    <label class="pic-it-button pic-it-button--upload" for="uploader">
      <div class="pic-it-button__text">
        {{ text }}
      </div>
      <!-- <i class="fal fa-camera" :class="iconClass"></i> -->
      <i class="pic-it-button__icon">
        <svg height="20" viewBox="0 0 20 20" width="20" xmlns="http://www.w3.org/2000/svg"><g fill="none" fill-rule="evenodd" stroke="currentColor" stroke-width="1.5"><path d="m1.5 3.5h17v13h-17z"/><path d="m2 11.763 3.018-2.263 4 3 2-1 2 1h5" transform="matrix(-1 0 0 1 20.018 0)"/><circle cx="6" cy="7.5" r="1.25"/></g></svg>
      </i>
    </label>
    <input ref="uploader" id="uploader" type="file" accept="image/*"
      @change="onFilesChange"
      data-direct-upload-url="/api/v1/direct_uploads"
      direct_upload="true"
      class="hidden" 
    />
  </div>
</template>
<script>
// https://edgeguides.rubyonrails.org/active_storage_overview.html#direct-uploads
import { DirectUpload } from "@rails/activestorage" 
import { mapGetters } from "vuex"

export default {

  props: ['label', 'icon'],

  computed: {
    ...mapGetters(['config', 'touchscreen']),

    text: function() {
      if (this.label) {
        return this.label;
      }

      // if (this.touchscreen) {
      //   return 'Set image'
      // }
        
      return this.$t('buttons.upload');
    },

    iconClass: function() {
      if (this.icon) {
        return this.icon;
      }

      if (!this.touchscreen) {
        return 'fa-image'
      }
        
      return 'fa-camera';
    }

  },

  methods: {
    onFilesChange() {
      let input = this.$refs.uploader
      Array.from(input.files).forEach(file => this.uploadFile(file))
    },

    uploadFile(file) {
      this.$store.dispatch('setState', ['loading', true]);

      let input = this.$refs.uploader;
      const url = input.dataset.directUploadUrl;

      const upload = new DirectUpload(file, url);

      upload.create((error, blob) => {
        if (error) {
          // Handle the error
        } else {      
          let newBgImage = `${this.config.proxy_url}/p?u=${this.config.cdn_url}/${blob.key}`
          
          this.$store.dispatch('addImage', newBgImage)
          this.$store.dispatch('setState', ['backgroundImage', { src: newBgImage, width_in_mm: null }])
          this.$store.dispatch('setState', ['showCameraOptions', false])

          window.picture_it_app_vmessage.$emit('track', 'upload')
        }
      })
    }
  }
}
</script>
