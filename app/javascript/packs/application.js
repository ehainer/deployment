// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

// Import stylesheet
import '../assets/stylesheets/application.scss';

// UJS for handling ajax responses
import 'jquery-ujs';

import VTerminal from '@components/terminal.vue';

window.addEventListener('DOMContentLoaded', () => {
  new Vue({
    el: '#app',
    components: { VTerminal }
  });
});
