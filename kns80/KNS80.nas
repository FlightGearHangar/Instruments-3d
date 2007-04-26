#<PropertyList><module>Aerostar-700</module><script><![CDATA[
####    King KNS-80 Integrated Navigation System   ####
####    Syd Adams    ####
####    Ron Jensen   ####
####
####	Must be included in the Set file to run the KNS80 radio 
####
#### Nav Modes  0 = VOR ; 1 = VOR/PAR ; 2 = RNAV/ENR ; 3 = RNAV/APR ;
####

KNS80 = props.globals.getNode("/instrumentation/kns-80",1);
NAV1 = props.globals.getNode("/instrumentation/nav/frequencies/selected-mhz",1);
NAV1_RADIAL = props.globals.getNode("/instrumentation/nav/radials/selected-deg",1);
FDM_ON = 0;
dsp_flash = props.globals.getNode("instrumentation/kns-80/flash", 1);
aircraft.light.new("instrumentation/kns-80/dsp-state", [0.5, 0.5],dsp_flash);

# Properties

NAV1_ACTUAL = props.globals.getNode("/instrumentation/nav/radials/actual-deg",1);
NAV1_TO_FLAG = props.globals.getNode("/instrumentation/nav[0]/to-flag",1);
NAV1_FROM_FLAG = props.globals.getNode("/instrumentation/nav[0]/from-flag",1);
NAV1_HEADING_NEEDLE_DEFLECTION = props.globals.getNode("/instrumentation/nav[0]/heading-needle-deflection",1);

NAV1_IN_RANGE = props.globals.getNode("/instrumentation/nav[0]/in-range",1);
DME1_IN_RANGE = props.globals.getNode("/instrumentation/dme[0]/in-range",1);

# outputs
CDI_NEEDLE = props.globals.getNode("/instrumentation/gps/cdi-deflection",1);
TO_FLAG    = props.globals.getNode("/instrumentation/gps/to-flag",1);
FROM_FLAG  = props.globals.getNode("/instrumentation/gps/from-flag",1);


RNAV = props.globals.getNode("/instrumentation/rnav",1);
# distance, radial from VOR Station
# rho, theta: distance and radial for phantom station
# range, bearing: distance and radial from phantom station

PI=3.14159265;
D2R=PI/180;
R2D=180/PI;

var unnil = func(n) { n == nil ? 0 : n }


# 0.1 second cron
sec01cron = func {
   updateRNAV();

   # schedule the next call
   settimer(sec01cron,0.1);
}


# general initialization
init = func {
   # schedule the 1st call
   settimer(sec01cron,1);
}

var updateRNAV = func{

# check to see if we are in-range
    if( NAV1_IN_RANGE.getValue()==0) {
        return;
    }
    var dme_valid=DME1_IN_RANGE.getValue();
    if( dme_valid == 0) {
        return;
    }
    if( dme_valid == nil) {
        return;
    }

#### Nav Modes  0 = VOR ; 1 = VOR/PAR ; 2 = RNAV/ENR ; 3 = RNAV/APR ;
    var mode = KNS80.getNode("nav-mode").getValue();
    use =KNS80.getNode("use").getValue();
    distance=getprop("/instrumentation/dme/indicated-distance-nm");
    selected_radial = NAV1_RADIAL.getValue();
    radial = NAV1_ACTUAL.getValue();
    rho = KNS80.getNode("wpt[" ~ use ~ "]/distance").getValue();
    theta = KNS80.getNode("wpt[" ~ use ~ "]/radial").getValue();
    fangle = 0;

    radial = unnil(radial);
    theta = unnil(theta);
    rho = unnil(rho);
    distance=unnil(distance);

    x1 = distance * math.cos( radial*D2R );
    y1 = distance * math.sin( radial*D2R );
    x2 = rho * math.cos( theta*D2R );
    y2 = rho * math.sin( theta*D2R );

    range = math.sqrt( (x1-x2)*(x1-x2) + (y1-y2)*(y1-y2) );
    bearing = math.atan2 (( y1-y2), (x1-x2))*R2D;

    if(bearing < 0) bearing += 360;
    abearing = bearing > 180 ? bearing - 180 : bearing + 180;

    if( mode == 0){
    #	print("KNS-80 VOR");
        needle_deflection = (NAV1_HEADING_NEEDLE_DEFLECTION.getValue());
        range = distance;
    #	return;
    }
    if ( mode == 1){
    #	print("KNS-80 VOR/PAR");
        fangle = math.abs(selected_radial - radial);
        needle_deflection = math.sin((selected_radial - radial) * D2R) * distance * 2;
    }
    if ( mode == 2){
    #	print("KNS-80 RNAV/ENR");
        fangle = math.abs(selected_radial - bearing);
        needle_deflection = math.sin((selected_radial - bearing) * D2R) * range * 2;
    } 
    if ( mode == 3){
    #	print("KNS-80 RNAV/APR");
        fangle = math.abs(selected_radial - bearing);
        needle_deflection = math.sin((selected_radial - bearing) * D2R) * range * 8;
    }

    if ( needle_deflection >  10) needle_deflection = 10;
    if ( needle_deflection < -10) needle_deflection =-10;
    if (fangle < 90 or fangle >270){
        from_flag=1;
        to_flag  =0;
    } else {
        from_flag=0;
        to_flag  =1;
    }

# valid=1;
    RNAV.getNode("heading-needle-deflection", 1).setValue(needle_deflection);
    CDI_NEEDLE.setValue(needle_deflection);
    TO_FLAG.setValue(to_flag);
    FROM_FLAG.setValue(from_flag);
    setprop("/instrumentation/rnav/indicated-distance-nm", range);
    setprop("/instrumentation/rnav/reciprocal-radial-deg", abearing);
    setprop("/instrumentation/rnav/actual-deg", bearing);
##debugging
##setprop("/instrumentation/rnav/debug-angle-deg", angle*R2D);
##setprop("/instrumentation/rnav/debug-anglef-deg", fangle);
##setprop("/instrumentation/rnav/debug-theta-deg",theta);
##setprop("/instrumentation/rnav/debug-rho", rho);


}

