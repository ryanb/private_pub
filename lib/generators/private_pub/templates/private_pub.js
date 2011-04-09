PrivatePub = {
  connecting: false,
  faye_client: null,
  faye_callbacks: [],
  subscriptions: {},
  subscription_callbacks: {},

  faye: function(callback) {
    if (PrivatePub.faye_client) {
      callback(PrivatePub.faye_client);
    } else {
      PrivatePub.faye_callbacks.push(callback);
      if (PrivatePub.subscriptions.server && !PrivatePub.connecting) {
        PrivatePub.connecting = true;
        var script = document.createElement("script");
        script.type = "text/javascript";
        script.src = PrivatePub.subscriptions.server + ".js";
        script.onload = function() {
          PrivatePub.faye_client = new Faye.Client(PrivatePub.subscriptions.server);
          PrivatePub.faye_client.addExtension(PrivatePub.faye_extension);
          for (var i=0; i < PrivatePub.faye_callbacks.length; i++) {
            PrivatePub.faye_callbacks[i](PrivatePub.faye_client);
          };
        }
        document.documentElement.appendChild(script);
      }
    }
  },

  faye_extension: {
    outgoing: function(message, callback) {
      if (message.channel == "/meta/subscribe") {
        // Attach the signature and timestamp to subscription messages
        var subscription = PrivatePub.subscriptions[message.subscription];
        if (!message.ext) message.ext = {};
        message.ext.private_pub_signature = subscription.signature;
        message.ext.private_pub_timestamp = subscription.timestamp;
      }
      callback(message);
    }
  },

  sign: function(options) {
    if (!PrivatePub.subscriptions.server) {
      PrivatePub.subscriptions.server = options.server;
    }
    PrivatePub.subscriptions[options.channel] = options;
    PrivatePub.faye(function(faye) {
      faye.subscribe(options.channel, function(message) {
        if (message.eval) {
          eval(message.eval);
        }
        if (callback = PrivatePub.subscription_callbacks[options.channel]) {
          callback(message.data, message.channel);
        }
      });
    });
  },

  subscribe: function(channel, callback) {
    PrivatePub.subscription_callbacks[channel] = callback;
  }
};
