import Vuex from 'vuex'
import Vue from 'vue'

Vue.use(Vuex)

export default new Vuex.Store({
  state: {
    config: {},
    showTransform: false,
    showBackgroundOptions: false,
    showFullBackground: true,
    showCameraOptions: false,
    item: {},
    parentUrl: '',
    itemImageURL: '',
    perspective: 0,
    rotateY: 0,
    rotateZ: 0,
    backgroundColor: '#fdfcfc',
    imageSize: 20,
    backgroundImages: [],
    backgroundImage: {},
    backgroundImageWithInMM: 0,
    htmlTagDirection: 'ltr',
    showSlider: true,
    livePreview: false,
    loading: true,
    livePreviewCapable: false,
    touchscreen: false,
  },

  getters: {
    config: state => {
      return state.config // for ease of mapGetters
    },
    item: state => {
      return state.item
    },
    parentUrl: state => {
      return state.parentUrl
    },
    showTransform: state => {
      return state.showTransform
    },
    showBackgroundOptions: state => {
      return state.showBackgroundOptions
    },
    showFullBackground: state => {
      return state.showFullBackground
    },
    showCameraOptions: state => {
      return state.showCameraOptions
    },
    backgroundImageWithInMM: state => {
      return state.backgroundImageWithInMM
    },
    htmlTagDirection: state => {
      return state.htmlTagDirection
    },
    showSlider: state => {
      return state.showSlider
    },
    itemImageURL: state => {
      return state.itemImageURL
    },
    backgroundImages: state => {
      return state.backgroundImages
    },
    backgroundImage: state => {
      return state.backgroundImage
    },
    livePreview: state => {
      return state.livePreview
    },
    loading: state => {
      return state.loading
    },
    touchscreen: state => {
      return state.touchscreen
    },
    livePreviewCapable: state => {
      return state.livePreviewCapable
    },
    perspective: state => {
      return state.perspective
    },
    rotateY: state => {
      return state.rotateY
    },
    rotateZ: state => {
      return state.rotateZ
    },
    backgroundColor: state => {
      return state.backgroundColor
    },
    imageSize: state => {
      return state.imageSize
    }
  },

  actions: {
    setState(context, newState) {
      context.commit('updateState', newState)
    },

    addImage(context, newImage) {
      context.commit('addImage', newImage)
    }
  },

  mutations: {
    updateState(state, newState) {
      state[newState[0]] = newState[1]
    },
    addImage(state, newImage) {
      state.backgroundImages.unshift({src: newImage});
    }
  }
});
