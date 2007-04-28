####    Bendix-King KFC-200 Flight Director    ####

# off - Off: v-bars hidden
# hdg - Heading: v-bars command a turn to the heading bug
# appr - Approach: bank and pitch commands capture and track LOC and GS
# bc - Reverse Localizer: bank command to caputre and track a reverse LOC
#course.GS is locked out.
# arm - Standby mode to compute capture point for nav, appr, or bc.
# cpld - Coupled: Active mode for nav, appr, or bc.
# ga - Go Around: commands wings level and missed approach attitude.
# alt - Altitude hold: commands pitch to hold altitude
# vertical trim - pitch command to adjust altitude at 500 fpm while in alt hold
#or pitch attitude at rate of 1 deg/sec when not in alt hold
# yd - Yaw Damper: system senses motion around ayw axis and moves rudder to
# oppose yaw.

fdprop = props.globals.getNode("/instrumentation/kfc200",1);
fdmode = "off";
fdmodeV = "off";
fdmode_last = "off";
current_alt=0.0;
alt_select = 0.0;
alt_offset = 0.0;
V_pitch=0.0;
V_roll=0.0;
DH = 0;
NAVGS = props.globals.getNode("/instrumentation/nav/has-gs",1);
NAVGS_RANGE = props.globals.getNode("/instrumentation/nav/gs-distance",1);
NAVBC = props.globals.getNode("/instrumentation/nav/back-course-btn",1);
NAV_IN_RANGE = props.globals.getNode("/instrumentation/nav/in-range",1);
HDG_DEFLECTION = props.globals.getNode("/instrumentation/nav/heading-needle-deflection",1);
GS_DEFLECTION = props.globals.getNode("/instrumentation/nav/gs-needle-deflection",1);
HDG = props.globals.getNode("/autopilot/locks/heading",1);
ALT = props.globals.getNode("/autopilot/locks/altitude",1);
SPD = props.globals.getNode("/autopilot/locks/speed",1);

setlistener("/sim/signals/fdm-initialized", func {
    fdprop.getNode("serviceable",1).setBoolValue(1);
    fdprop.getNode("vbar-pitch",1).setDoubleValue(0.0);
    fdprop.getNode("vbar-roll",1).setDoubleValue(0.0);
    fdprop.getNode("fd-on",1).setBoolValue(0);
    fdprop.getNode("fdmode",1).setValue("off");
    fdprop.getNode("fdmodeV",1).setValue("off");
    fdprop.getNode("alt-offset",1).setDoubleValue(0.0);
    fdprop.getNode("alt-alert",1).setBoolValue(0);
    DH = props.globals.getNode("/autopilot/route-manager/min-lock-altitude-agl-ft").getValue();
    alt_select = 0;
    update();
    print("KFC-200 ... OK");
    });

setlistener("/instrumentation/kfc200/fd-on", func {
    var fdON = cmdarg().getValue();
    if(!fdprop.getNode("serviceable").getBoolValue()){return;}
    clear_ap();
    });

setlistener("/autopilot/settings/target-altitude-ft",func{
    if(!fdprop.getNode("serviceable").getBoolValue()){return;}
    alt_select = cmdarg().getValue();
    });

setlistener("/autopilot/route-manager/min-lock-altitude-agl-ft",func{
    if(!fdprop.getNode("serviceable").getBoolValue()){return;}
    DH = cmdarg().getValue();
    });


setlistener("/instrumentation/kfc200/fdmode",func{
    if(!fdprop.getNode("serviceable").getBoolValue()){return;}
    fdmode = cmdarg().getValue();
    NAVBC.setBoolValue(0);
    if(fdmode == "off"){HDG.setValue("wing-leveler");return;}
    if(fdmode == "hdg"){
    HDG.setValue("dg-heading-hold");
    return;}
    if(fdmode == "appr"){
    HDG.setValue("nav1-hold");
    if(NAVGS.getBoolValue()){
    fdprop.getNode("fdmodeV").setValue("gs-arm");
    }
    return;}

    if(fdmode == "nav-arm"){
        HDG.setValue("dg-heading-hold");
        return;}
    if(fdmode == "nav-cpld"){
        HDG.setValue("nav1-hold");
        return;}
    if(fdmode == "bc"){
        HDG.setValue("nav1-hold");
    NAVBC.setBoolValue(1);
    return;}
        });

