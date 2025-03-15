export default {
  log (message, e) {
    if (window.pictureItApp.config && window.pictureItApp.config.env == 'd') {
      window.console && console.log(message, e);  
    }
  }
}