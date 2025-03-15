<template>
  <div>
    <div data-html2canvas-ignore v-show="showSlider && hasMoreThanOneImages" class="slider-wrapper">
      <div class="slider-container">
        <swiper ref="slider" :options="swiperOption">
          <swiper-slide v-for="(image, index) in images" :key="index">
            <div>
              <img class="slider-image" :src="image.src" />
            </div>
          </swiper-slide>
        </swiper>
      </div>
    </div>
  </div>
</template>
<script>
import { mapGetters } from 'vuex';

export default {
  computed: {
    ...mapGetters(['backgroundImages', 'showSlider']),

    slider() {
      return this.$refs.slider.swiper
    },

    images() {
      return this.backgroundImages;
    },

    hasMoreThanOneImages() {
      if (this.backgroundImages && this.backgroundImages.length > 1) {
        return true;
      } else {
        return false;
      }
    }
  },

  data() {
    return {
      swiperOption: {
        initialSlide: 0,
        slideToClickedSlide: true,
        grabCursor: false,
        centeredSlides: true,
        slidesPerView: 'auto',
        init: false
      }
    }
  },

  mounted() {
    this.setupSlider();
  },

  methods: {
    setupSlider() {
      const self = this;
      // not great solution - but need to give time for images to load before slider.init
      setTimeout(() => {
        self.slider.init();
        self.slider.on('slideChange', () => {
          // self.$store.dispatch('setState', ['loading', true]);
          self.$store.dispatch('setState', ['backgroundImage', self.images[self.slider.activeIndex]]);
        })    
      }, 500)
    }
  }
}
</script>