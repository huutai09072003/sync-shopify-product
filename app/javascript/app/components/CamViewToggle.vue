<template>
  <div class="pic-it-button__wrapper">
    <div @click='toggleLivePreview' class="pic-it-button pic-it-button--live-preview">
      <template v-if='livePreview'>
        <div class="pic-it-button__text">
          {{ $t('buttons.backgrounds') }}
        </div>
        <i class="pic-it-button__icon">
          <svg height="20" viewBox="0 0 20 20" width="20" xmlns="http://www.w3.org/2000/svg">
            <g fill="none" fill-rule="evenodd" stroke="currentColor" stroke-width="1.5">
              <path d="m1.5 3.5h17v13h-17z" />
              <path d="m2 11.763 3.018-2.263 4 3 2-1 2 1h5" transform="matrix(-1 0 0 1 20.018 0)" />
              <circle cx="6" cy="7.5" r="1.25" />
            </g>
          </svg>
        </i>
      </template>
      <template v-else>
        <div class="pic-it-button__text">
          {{ $t('buttons.live_preview') }}
        </div>
        <i class="pic-it-button__icon">
          <svg height="20" viewBox="0 0 20 20" width="20" xmlns="http://www.w3.org/2000/svg">
            <g fill="none" fill-rule="evenodd" stroke="currentColor" stroke-width="1.5">
              <circle cx="10" cy="10.562" r="3.75" />
              <path
                d="m3.20710678 5h1.79289322l.3506975-1.05209251c.09818562-.29455685.26360332-.56220831.48315304-.78175803l.16614946-.16614946c.32014462-.32014462.75435391-.5 1.20710678-.5h5.58578642c.4527529 0 .8869622.17985538 1.2071068.5l.1661495.16614946c.2195497.21954972.3849674.48720118.483153.78175803l.3506975 1.05209251h2.125c.3934466 0 .763932.1852427 1 .5.2434165.32455532.375.71930585.375 1.125v9.25c0 .4056942-.1315835.8004447-.375 1.125-.236068.3147573-.6065534.5-1 .5h-13.91789322c-.45275287 0-.88696216-.1798554-1.20710678-.5s-.5-.7543539-.5-1.2071068v-9.08578642c0-.45275287.17985538-.88696216.5-1.20710678s.75435391-.5 1.20710678-.5z"
                stroke-linejoin="round" />
            </g>
          </svg>
        </i>
      </template>
    </div>

    <transition name="fade">
      <div class="qr-code-modal" v-show=showQrCode>
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
            <p class="qr-code-modal__title">Preview on your wall</p>
            <p class="qr-code-modal__description">To view this in your room, start by scanning the QR code below</p>
          </div>
          <vue-qrcode :value="parentUrl" :options="{ width: 200 }"></vue-qrcode>
        </div>
      </div>
    </transition>
  </div>
</template>
<script>
import { mapGetters } from 'vuex';
import VueQrcode from '@chenfengyuan/vue-qrcode';

export default {
  components: {
    VueQrcode
  },
  computed: {
    ...mapGetters(['livePreview', 'parentUrl'])
  },

  data() {
    return {
      showQrCode: false
    }
  },

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
    closeQrCode() {
      this.showQrCode = false
    },
    toggleLivePreview() {
      const self = this;

      if (this.isDeskTop()) {
        this.showQrCode = !this.showQrCode
      } else {
        if (!self.livePreview) {
          this.$store.dispatch('setState', ['backgroundImage', {}])
        }
        this.$store.dispatch('setState', ['livePreview', !self.livePreview])
      }
    }
  }
}
</script>