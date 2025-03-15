<template>
  <div class="picture-it-transformer">
    <div @click="toggleTransformer" class="pic-it-button pic-it-button--settings">
      <div class="pic-it-button__text">
        {{ $t('buttons.settings') }}
      </div>
      <i class="pic-it-button__icon">
        <svg height="20" viewBox="0 0 20 20" width="20" xmlns="http://www.w3.org/2000/svg"><g fill="none" fill-rule="evenodd" stroke="currentColor" stroke-width="1.5" transform="matrix(.70710678 -.70710678 .70710678 .70710678 2.221748 13.535775)"><path d="m3.5 6v-2"/><path d="m6.5 6v-2m3 2v-2m3 2v-2m-7.5-4v2m6-2v2"/><path d="m0 0h16v6h-16z"/></g></svg>
      </i>
    </div>

    <!-- <label class="pic-it__product-dimensions pic-it-label" v-if="dimensions">
      {{ dimensions }}
    </label> -->

    <transition name="fade">
      <div class="transformer__controls" v-show='showTransform'>

        <div class="transformer__controls--product-title" :dir="htmlTagDirection">
          <h5>
            {{ $t('image_transformer.settings_title') }}
          </h5>

          <div @click="reset" class="pic-it-button pic-it-button--icon-only">
            <!-- <div class="pic-it-button__text">
              Restore
            </div> -->
            <i class="pic-it-button__icon">
              <svg height="20" viewBox="0 0 20 20" width="20" xmlns="http://www.w3.org/2000/svg"><g fill="none" fill-rule="evenodd"><path d="m0 0h20v20h-20z" opacity=".1"/><path d="m3.5 9.75c0-3.72792206 3.02207794-6.75 6.75-6.75 3.7279221 0 6.75 3.02207794 6.75 6.75 0 3.7279221-3.0220779 6.75-6.75 6.75-1.5815153 0-3.03599602-.5438997-4.18659337-1.4548503" stroke="#000" stroke-linecap="round" stroke-width="1.5"/><path d="m1.13684501 9.5077492 1.97891304 3.4670041c.13688857.2398252.44227542.3232719.68210063.1863833.0776802-.0443387.1420446-.1087031.18638327-.1863833l2.01824675-3.53591574c.13688857-.23982521.05344194-.54521206-.18638327-.68210063-.15462952-.08826017-.3445275-.08763474-.4985723.00164204l-1.84702009 1.07044197-1.63981362-.99624924c-.23600167-.14338-.54355127-.06829531-.68693128.16770636-.09436699.15532687-.09701772.34962776-.00692313.50747114z" fill="#000"/></g></svg>
            </i>
          </div>
        </div>

        <div class="transformer__controls--product">
          <div class="transformer__controls--item" :dir="htmlTagDirection">
            <label>{{ $t('image_transformer.angle') }}</label>
            <div class='picture-it-range-slider'>
              <vue-slider v-model="rotateY"
                width="100%"
                :height="4"
                :min="rotateYSettings.min"
                :max="rotateYSettings.max"
                :contained="true"
                :dotSize="20"
              />
            </div>
          </div>

          <div class="transformer__controls--item" :dir="htmlTagDirection">
            <label>{{ $t('image_transformer.level') }}</label>
            <div class="picture-it-range-slider">
              <vue-slider v-model="rotateZ"
                width="100%"
                :height="4"
                :min="rotateZSettings.min"
                :max="rotateZSettings.max"
                :contained="true"
                :dotSize="20"
              />
            </div>
          </div>

          <div class="transformer__controls--item" :dir="htmlTagDirection">
            <label :style="labelFullBackgroundStyle">{{ $t('image_transformer.show_full_background') }}</label>
            <div class="pic-it-show-full-background__toggle">
              <pic-it-toggle v-model="showFullBackground"></pic-it-toggle>
            </div>
          </div>
        </div>

        <div class="transformer__controls--background" v-if="shouldShowBackgroundSettings">
          <div class="pic-it-form">
            <div class="transformer__controls--item" :dir="htmlTagDirection">
              <label>{{ $t('image_transformer.space_width') }}</label>
              <input v-model="size" type="number" />
            </div>

            <div class="transformer__controls--item" :dir="htmlTagDirection">
              <label>{{ $t('common.unit') }}</label>
              <select v-model="units">
                <option value='feet'>{{ $t('common.feet') }}</option>
                <option value='meters'>{{ $t('common.meters') }}</option>
              </select>
            </div>
          </div>
        </div>

        <!-- <div class="pic-it-message pic-it-transformer-warning">
          <div class="pic-it-message__body">
            <h6>Note:</h6>
            <p>
              Using these settings will disable ability to save image.
            </p>
            <p v-if="shouldShowBackgroundSettings">
              Estimate the width of the background. This allows for better sizing of the product preview.
            </p>
          </div>
        </div> -->
      </div>
    </transition>
  </div>
