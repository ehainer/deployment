<template>
  <pre class="terminal">
    <div class="console">
      <p class="message">Waiting...</p>
    </div>
    <div v-show="running" class="loader">
      <span class="first"></span>
      <span class="second"></span>
      <span class="third"></span>
    </div>
  </pre>
</template>

<script type="text/javascript">
import Axios from 'axios';
import ActionCable from 'actioncable';

export default {
  name: 'v-terminal',
  mounted: function(){
    this.connection = this.cable.subscriptions.create({ channel: 'DeploymentChannel' }, {
      received: (data) => {
        if(data.clear){
          this.clear();
        }

        if(data.reset){
          this.reset();
        }

        if(data.message){
          this.write(data.message, data.class || '');
        }

        if(data.timer){
          let counter = 30;
          this.timer = setInterval(() => {
            if(counter > 0){
              counter--;
              $(this.$el).find('.timer').html(counter);
            }else{
              clearInterval(this.timer);
            }
          }, 1000);
        }
      }
    });

    window.onbeforeunload = (e) => {
      if(this.connection) this.connection.unsubscribe();
    };
  },
  methods: {
    clear: function(){
      this.running = false;
      if(this.timer) clearInterval(this.timer);
      $(this.$el).find('.console').html('');
    },
    reset: function(){
      this.running = false;
      if(this.timer) clearInterval(this.timer);
      $(this.$el).find('.console').html('<p class="message">Waiting...</p>');
    },
    write: function(message, klass){
      $(this.$el).find('.console').append($('<p />', { class: 'message ' + (klass || '') }).html(message));

      if($(this.$el).find('.console').height() > $(window).height()){
        $(this.$el).scrollTop($(this.$el).find('.console').height());
      }

      if(/complete/.test(klass)){
        this.running = false;
      }else{
        this.running = true;
      }
    }
  },
  data: function(){
    return {
      cable: ActionCable.createConsumer(),
      connection: null,
      running: false,
      timer: null
    };
  }
}
</script>

<style lang="scss" scoped>
.terminal {
  background-color: #1d1d1d;
  font-size: 15px;
  color: white;
  padding: 15px;
  height: 100%;
  max-height: 100%;
  overflow: auto;

  /deep/ .console {
    > .heading {
      font-size: 18px;
      font-weight: bold;
      color: #01b7b7;
      margin: 0 0 8px;
    }

    > .complete {
      color: #07b333;
    }

    > .warning {
      color: #e5e927 !important;
    }

    > .message + .heading {
      margin-top: 8px;
    }

    a {
      display: inline-block;
      color: #00a6ff;
      text-decoration: none;

      &:hover {
        text-decoration: underline;
      }

      &:before {
        content: '(';
      }

      &:after {
        content: ')';
      }
    }
  }

  > .loader {
    height: 10px;
    margin: 8px 0 15px;
    font-size: 0;

    > span {
      display: inline-block;
      margin: 0 10px 0 0;
      width: 8px;
      height: 8px;
      background-color: #ffffff;
      border-radius: 50%;
      float: left;
      animation: loader 1400ms infinite ease-in-out;

      &.first {
        animation-delay: -320ms;
      }

      &.second {
        animation-delay: -160ms;
      }
    }
  }
}

@keyframes loader {
  0%, 80%, 100% { opacity: 0; }
  40% { opacity: 1; }
}
</style>