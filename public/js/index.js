var io = new RocketIO().connect();

io.on("connect", function(session){
  console.log("connect!! "+session);
});

io.on("temp", function(data){
  $("#temp").text("気温:"+data+"度");
});

io.on("light", function(data){
  $("#light").text("明るさ:"+data);
});
