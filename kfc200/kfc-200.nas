####    Bendix-King KFC-200 Flight Director    ####

# off - Off: v-bars hidden
# hdg - Heading: v-bars command a turn to the heading bug
# appr - Approach: bank and pitch commands capture and track LOC and GS
# bc - Reverse Localizer: bank command to caputre and track a reverse LOC
#      course.  GS is locked out.
# arm - Standby mode to compute capture point for nav, appr, or bc.
# cpld - Coupled: Active mode for nav, appr, or bc.
# ga - Go Around: commands wings level and missed approach attitude.
# alt - Altitude hold: commands pitch to hold altitude
# vertical trim - pitch command to adjust altitude at 500 fpm while in alt hold
#                 or pitch attitude at rate of 1 deg/sec when not in alt hold
# yd - Yaw Damper: system senses motion around ayw axis and moves rudder to
#                  oppose yaw.

fdprop = props.globals.getNode("/instrumentation/kfc200",1);
fdmode = "off";
fdmodeV = "off";
fdmode_last = "off";
nav_dist = 0.0;
last_nav_dist = 0.0;
last_nav_time = 0.0;
tth_filter = 0.0;
alt_select = 0.0;
current_alt=0.0;
alt_offset = 0.0;
kfcmode="";
ap_on = 0.0;
alt_alert = 0.0;

setlistener("/sim/signals/fdm-initialized", func {
    fdprop.getChild("fd_on").setBoolValue(0);
    fdprop.getChild("fdmode").setValue(fdmode);
    setprop("/instrumentation/kfc200/alt-offset",alt_offset);
    setprop("/instrumentation/kfc200/fdmodeV","off");
    setprop("/instrumentation/kfc200/alt-alert",alt_alert);
    current_alt = getprop("/instrumentation/altimer/indicated-altitude-ft");
	alt_select = getprop("/autopilot/settings/target-altitude-ft");
    print("KFC-200 ... OK");
    });

setlistener("/instrumentation/kfc200/fd_on", func {
	var fdON = cmdarg().getValue();
    if(fdON){clear_ap();}
    });


setlistener("/instrumentation/kfc200/fdmode", func {
	fdmode = cmdarg().getValue();
    if(fdmode == "off"){clear_ap();return;}
    if(fdmode == "hdg"){
    	setprop("/autopilot/locks/heading","dg-heading-hold");
    	return;}
    if(fdmode == "appr"){
    	setprop("/autopilot/locks/altitude","gs1-hold");
    	setprop("/autopilot/locks/heading","nav1-hold");
    	return;}
    if(fdmode == "nav-arm"){
    	setprop("/autopilot/locks/heading","dg-heading-hold");
    	return;}
    if(fdmode == "nav-cpld"){
    	setprop("/autopilot/locks/heading","nav1-hold");
    	return;}
    if(fdmode == "bc"){
    	setprop("/autopilot/locks/heading","back-coarse");
		return;}

    });

setlistener("/instrumentation/kfc200/fdmodeV", func {
	altmode = cmdarg().getValue();
    if(altmode == "off"){
    setprop("/autopilot/locks/altitude","pitch-hold");;return;}
    if(altmode == "alt"){
    	setprop("/autopilot/locks/altitude","altitude-hold");
    	return;}
    });


clear_ap = func {
	setprop("/autopilot/settings/target-pitch-deg",getprop("orientation/pitch-deg"));
	setprop("/autopilot/locks/heading","wing-leveler");
	setprop("/autopilot/locks/altitude","pitch-hold");
	}

update_nav = func {
    var APmode = fdprop.getChild("fdmode").getValue();
    if(APmode == "nav-arm"){
    	if(getprop("instrumentation/nav/in-range")){
    		var offset = getprop("instrumentation/nav/heading-needle-deflection");
			if(offset < 5 or offset > -5){
				fdprop.getChild("fdmode").setValue("nav-cpld");		    	
    			}else{
    			fdprop.getChild("fdmode").setValue("nav-arm");
    			}
    		}
		}
}

get_altoffset = func(){
	alt_offset = 0.0;
	alt_select = getprop("/autopilot/settings/target-altitude-ft");
	if ( alt_select == nil or alt_select == "" ){ alt_select = 0.0;return (alt_select);}
	current_alt = getprop("/instrumentation/altimeter/indicated-altitude-ft");
	if(current_alt == nil){current_alt = 0.0;}
	alt_offset = (alt_select-current_alt);
	setprop("/instrumentation/kfc200/alt-alert",alt_offset);
	if(alt_offset > 500.0){alt_offset = 500.0;}
	if(alt_offset < -500.0){alt_offset = -500.0;}
	}

update = func {
	get_altoffset();
    update_nav();
    settimer(update, 0);
}

settimer(update, 0);

