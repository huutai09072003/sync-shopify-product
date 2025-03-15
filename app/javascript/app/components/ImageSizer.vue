<template>
  <div data-html2canvas-ignore class="picture-it-sizer">    
    <div class='picture-it-range-slider'>
      <vue-slider
        v-model="imageSize" 
        :min="imageSizeSettings.min" 
        :max="imageSizeSettings.max"
        :contained="true"
        :dotSize="20"
        direction='btt'
        :width="4"
        height='100%'
        :duration='0.15'
        :interval='0.001'
        tooltip='none'
      />
    </div>
  </div>
</template>
<script>
export default {

  data() {
    return {
      imageSizeSettings: {
        min: 1,
        // max: 100
        max: 40
      }
    }
  },

  created() {
    if (this.$store.state.item.width_in_mm && this.$store.state.backgroundImage.width_in_mm) {
      let widthAsPercentage = (this.$store.state.item.width_in_mm / this.$store.state.backgroundImage.width_in_mm) * 100;
      this.$store.dispatch('setState', ['imageSize', widthAsPercentage])
    }
  },

  computed: {    
    imageSize: {
      get () {
        return this.$store.state.imageSize
      },
      set (value) {
        this.$store.dispatch('setState', ['imageSize', value])
      }
    },
  }
}
</script>