setlistener("/instrumentation/kfc200/fdmodeV", func {
    if(!fdprop.getNode("serviceable").getBoolValue()){return;}
    altmode = cmdarg().getValue();
    if(altmode == "off"){
    setprop("/autopilot/settings/target-pitch-deg",getprop("/orientation/pitch-deg"));
    ALT.setValue("pitch-hold");
    return;}
    if(altmode == "alt-arm"){
        ALT.setValue("pitch-hold");
        return;}
    if(altmode == "alt"){
        ALT.setValue("altitude-hold");
        return;}
    if(altmode == "gs-arm"){
    ALT.setValue("pitch-hold");
    return;}
    if(altmode == "gs"){
        ALT.setValue("gs1-hold");
    return;}
    });

clear_ap = func {
    setprop("/autopilot/settings/target-pitch-deg",getprop("/orientation/pitch-deg"));
    HDG.setValue("wing-leveler");
    ALT.setValue("pitch-hold");
    }

update_nav = func {
    if(fdprop.getNode("serviceable").getBoolValue()){
    var APmode = fdprop.getNode("fdmode").getValue();
    var VNAV = fdprop.getNode("fdmodeV").getValue();
    if(APmode == "nav-arm"){
        if(NAV_IN_RANGE.getBoolValue()){
            var offset = HDG_DEFLECTION.getValue();
            if(offset < 5 or offset > -5){
                fdprop.getChild("fdmode").setValue("nav-cpld");
        }else{
            fdprop.getChild("fdmode").setValue("nav-arm");
                }
            }
        }
    if(VNAV == "gs-arm"){
        if(NAVGS_RANGE.getValue()< 30000){
        test = GS_DEFLECTION.getValue();
        if(test < 1 ){fdprop.getNode("fdmodeV").setValue("gs");}
        }
    }

    if(VNAV == "alt-arm"){
        var offset = fdprop.getNode("alt-offset").getValue();
        if(offset > -990 and offset < 990){
        fdprop.getNode("fdmodeV").setValue("alt");}
        }

    if(VNAV == "alt"){
        offset = fdprop.getNode("alt-offset").getValue();
        if(offset < -990 and offset > 990){
        fdprop.getNode("fdmodeV").setValue("alt-arm");}
        }
    }
    V_pitch=props.globals.getNode("autopilot/settings/target-pitch-deg").getValue();
    V_pitch-=props.globals.getNode("orientation/pitch-deg").getValue();
    if(V_pitch > 30){V_pitch = 30;}
    if(V_pitch < -30){V_pitch = -30;}
    fdprop.getNode("vbar-pitch",1).setValue(V_pitch);
    V_roll=props.globals.getNode("autopilot/internal/target-roll-deg").getValue();
    if(V_roll == nil){V_roll = 0.0;}
    V_roll -=props.globals.getNode("orientation/roll-deg").getValue();
    if(V_roll > 30){V_roll = 30;}
    if(V_roll < -30){V_roll = -30;}
    fdprop.getNode("vbar-roll",1).setValue(V_roll);
    }

get_altoffset = func{
    current_alt = props.globals.getNode("/instrumentation/altimeter/indicated-altitude-ft").getValue();
    var offset = (current_alt - alt_select);
    var alert =0;
    fdprop.getNode("alt-offset").setValue(offset);
    if(offset > -1000 and offset < -300){alert = 1;}
    if(offset < 1000 and offset > 300){alert = 1;}
    fdprop.getNode("alt-alert").setBoolValue(alert);
    if(getprop("/position/altitude-agl-ft") < DH){props.globals.getNode("/autopilot/locks/passive-mode").setBoolValue(1);}
    }

update = func {
    get_altoffset();
    update_nav();
    settimer(update, 0);
    }

