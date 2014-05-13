

var GPSmap196 = {
  new: func(canvas_group) {
    print("Load Garmin GPSmap196 canvas");
    m             = { parents : [GPSmap196] };
    m.node        = props.globals.initNode("/instrumentation/gps196");
    m.rockerUp    = m.node.initNode("inputs/rocker-up", 0, "BOOL");
    m.buttonIn    = m.node.initNode("inputs/button-in", 0, "BOOL");
    m.buttonDto   = m.node.initNode("inputs/button-dto", 0, "BOOL");
    m.buttonOut   = m.node.initNode("inputs/button-out", 0, "BOOL");
    m.buttonMenu  = m.node.initNode("inputs/button-menu", 0, "BOOL");
    m.buttonNrst  = m.node.initNode("inputs/button-nrst", 0, "BOOL");
    m.buttonPage  = m.node.initNode("inputs/button-page", 0, "BOOL");
    m.buttonQuit  = m.node.initNode("inputs/button-quit", 0, "BOOL");
    m.rockerDown  = m.node.initNode("inputs/rocker-down", 0, "BOOL");
    m.rockerLeft  = m.node.initNode("inputs/rocker-left", 0, "BOOL");
    m.buttonPower = m.node.initNode("inputs/button-power", 0, "BOOL");
    m.rockerRight = m.node.initNode("inputs/rocker-right", 0, "BOOL");
    m.buttonEnter = m.node.initNode("inputs/button-enter", 0, "BOOL");

    m.text = canvas_group.createChild("text", "optional-id-for element")
                  .setFontSize(14)
                  .setColor(1,0,0)
                  .setTranslation(10, 20)
                  .setAlignment("left-center")
                  .setText("This is a text element")
                  .setFont("LiberationFonts/LiberationSans-Regular.ttf");

    return m;
  },
  update: func() {

    settimer(func me.update(), 0);
  }
};

setlistener("sim/signals/fdm-initialized", func() {
  var gpsmap196Screen = canvas.new({
    "name": "GPSmap196-screen",
    "size": [512, 512],
    "view": [320, 240],
    "mipmapping": 1
  });
  gpsmap196Screen.addPlacement({"node": "gps196.screen"});
  gpsmap196Canvas = GPSmap196.new(gpsmap196Screen.createGroup());
  gpsmap196Canvas.update();
});

