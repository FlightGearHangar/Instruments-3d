####    King KNS-80 Integrated Navigation System   ####
####    Syd Adams    ####
####
####	Must be included in the Set file to run the KNS80 radio 
####

KNS80 = props.globals.getNode("/instrumentation/kns-80",1);
NAV1 = props.globals.getNode("/instrumentation/nav/frequencies/selected-mhz",1);
FDM_ON = 0;

setlistener("/sim/signals/fdm-initialized", func {
	KNS80.getNode("serviceable",1).setBoolValue(1);
	KNS80.getNode("volume",1).setValue(0.5);
	KNS80.getNode("display",1).setValue(0);
	KNS80.getNode("use",1).setValue(0);
	KNS80.getNode("displayed-frequency",1).setValue(NAV1.getValue()* 100);	
	KNS80.getNode("frequency[0]",1).setValue(NAV1.getValue()* 100);
	KNS80.getNode("frequency[1]",1).setValue(10800);
	KNS80.getNode("frequency[2]",1).setValue(10800);
	KNS80.getNode("frequency[3]",1).setValue(10800);
	FDM_ON = 1;
	print("KNS-80 Nav System ... OK");
	});

setlistener("/instrumentation/kns-80/displayed-frequency", func {
	if(FDM_ON == 0){return;}
	var freq = cmdarg().getValue();
	var num = KNS80.getNode("display").getValue();
	var freq_use = KNS80.getNode("use").getValue();
	KNS80.getNode("frequency[" ~ num ~ "]").setValue(freq);
	NAV1.setValue(KNS80.getNode("frequency[" ~ freq_use ~ "]").getValue() * 0.01);
	});

setlistener("/instrumentation/kns-80/serviceable", func {
	if(FDM_ON == 0){return;}
	setprop("/instrumentation/nav/serviceable",cmdarg().getValue());
	setprop("/instrumentation/dme/serviceable",cmdarg().getValue());
	});

setlistener("/instrumentation/kns-80/volume", func {
	if(FDM_ON == 0){return;}
	#setprop("/instrumentation/nav/volume",cmdarg().getValue());
	setprop("/instrumentation/dme/volume",cmdarg().getValue());
	});

setlistener("/instrumentation/kns-80/use", func {
	if(FDM_ON == 0){return;}
	var freq = cmdarg().getValue();
	NAV1.setValue(KNS80.getNode("frequency[" ~ freq ~ "]").getValue()* 0.01);
	});

setlistener("/instrumentation/kns-80/display", func {
	if(FDM_ON == 0){return;}
	var freq = cmdarg().getValue();
	KNS80.getNode("displayed-frequency").setValue(KNS80.getNode("frequency[" ~ freq ~ "]").getValue());
	});

