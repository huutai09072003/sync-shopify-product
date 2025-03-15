<template>
  <div v-if="shouldShow" class="picture-it-transformer">
    <div>
      <div @click='toggleOptions' class="pic-it-button">
        <template v-if='showBackgroundOptions'>
          <div class='pic-it-button--text'>
            Close
          </div>
          <i class="fal fa-arrow-down"></i>
        </template>
        <template v-else>
          <div class='pic-it-button--text'>
            Background Settings
          </div>
          <i class="fal fa-cog"></i>
        </template>
      </div>
    </div>

    <transition name="slide">
      <div v-show='showBackgroundOptions'>
        <div class="picture-it-form-inline">
          <div class="picture-it-form-group">
            <label>Width</label>
            <input v-model="size" type="number" class="picture-it-form-control" />
          </div>
          <div class="picture-it-form-group">
            <label>Units</label>

            <select v-model="units" class="picture-it-form-control picture-it-form-control-lg">
              <option value='feet'>Feet</option>
              <option value='meters'>Meters</option>
            </select>
          </div>
        </div>
        <div class="picture-it-transformer-warning">
          Estimate the width of the background. This allows for better sizing of the product preview.
        </div>
      </div>
    </transition>
  </div>
</template>
<script>
import { mapGetters } from 'vuex'

export default {

  data() {
    return {
      size: '',
      units: 'feet'
    }
  },

  computed: {
    ...mapGetters(['config', 'touchscreen', 'backgroundImage', 'showBackgroundOptions']),

    shouldShow: function(argument) {
      return this.config && this.config.autoscale && this.$store.state.item.width_in_mm
    }
  },

  watch: {
    backgroundImage: function() {
      if (this.backgroundImage && this.backgroundImage.width_in_mm) {
        let width_in_mm = this.backgroundImage.width_in_mm;  
        if (width_in_mm && width_in_mm > 0) {
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

    toggleOptions() {
      const self = this;
      this.$store.dispatch('setState', ['showBackgroundOptions', !self.showBackgroundOptions])
    }
  }
}
</script>