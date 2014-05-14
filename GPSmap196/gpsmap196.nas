

var GPSmap196 = {
  new: func() {
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
    m.gmt         = props.globals.getNode("sim/time/gmt");
    m.gpsmap196Screen = canvas.new({
      "name": "GPSmap196-screen",
      "size": [512, 512],
      "view": [320, 240],
      "mipmapping": 1
    });
    m.gpsmap196Screen.addPlacement({"node": "gps196.screen"});
    var g = m.gpsmap196Screen.createGroup();

    m.text_title =
      g.createChild("text", "line-title")
       .setDrawMode(canvas.Text.TEXT + canvas.Text.FILLEDBOUNDINGBOX)
       .setColor(0,0,0)
       .setColorFill(0,1,0)
       .setAlignment("center-top")
       .setFont("LiberationFonts/LiberationMono-Bold.ttf")
       .setFontSize(35, 1.5)
       .setTranslation(150, 50);

    return m;
  },
  update: func() {
    me.text_title.setText(me.gmt.getValue());
    settimer(func me.update(), 0);
  }
};

setlistener("sim/signals/fdm-initialized", func() {
  gpsmap196Canvas = GPSmap196.new();
  gpsmap196Canvas.update();
});

