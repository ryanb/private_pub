describe("PrivatePub", function() {
  var pub, doc;
  beforeEach(function() {
    Faye = {}; // To simulate global Faye object
    doc = {};
    pub = buildPrivatePub(doc);
  });

  it("adds a subscription callback", function() {
    pub.subscribe("hello", "callback");
    expect(pub.subscriptionCallbacks["hello"]).toEqual("callback");
  });

  it("has a fayeExtension which adds matching subscription signature and timestamp to outgoing message", function() {
    var called = false;
    var message = {channel: "/meta/subscribe", subscription: "hello"}
    pub.subscriptions["hello"] = {signature: "abcd", timestamp: "1234"}
    pub.fayeExtension.outgoing(message, function(message) {
      expect(message.ext.private_pub_signature).toEqual("abcd");
      expect(message.ext.private_pub_timestamp).toEqual("1234");
      called = true;
    });
    expect(called).toBeTruthy();
  });

  it("evaluates javascript in message response", function() {
    pub.handleResponse({eval: 'self.subscriptions.foo = "bar"'});
    expect(pub.subscriptions.foo).toEqual("bar");
  });

  it("triggers callback matching message channel in response", function() {
    var called = false;
    pub.subscribe("test", function(data, channel) {
      expect(data).toEqual("abcd");
      expect(channel).toEqual("test");
      called = true;
    });
    pub.handleResponse({channel: "test", data: "abcd"});
    expect(called).toBeTruthy();
  });

  it("adds a faye subscription with response handler when signing", function() {
    var faye = {subscribe: jasmine.createSpy()};
    spyOn(pub, 'faye').andCallFake(function(callback) {
      callback(faye);
    });
    var options = {server: "server", channel: "somechannel"};
    pub.sign(options);
    expect(faye.subscribe).toHaveBeenCalledWith("somechannel", pub.handleResponse);
    expect(pub.subscriptions.server).toEqual("server");
    expect(pub.subscriptions.somechannel).toEqual(options);
  });

  it("adds a faye subscription with response handler when signing", function() {
    var faye = {subscribe: jasmine.createSpy()};
    spyOn(pub, 'faye').andCallFake(function(callback) {
      callback(faye);
    });
    var options = {server: "server", channel: "somechannel"};
    pub.sign(options);
    expect(faye.subscribe).toHaveBeenCalledWith("somechannel", pub.handleResponse);
    expect(pub.subscriptions.server).toEqual("server");
    expect(pub.subscriptions.somechannel).toEqual(options);
  });

  it("takes a callback for subscription object when signing", function(){
    var faye = {subscribe: function(){ return "subscription"; }};
    spyOn(pub, 'faye').andCallFake(function(callback) {
      callback(faye);
    });
    var options = { server: "server", channel: "somechannel" };
    options.subscription = jasmine.createSpy();
    pub.sign(options);
    expect(options.subscription).toHaveBeenCalledWith("subscription");
  });

  it("returns the subscription object for a subscribed channel", function(){
    var faye = {subscribe: function(){ return "subscription"; }};
    spyOn(pub, 'faye').andCallFake(function(callback) {
      callback(faye);
    });
    var options = { server: "server", channel: "somechannel" };
    pub.sign(options);
    expect(pub.subscription("somechannel")).toEqual("subscription")
  });

  it("unsubscribes a channel by name", function(){
    var sub = { cancel: jasmine.createSpy() };
    var faye = {subscribe: function(){ return sub; }};
    spyOn(pub, 'faye').andCallFake(function(callback) {
      callback(faye);
    });
    var options = { server: "server", channel: "somechannel" };
    pub.sign(options);
    expect(pub.subscription("somechannel")).toEqual(sub);
    pub.unsubscribe("somechannel");
    expect(sub.cancel).toHaveBeenCalled();
    expect(pub.subscription("somechannel")).toBeFalsy();
  });

  it("unsubscribes all channels", function(){
    var created = 0;
    var sub = function() {
      created ++;
      var sub = { cancel: function(){ created --; } };
      return sub;
    };
    var faye = { subscribe: function(){ return sub(); }};
    spyOn(pub, 'faye').andCallFake(function(callback) {
      callback(faye);
    });
    pub.sign({server: "server", channel: "firstchannel"});
    pub.sign({server: "server", channel: "secondchannel"});
    expect(created).toEqual(2);
    expect(pub.subscription("firstchannel")).toBeTruthy();
    expect(pub.subscription("secondchannel")).toBeTruthy();
    pub.unsubscribeAll()
    expect(created).toEqual(0);
    expect(pub.subscription("firstchannel")).toBeFalsy();
    expect(pub.subscription("secondchannel")).toBeFalsy();
  });

  it("triggers faye callback function immediately when fayeClient is available", function() {
    var called = false;
    pub.fayeClient = "faye";
    pub.faye(function(faye) {
      expect(faye).toEqual("faye");
      called = true;
    });
    expect(called).toBeTruthy();
  });

  it("adds fayeCallback when client and server aren't available", function() {
    pub.faye("callback");
    expect(pub.fayeCallbacks[0]).toEqual("callback");
  });

  it("adds a script tag loading faye js when the server is present", function() {
    script = {};
    doc.createElement = function() { return script; };
    doc.documentElement = {appendChild: jasmine.createSpy()};
    pub.subscriptions.server = "path/to/faye";
    pub.faye("callback");
    expect(pub.fayeCallbacks[0]).toEqual("callback");
    expect(script.type).toEqual("text/javascript");
    expect(script.src).toEqual("path/to/faye.js");
    expect(script.onload).toEqual(pub.connectToFaye);
    expect(doc.documentElement.appendChild).toHaveBeenCalledWith(script);
  });

  it("connects to faye server, adds extension, and executes callbacks", function() {
    callback = jasmine.createSpy();
    client = {addExtension: jasmine.createSpy()};
    Faye.Client = function(server) {
      expect(server).toEqual("server")
      return client;
    };
    pub.subscriptions.server = "server";
    pub.fayeCallbacks.push(callback);
    pub.connectToFaye();
    expect(pub.fayeClient).toEqual(client);
    expect(client.addExtension).toHaveBeenCalledWith(pub.fayeExtension);
    expect(callback).toHaveBeenCalledWith(client);
  });
});
