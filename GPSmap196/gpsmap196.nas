print("Load Garmin GPSmap196 canvas");

var GPSmap196 = {
  new: func {
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
    return m;
  },
  update: func {

  }
};

var myGPSmap196 = GPSmap196.new();

var myCanvas = canvas.new({
  "name": "GPSmap196-screen",   # The name is optional but allow for easier identification
  "size": [512, 512],   # Size of the underlying texture (should be a power of 2, required) [Resolution]
  "view": [320, 240],   # Virtual resolution (Defines the coordinate system of the canvas [Dimensions]
                        # which will be stretched the size of the texture, required)
  "mipmapping": 1       # Enable mipmapping (optional)
});

myCanvas.addPlacement({"node": "gps196.screen"});
myCanvas.setColorBackground(0.6,0.64,0.545);

var group = myCanvas.createGroup();
var text = group.createChild("text", "optional-id-for element")
                .setTranslation(10, 20)      # The origin is in the top left corner
                .setAlignment("left-center") # All values from osgText are supported (see $FG_ROOT/Docs/README.osgtext)
                .setFont("LiberationFonts/LiberationSans-Regular.ttf") # Fonts are loaded either from $AIRCRAFT_DIR/Fonts or $FG_DATA/Fonts
                .setFontSize(14)             # Set fontsize and optionally character aspect ratio
                .setColor(0,0,0)             # Text color
                .setText("This is a text element");
text.show();
