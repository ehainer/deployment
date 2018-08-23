<template>
  <pre class="terminal">
    <p class="message">Waiting...</p>
  </pre>
</template>

<script type="text/javascript">
import Axios from 'axios';
import ActionCable from 'actioncable';

export default {
  name: 'v-terminal',
  mounted: function(){
    this.cable.subscriptions.create({ channel: 'DeploymentChannel' }, {
      received: (data) => {
        if(data.clear){
          this.clear();
        }else if(data.message){
          this.write(data.message, data.class || '');
        }
      }
    });
  },
  methods: {
    clear: function(){
      $(this.$el).html('');
    },
    write: function(message, klass){
      $(this.$el).append($('<p />', { class: 'message ' + klass }).html(message));
    }
  },
  data: function(){
    return {
      cable: ActionCable.createConsumer()
    };
  }
}
</script>

<style lang="scss" scoped>
.terminal {
  background-color: #1d1d1d;
  font-size: 15px;
  color: white;
  padding: 10px;
  height: 100vh;
  max-height: 100vh;
  overflow: auto;

  /deep/ .heading {
    font-size: 18px;
    font-weight: bold;
    color: #01b7b7;
    margin: 8px 0;
  }
}
</style>