_setlistener("/sim/signals/fdm-initialized", func {
    KNS80.getNode("serviceable",1).setBoolValue(1);
    KNS80.getNode("volume-adjust",1).setValue(0);
    KNS80.getNode("data-adjust",1).setValue(0);
    KNS80.getNode("volume",1).setValue(0.5);
    KNS80.getNode("display",1).setValue(0);
    KNS80.getNode("use",1).setValue(0);
    KNS80.getNode("data-mode",1).setValue(0);
    KNS80.getNode("nav-mode",1).setValue(0);
    KNS80.getNode("dme-hold",1).setBoolValue(0);
    KNS80.getNode("displayed-frequency",1).setValue(NAV1.getValue()* 100);
    KNS80.getNode("displayed-distance",1).setValue(0);
    KNS80.getNode("displayed-radial",1).setValue(NAV1_RADIAL.getValue());
    KNS80.getNode("wpt[0]/frequency",1).setValue(NAV1.getValue()* 100);
    KNS80.getNode("wpt[0]/radial",1).setValue(NAV1_RADIAL.getValue());
    KNS80.getNode("wpt[0]/distance",1).setValue(0.0);
    KNS80.getNode("wpt[1]/frequency",1).setValue(11570);
    KNS80.getNode("wpt[1]/radial",1).setValue(120);
    KNS80.getNode("wpt[1]/distance",1).setValue(7.2);
    KNS80.getNode("wpt[2]/frequency",1).setValue(11570);
    KNS80.getNode("wpt[2]/radial",1).setValue(270);
    KNS80.getNode("wpt[2]/distance",1).setValue(5.8);
    KNS80.getNode("wpt[3]/frequency",1).setValue(10800);
    KNS80.getNode("wpt[3]/radial",1).setValue(0);
    KNS80.getNode("wpt[3]/distance",1).setValue(0.0);
    props.globals.getNode("/instrumentation/nav/ident").setBoolValue(0);
    FDM_ON = 1;
    init();
    print("KNS-80 Nav System ... OK");
    },1);

setlistener("/instrumentation/kns-80/volume-adjust", func {
    if(FDM_ON != 0){
    var amnt = cmdarg().getValue() * 0.05;
    cmdarg().setValue(0);
    var vol = KNS80.getChild("volume").getValue();
    vol+= amnt;
    if(vol > 1.0){vol = 1.0;}
    if(vol < 0.0){vol = 0.0;KNS80.getNode("serviceable").setBoolValue(0);}
    if(vol > 0.0){KNS80.getNode("serviceable").setBoolValue(1);}
    KNS80.getNode("volume").setValue(vol);
    KNS80.getNode("volume-adjust").setValue(0);
        }
    });

