<template>
  <pre class="terminal">
    <div class="console">
      <p class="message pending">Waiting...</p>
    </div>
    <div class="loader" style="display: none;">
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
        }else if(data.message){
          this.write(data.message, data.class || '');
        }
      }
    });

    window.onbeforeunload = (e) => {
      if(this.connection) this.connection.unsubscribe();
    };
  },
  methods: {
    clear: function(){
      $(this.$el).find('.console').html('');
      $(this.$el).find('.loader').show();
    },
    write: function(message, klass){
      $(this.$el).find('.console').append($('<p />', { class: 'message ' + klass }).html(message));

      if($(document.body).height() > $(window).height()){
        $(document).scrollTop($(document.body).height());
      }

      if(/complete/.test(klass)){
        $(this.$el).find('.loader').hide();
      }
    }
  },
  data: function(){
    return {
      cable: ActionCable.createConsumer(),
      connection: null
    };
  }
}
</script>

<style lang="scss" scoped>
.terminal {
  background-color: #1d1d1d;
  font-size: 15px;
  color: white;
  padding: 0 15px 15px;
  min-height: 100vh;

  > .console {
    > .pending {
      margin-top: 15px;
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

  /deep/ .heading {
    font-size: 18px;
    font-weight: bold;
    color: #01b7b7;
    margin: 15px 0 8px;
  }

  /deep/ .complete {
    color: #07b333;
  }
}

@keyframes loader {
  0%, 80%, 100% { opacity: 0; }
  40% { opacity: 1; }
}
</style>