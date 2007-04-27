####    King RDR-160 Weather Radar  ####
####    Syd Adams    ####
####
####    Include this file in the Set file to run the RDR-160 radar 
####
#### Switch Modes  0 = off ; 1 = stby ; 2 = tst ; 3 = on;
#### Radar Modes WX ; WXA ; MAP
#### Ranges : 10 , 20, 40, 80 , 160 

RADAR = props.globals.getNode("/instrumentation/wxradar",1);
FDM_ON = 0;
P_Str =["off","stby", "tst","on"];
RADAR.getNode("serviceable",1).setBoolValue(1);
RADAR.getNode("range",1).setIntValue(10);
RADAR.getNode("set-range",1).setIntValue(0);
RADAR.getNode("minimized",1).setBoolValue(0);
RADAR.getNode("switch",1).setValue("off");
RADAR.getNode("switch-pos",1).setIntValue(0);
RADAR.getNode("mode",1).setValue("WX");
RADAR.getNode("lightning",1).setBoolValue(0);
RADAR.getNode("display-mode",1).setValue("arc");
RADAR.getNode("dim",1).setDoubleValue(0.5);

setlistener("/sim/signals/fdm-initialized", func {
    FDM_ON = 1;
    print("KING RDR-160 ... OK");
    });

setlistener("/instrumentation/wxradar/switch-pos", func {
    if(FDM_ON != 0){
        var swtch = cmdarg().getValue();
        RADAR.getNode("switch",1).setValue(P_Str[swtch]);
        }
    });

setlistener("/instrumentation/wxradar/set-range", func {
    if(FDM_ON != 0){
        var rng = RADAR.getNode("range").getValue();
        var num = cmdarg().getValue();
        cmdarg().setValue(0);
        if(num > 0){
        rng *= 2;
        if(rng > 160){rng = 160.0;}
        }else{
        if(num < 0){
            rng *=0.5;
            if(rng < 10){rng = 10.0;}
                }
            }
        RADAR.getNode("range").setValue(rng);
        }
    });