setlistener("/instrumentation/kns-80/data-adjust", func {
    if(FDM_ON != 0){
    var dmode = KNS80.getNode("data-mode").getValue();
    var num = cmdarg().getValue();
    cmdarg().setValue(0);
    if(dmode == 0){
        if(num == -1 or num ==1 ){num = num *5;}else{num = num *10;}
        var newfreq = KNS80.getNode("displayed-frequency").getValue();
        newfreq += num;
        if(newfreq > 11895){newfreq -= 1100;}
        if(newfreq < 10800){newfreq += 1100;}
        KNS80.getNode("displayed-frequency").setValue(newfreq);
        return;
        }
    if(dmode == 1){
        var newrad = KNS80.getNode("displayed-radial").getValue();
        newrad += num;
        if(newrad > 359){newrad -= 360;}
        if(newrad < 0){newrad += 360;}
        KNS80.getNode("displayed-radial").setValue(newrad);
        return;
        }
    if(dmode == 2){
        var newdist = KNS80.getNode("displayed-distance").getValue();
        newdist += num;
        if(newdist > 99){newdist -= 100;}
        if(newdist < 0){newdist += 100;}
        KNS80.getNode("displayed-distance").setValue(newdist);
        return;
        }
        }
    });

setlistener("/instrumentation/kns-80/displayed-frequency", func {
    if(FDM_ON != 0){
    var freq = cmdarg().getValue();
    var num = KNS80.getNode("display").getValue();
    var use = KNS80.getNode("use").getValue();
    KNS80.getNode("wpt[" ~ num ~ "]/frequency").setValue(freq);
    NAV1.setValue(KNS80.getNode("wpt[" ~ use ~ "]/frequency").getValue() * 0.01);
        }
    });

setlistener("/instrumentation/kns-80/displayed-radial", func {
    if(FDM_ON != 0){
    var rad = cmdarg().getValue();
    var num = KNS80.getNode("display").getValue();
    var radial = KNS80.getNode("use").getValue();
    KNS80.getNode("wpt[" ~ num ~ "]/radial").setValue(rad);
        }
    });

setlistener("/instrumentation/kns-80/displayed-distance", func {
    if(FDM_ON != 0){
    var dis = cmdarg().getValue();
    var num = KNS80.getNode("display").getValue();
    KNS80.getNode("wpt[" ~ num ~ "]/distance").setValue(dis);
    }
});

setlistener("/instrumentation/kns-80/serviceable", func {
    if(FDM_ON != 0){
    setprop("/instrumentation/nav/serviceable",cmdarg().getValue());
    setprop("/instrumentation/dme/serviceable",cmdarg().getValue());
        }
    });

setlistener("/instrumentation/kns-80/volume", func {
    if(FDM_ON == 0){return;}
    setprop("/instrumentation/nav/volume",cmdarg().getValue());
    setprop("/instrumentation/dme/volume",cmdarg().getValue());
    });

setlistener("/instrumentation/kns-80/use", func {
    if(FDM_ON == 0){return;}
    var freq = cmdarg().getValue();
    KNS80.getNode("flash").setValue(0);
    KNS80.getNode("data-mode",1).setValue(0);
    NAV1.setValue(KNS80.getNode("wpt[" ~ freq ~ "]/frequency").getValue()* 0.01);
    });

setlistener("/instrumentation/kns-80/display", func {
    if(FDM_ON == 0){return;}
    var freq = cmdarg().getValue();
    var test = KNS80.getNode("use").getValue();
    var wpt = KNS80.getNode("wpt[" ~ freq ~ "]/frequency").getValue();
    KNS80.getNode("displayed-frequency").setValue(wpt);
    KNS80.getNode("displayed-distance").setValue(KNS80.getNode("wpt[" ~ freq ~ "]/distance").getValue());
    KNS80.getNode("displayed-radial").setValue(KNS80.getNode("wpt[" ~ freq ~ "]/radial").getValue());
    KNS80.getNode("data-mode",1).setValue(0);
    if(test != freq){
        KNS80.getNode("flash").setValue(1);
        }else{
        KNS80.getNode("flash").setValue(0);
        }
    });

setlistener("/instrumentation/kns-80/dme-hold", func {
    if(FDM_ON == 0){return;}
    if(cmdarg().getBoolValue()){
        props.globals.getNode("instrumentation/dme/frequencies/selected-mhz").setValue(NAV1.getValue());
        props.globals.getNode("instrumentation/dme/frequencies/source").setValue("/instrumentation/dme/frequencies/selected-mhz");
        }else{
            props.globals.getNode("instrumentation/dme/frequencies/selected-mhz").setValue("");
                props.globals.getNode("instrumentation/dme/frequencies/source").setValue("/instrumentation/nav[0]/frequencies/selected-mhz");
            }
    });

#  ]]></script></PropertyList>
