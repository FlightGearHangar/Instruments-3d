####    King KNS-80 Integrated Navigation System   ####
####    Syd Adams    ####
####
####	Must be included in the Set file to run the KNS80 radio 
####
#### Nav Modes  0 = VOR ; 1 = VOR/PAR ; 2 = RNAV/ENR ; 3 = RNAV/APR ;
####

KNS80 = props.globals.getNode("/instrumentation/kns-80",1);
NAV1 = props.globals.getNode("/instrumentation/nav/frequencies/selected-mhz",1);
NAV1_RADIAL = props.globals.getNode("/instrumentation/nav/radials/selected-deg",1);
FDM_ON = 0;

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
	KNS80.getNode("wpt[1]/frequency",1).setValue(10800);
	KNS80.getNode("wpt[1]/radial",1).setValue(0);
	KNS80.getNode("wpt[1]/distance",1).setValue(0.0);
	KNS80.getNode("wpt[2]/frequency",1).setValue(10800);
	KNS80.getNode("wpt[2]/radial",1).setValue(0);
	KNS80.getNode("wpt[2]/distance",1).setValue(0.0);
	KNS80.getNode("wpt[3]/frequency",1).setValue(10800);
	KNS80.getNode("wpt[3]/radial",1).setValue(0);
	KNS80.getNode("wpt[3]/distance",1).setValue(0.0);
	FDM_ON = 1;
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
	NAV1_RADIAL.setValue(KNS80.getNode("wpt[" ~ radial ~ "]/radial").getValue());
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
	NAV1.setValue(KNS80.getNode("wpt[" ~ freq ~ "]/frequency").getValue()* 0.01);
	NAV1_RADIAL.setValue(KNS80.getNode("wpt[" ~ freq ~ "]/radial").getValue());
	});

setlistener("/instrumentation/kns-80/display", func {
	if(FDM_ON == 0){return;}
	var freq = cmdarg().getValue();
	var wpt = KNS80.getNode("wpt[" ~ freq ~ "]/frequency").getValue();
	KNS80.getNode("displayed-frequency").setValue(wpt);
	KNS80.getNode("displayed-radial").setValue(KNS80.getNode("wpt[" ~ freq ~ "]/radial").getValue());
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
