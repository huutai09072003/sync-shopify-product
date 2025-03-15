<template>
  <button @click='handleSave' class="pic-it-button pic-it-button--save-image" :disabled="savable == false">
    <div class='pic-it-button__text'>
      {{ $t('buttons.save') }}
    </div>
    <i class="pic-it-button__icon">
      <svg height="20" viewBox="0 0 20 20" width="20" xmlns="http://www.w3.org/2000/svg"><g fill="none" fill-rule="evenodd" stroke="currentColor" stroke-width="1.5"><path d="m10 3.5v10.006m3.884-3.5-3.884 3.5-3.885-3.501"/><path d="m3 14.5v1c0 .5522847.44771525 1 1 1h12c.5522847 0 1-.4477153 1-1v-1"/></g></svg>
    </i>
  </button>
</template>
<script>
import html2canvas from 'html2canvas'
import download from 'downloadjs'
import { mapGetters } from 'vuex'

export default {
  data() {
    return {
      saving: false,
    }
  },

  computed: {
    ...mapGetters(['livePreview', 'rotateY', 'rotateZ']),

    savable: function() {
      if (this.livePreview) {
        return this.rotateY == 0 && this.rotateZ == 0;
      } else {
        true
      }
    },

    filename: function() {
      let name = 'preview.png'
      try {
        name = window.pictureItApp.item.title.toLowerCase().replace(' ', '-') + '-preview.png';
      } catch(ign) {}
      return name;
    }
  },

  methods: {
    handleSave() {
      const self = this;
      if (this.saving) {
        return;
      }
      this.saving = true;

      this.$store.dispatch('setState', ['showTransform', false])
      this.$store.dispatch('setState', ['loading', true]);

      if (this.livePreview) {
        this.imageWithVideoBackgroundDownload();
      } else {
        this.imageWithStaticBackgroundDownload();
      }
    },

    imageWithVideoBackgroundDownload() {
      const self = this;

      var video = document.querySelector('#camera-stream'),
          item = document.querySelector('#scale-element'),
          hidden_canvas = document.querySelector('#blank-canvas'),
          context = hidden_canvas.getContext('2d');

      var width = video.videoWidth,
          height = video.videoHeight;

      if (width && height) {
        let item_position = item.getBoundingClientRect();
        let video_position = video.getBoundingClientRect();

        // Setup a canvas with the same dimensions as the video.
        hidden_canvas.width = window.innerWidth;
        hidden_canvas.height = window.innerHeight;

        // Make a copy of the current frame in the video on the canvas.
        context.drawImage(video, video_position.left, video_position.top, video_position.width, video_position.height)

        let item_image = new Image();
        item_image.src = item.getAttribute('src');
        item_image.crossOrigin = "anonymous";
        item_image.onload = function(){
          // Draw item on to canvas
          context.drawImage(item_image, item_position.left, item_position.top, item_position.width, item_position.height)

          // Turn the canvas image into a dataURL that can be used as a src for our photo.
          var snap =  hidden_canvas.toDataURL('image/png');
          download(snap, self.filename);
          self.saving = false;
          self.$store.dispatch('setState', ['loading', false]);
          window.picture_it_app_vmessage.$emit('track', 'download');
        }
      }
    },

    imageWithStaticBackgroundDownload() {
      const self = this;

      // seen instances of item's image not showing up on download - this fail-safe #1
      let item = document.querySelector('#scale-element')
      let zIndex = window.getComputedStyle(item).getPropertyValue('z-index');
      item.style.zIndex = '1000'; // ensure it on top for html2canvas

      html2canvas(document.getElementById('picture-it-app-container')).then(function(canvas) {

        // seen instances of item's image not showing up on download - this fail-safe #2
        if (window.pictureItApp.browser && window.pictureItApp.browser.os == 'ios') {
          let context = canvas.getContext('2d');
          let item = document.querySelector('#scale-element')
          let item_position = item.getBoundingClientRect();
          let item_image = new Image();
          item_image.src = item.getAttribute('src');
          item_image.crossOrigin = "anonymous";
          item_image.onload = function(){
            context.drawImage(item_image, item_position.left, item_position.top, item_position.width, item_position.height)
          }
        }

        setTimeout(function() {
          var dataUrl = canvas.toDataURL('image/png');
          download(dataUrl, self.filename);

          self.saving = false;
          self.$store.dispatch('setState', ['loading', false]);
          item.style.zIndex = zIndex;
          window.picture_it_app_vmessage.$emit('track', 'download');
        }, 1000)
      });
  }
  }
}
</script>
