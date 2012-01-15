# Private Pub

Private Pub is a Ruby gem for use with Rails to publish and subscribe to messages through [Faye](http://faye.jcoglan.com/). It allows you to easily provide real-time updates through an open socket without tying up a Rails process. All channels are private so users can only listen to events you subscribe them to.

This project was motivated by [RailsCasts episode #260](http://railscasts.com/episodes/260-messaging-with-faye).


## Setup

Add the gem to your Gemfile and run the `bundle` command to install it.

```ruby
gem "private_pub"
```

Run the generator to create the initial files.

```
rails g private_pub:install
```

Next, start up Faye using the rackup file that was generated.

```
rackup private_pub.ru -s thin -E production
```

**In Rails 3.1** add the JavaScript file to your application.js file manifest.

```javascript
//= require private_pub
```

**In Rails 3.0** add the generated private_pub.js file to your layout.

```rhtml
<%= javascript_include_tag "private_pub" %>
```

It's not necessary to include faye.js since that will be handled automatically for you.


## Usage

Use the `subscribe_to` helper method on any page to subscribe to a channel.

```rhtml
<%= subscribe_to "/messages/new" %>
```

Use the `publish_to` helper method to send JavaScript to that channel. This is usually done in a JavaScript AJAX template (such as a create.js.erb file).

```rhtml
<% publish_to "/messages/new" do %>
  $("#chat").append("<%= j render(@messages) %>");
<% end %>
```

This JavaScript will be immediately evaluated on all clients who have subscribed to that channel. In this example they will see the new chat message appear in real-time without reloading the browser.


## Alternative Usage

If you prefer to work through JSON instead of `.js.erb` templates, you can pass a hash to `publish_to` instead of a block and it will be converted `to_json` behind the scenes. This can be done anywhere (such as the controller).

```ruby
PrivatePub.publish_to "/messages/new", :chat_message => "Hello, world!"
```

And then handle this through JavaScript on the client side.

```javascript
PrivatePub.subscribe("/messages/new", function(data, channel) {
  $("#chat").append(data.chat_message);
});
```

The Ruby `subscribe_to` helper call is still necessary with this approach to grant the user access to the channel. The JavaScript is just a callback for any custom behavior.


## Configuration

The configuration is set separately for each environment in the generated `config/private_pub.yml` file. Here are the options.

* `server`: The URL to use for the Faye server such as `http://localhost:9292/faye`.
* `secret_token`: A secret hash to secure the server. Can be any string.
* `signature_expiration`: The length of time in seconds before a subscription signature expires. If this is not set there is no expiration. Note: if Faye is on a separate server from the Rails app, the system clocks must be in sync for the expiration to work properly.


## How It Works

The `subscribe_to` helper will output the following script which subscribes the user to a specific channel and server.

```html
<script type="text/javascript">
  PrivatePub.sign({
    channel: "/messages/new",
    timestamp: 1302306682972,
    signature: "dc1c71d3e959ebb6f49aa6af0c86304a0740088d",
    server: "http://localhost:9292/faye"
  });
</script>
```

The signature and timestamp checked on the Faye server to ensure users are only able to access channels you subscribe them to. The signature will automatically expire after the time specified in the configuration.

The `publish_to` method will send a post request to the Faye server (using `Net::HTTP`) instructing it to send the given data back to the browser.


## Development & Feedback

Questions or comments? Please use the [issue tracker](https://github.com/ryanb/private_pub/issues). Tests can be run with `bundle` and `rake` commands.
