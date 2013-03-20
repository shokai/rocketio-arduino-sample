var io = new RocketIO().connect();

io.on("connect", function(session){
  console.log("connect!! "+session);
  $("#rocketio").text("接続:"+io.type);
});

io.on("disconnect", function(){
  $("#rocketio").text("接続:close");
});

io.on("arduino", function(data){
  $("#temp").text("気温:"+data.temp+"度");
  $("#light").text("明るさ:"+data.light);
});

io.on("stat", function(data){
  $("#cpu").text("CPU:"+data.cpu+"%");
  $("#mem").text("メモリ:"+data.mem+"%");
});

io.on("clients", function(data){
  $("#websocket").text("websocket:"+data.websocket);
  $("#comet").text("comet:"+data.comet);
});

var blink = false;
io.on("*", function(event_name, data){
  if(blink) $("#blink").html("..");
  else $("#blink").html(".");
  blink = !blink;
});