</template>
<script>
import { mapGetters } from 'vuex'
// import Swatches from 'vue-swatches'

// import "vue-swatches/dist/vue-swatches.min.css"
export default {
  // components: {
  //   Swatches
  // },

  data() {
    return {
      perspectiveSettings: {
        min: 0,
        max: 1000
      },
      rotateYSettings: {
        min: -75,
        max: 75
      },
      rotateZSettings: {
        min: -10,
        max: 10
      },
      size: '',
      units: 'feet'
    }
  },

  computed: {
    ...mapGetters(['config', 'touchscreen', 'showTransform', 'backgroundImage', 'item', 'backgroundImageWithInMM', 'htmlTagDirection']),

    dimensions: function() {
      if (this.item && this.item.dimensions_unit && this.item.height && this.item.width) {

        let unit = "cm"
        if (this.item.dimensions_unit == 'inches') {
          unit = '"';
        }

        return `${this.item.width}${unit} x ${this.item.height}${unit}`;
      }
    },

    perspective: {
      get() {
        return this.$store.state.perspective
      },
      set(value) {
        this.$store.dispatch('setState', ['perspective', value])
      }
    },

    rotateY: {
      get() {
        return this.$store.state.rotateY
      },
      set (value) {
        if (value == 0) {
          this.$store.dispatch('setState', ['perspective', 0])
        } else {
          this.$store.dispatch('setState', ['perspective', 500])
        }

        this.$store.dispatch('setState', ['rotateY', value])
      }
    },

    rotateZ: {
      get() {
        return this.$store.state.rotateZ
      },
      set(value) {
        this.$store.dispatch('setState', ['rotateZ', value])
      }
    },

    showFullBackground: {
      get() {
        return this.$store.state.showFullBackground
      },
      set(value) {
        this.$store.dispatch('setState', ['showFullBackground', value])
      }
    },

    shouldShowBackgroundSettings: function(argument) {
      return this.config && this.config.autoscale && this.$store.state.item.width_in_mm
    },

    labelFullBackgroundStyle() {
      return this.showFullBackground ? '' : 'color: #999;';
    },

    // backgroundColor: {
    //   get() {
    //     return this.$store.state.backgroundColor
    //   },
    //   set(value) {
    //     this.$store.dispatch('setState', ['backgroundColor', value])
    //   }
    // },
  },

  watch: {
    backgroundImage: function() {
      if (this.backgroundImage && this.backgroundImage.width_in_mm) {
        let width_in_mm = this.backgroundImageWithInMM;
        if (width_in_mm && width_in_mm > 0) {
          this.size = width_in_mm / 304.8
        }
      } else {
        this.size = '';
      }
    },
    backgroundImageWithInMM: function() {
      const width_in_mm = this.backgroundImageWithInMM;

      if (width_in_mm !== undefined) {
        if (width_in_mm > 0) {
          this.size = width_in_mm / 304.8
        }
      } else {
        this.size = '';
      }
    },
    size: function() {
      this.resizeProductImage();
    },
    units: function() {
      this.resizeProductImage();
    }
  },

  methods: {
    reset() {
      this.perspective = 0;
      this.rotateY = 0;
      this.rotateZ = 0;

      if (this.$store.state.item.width_in_mm && this.$store.state.backgroundImage.width_in_mm) {
        let widthAsPercentage = (this.$store.state.item.width_in_mm / this.backgroundImageWithInMM) * 100;
        this.$store.dispatch('setState', ['imageSize', widthAsPercentage])
      } else {
        // this.$store.dispatch('setState', ['imageSize', 20])
      }
    },

    toggleTransformer() {
      const self = this;
      this.$store.dispatch('setState', ['showTransform', !self.showTransform])
    },

    // showSlider(toggle) {
    //   this.$store.dispatch('setState', ['showSlider', toggle])
    // }

    resizeProductImage() {
      if (!this.size && this.size <= 0) { return; }
      let bg_width_in_mm;
      if (this.units == 'feet') {
        bg_width_in_mm = parseFloat(this.size * 304.8).toFixed(2); // 12x (feet -> inches), 25.4x (inch -> mm )
      } else {
        bg_width_in_mm = parseFloat(this.size * 1000).toFixed(2); // using meters
      }

      if (bg_width_in_mm < 1000) {
        return;
      }

      let widthAsPercentage = (this.$store.state.item.width_in_mm / bg_width_in_mm) * 100;
      if (widthAsPercentage > 0) {
        this.$store.dispatch('setState', ['imageSize', widthAsPercentage])
      }
    },
  }
}
</script>