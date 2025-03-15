<template>
  <div v-show="loading" class="pic-it-loader">
    <div class="pic-it-loader__icon"></div>
  </div>
</template>
<script>
import { mapGetters } from 'vuex';

export default {
  computed: {
    ...mapGetters(['loading']),
  }
}
</script>