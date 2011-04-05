PrivatePubExtension = {
  outgoing: function(message, callback) {
    if (message.channel == "/meta/subscribe") {
      // Attach the signature and timestamp to subscription messages
      var subscription = $(".private_pub_subscription[data-channel='" + message.subscription + "']");
      if (!message.ext) message.ext = {};
      message.ext.private_pub_signature = subscription.data("signature");
      message.ext.private_pub_timestamp = subscription.data("timestamp");
    }
    callback(message);
  }
};

jQuery(function() {
  var faye;
  if ($(".private_pub_subscription").length > 0) {
    jQuery.getScript($(".private_pub_subscription").data("server") + ".js", function() {
      faye = new Faye.Client($(".private_pub_subscription").data("server"));
      faye.addExtension(PrivatePubExtension);
      $(".private_pub_subscription").each(function(index) {
        faye.subscribe($(this).data("channel"), function(data) {
          if (data._eval) eval(data._eval);
        });
      });
    });
  }
});
