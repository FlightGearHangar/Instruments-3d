var input = func(v) {
		setprop("/instrumentation/cdu/input",getprop("/instrumentation/cdu/input")~v);
	}
	
var delete = func {
		var length = size(getprop("/instrumentation/cdu/input")) - 1;
		setprop("/instrumentation/cdu/input",substr(getprop("/instrumentation/cdu/input"),0,length));
	}
	
var i = 0;

var plusminus = func {	
	var end = size(getprop("/instrumentation/cdu/input"));
	var start = end - 1;
	var lastchar = substr(getprop("/instrumentation/cdu/input"),start,end);
	if (lastchar == "+"){
		me.delete();
		me.input('-');
		}
	if (lastchar == "-"){
		me.delete();
		me.input('+');
		}
	if ((lastchar != "-") and (lastchar != "+")){
		me.input('+');
		}
	}

var cdu = func{
		
		var display = getprop("/instrumentation/cdu/display");
		var serviceable = getprop("/instrumentation/cdu/serviceable");
		title = "";		page = "";
		line1l = "";	line2l = "";	line3l = "";	line4l = "";	line5l = "";	line6l = "";
		line1lt = "";	line2lt = "";	line3lt = "";	line4lt = "";	line5lt = "";	line6lt = "";
		line1c = "";	line2c = "";	line3c = "";	line4c = "";	line5c = "";	line6c = "";
		line1ct = "";	line2ct = "";	line3ct = "";	line4ct = "";	line5ct = "";	line6ct = "";
		line1r = "";	line2r = "";	line3r = "";	line4r = "";	line5r = "";	line6r = "";
		line1rt = "";	line2rt = "";	line3rt = "";	line4rt = "";	line5rt = "";	line6rt = "";
		
		if (display == "MENU") {
			title = "MENU";
			line1l = "<FMC";
			line1r = "SELECT>";
			line2l = "<ACARS";
			line2r = "SELECT>";
			line6l = "<ACMS";
			line6r = "CMC>";
		}
		if (display == "ALTN_NAV_RAD") {
			title = "ALTN NAV RADIO";
		}
		if (display == "APP_REF") {
			title = "APPROACH REF";
			line1lt = "GROSS WT";
			line1rt = "FLAPS    VREF";
			line1l = getprop("/instrumentation/fmc/vspeeds/Vref");
			line4lt = getprop("/autopilot/route-manager/destination/airport");
			line6l = "<INDEX";
			line6r = "THRUST LIM>";
		}
		if (display == "DEP_ARR_INDEX") {
			title = "DEP/ARR INDEX";
			line1l = "<DEP";
			line1ct = "RTE 1";
			line1c = getprop("/autopilot/route-manager/departure/airport");
			line1r = "ARR>";
			line2c = getprop("/autopilot/route-manager/destination/airport");
			line2r = "ARR>";
			line3l = "<DEP";
			line3r = "ARR>";
			line4r = "ARR>";
			line6lt ="DEP";
			line6l = "<----";
			line6c = "OTHER";
			line6rt ="ARR";
			line6r = "---->";
		}
		if (display == "EICAS_MODES") {
			title = "EICAS MODES";
			line1l = "<ENG";
			line1r = "FUEL>";
			line2l = "<STAT";
			line2r = "GEAR>";
			line5l = "<CANC";
			line5r = "RCL>";
			line6r = "SYNOPTICS>";
		}
		if (display == "EICAS_SYN") {
			title = "EICAS SYNOPTICS";
			line1l = "<ELEC";
			line1r = "HYD>";
			line2l = "<ECS";
			line2r = "DOORS>";
			line5l = "<CANC";
			line5r = "RCL>";
			line6r = "MODES>";
		}
		if (display == "FIX_INFO") {
			title = "FIX INFO";
			line1l = sprintf("%3.2f", getprop("/instrumentation/nav[0]/frequencies/selected-mhz-fmt"));
			line1r = sprintf("%3.2f", getprop("/instrumentation/nav[1]/frequencies/selected-mhz-fmt"));
			line2l = sprintf("%3.2f", getprop("/instrumentation/nav[0]/radials/selected-deg"));
			line2r = sprintf("%3.2f", getprop("/instrumentation/nav[1]/radials/selected-deg"));
			line6l = "<ERASE FIX";
		}
		if (display == "IDENT") {
			title = "IDENT";
			line1lt = "MODEL";
			line1l = getprop("/instrumentation/cdu/ident/model");
			line1rt = "ENGINES";
			line2lt = "NAV DATA";
			line1r = getprop("/instrumentation/cdu/ident/engines");
			line6l = "<INDEX";
			line6r = "POS INIT>";
		}
		if (display == "INIT_REF") {
			title = "INIT/REF INDEX";
			line1l = "<IDENT";
			line1r = "NAV DATA>";
			line2l = "<POS";
			line3l = "<PERF";
			line4l = "<THRUST LIM";
			line5l = "<TAKEOFF";
			line6l = "<APPROACH";
			line6r = "MAINT>";
		}
		if (display == "NAV_RAD") {
			title = "NAV RADIO";
			line1lt = "VOR L";
			line1l = sprintf("%3.2f", getprop("/instrumentation/nav[0]/frequencies/selected-mhz-fmt"));
			line1rt = "VOR R";
			line1r = sprintf("%3.2f", getprop("/instrumentation/nav[1]/frequencies/selected-mhz-fmt"));
			line2lt = "CRS";
			line2ct = "RADIAL";
			line2c = sprintf("%3.2f", getprop("/instrumentation/nav[0]/radials/selected-deg"))~"   "~sprintf("%3.2f", getprop("/instrumentation/nav[1]/radials/selected-deg"));
			line2rt = "CRS";
			line3lt = "ADF L";
			line3l = sprintf("%3.2f", getprop("/instrumentation/adf[0]/frequencies/selected-khz"));
			line3rt = "ADF R";
		}
		if (display == "PERF_INIT") {
			title = "PERF INIT";
			line1lt = "GR WT";
			line1rt = "CRZ ALT";
			line1r = getprop("/autopilot/route-manager/cruise/altitude-ft");
			line2lt = "FUEL";
			line3lt = "ZFW";
			line4lt = "RESERVES";
			line4rt = "CRZ CG";
			line5lt = "COST INDEX";
			line5rt = "STEP SIZE";
			line6l = "<INDEX";
			line6r = "THRUST LIM>";	
			if (getprop("/sim/flight-model") == "jsb") {
				line1l = sprintf("%3.1f", (getprop("/fdm/jsbsim/inertia/weight-lbs")/1000));
				line2l = sprintf("%3.1f", (getprop("/fdm/jsbsim/propulsion/total-fuel-lbs")/1000));
				line3l = sprintf("%3.1f", (getprop("/fdm/jsbsim/inertia/empty-weight-lbs")/1000));
			}
			elsif (getprop("/sim/flight-model") == "yasim") {
				line1l = sprintf("%3.1f", (getprop("/yasim/gross-weight-lbs")/1000));
				line2l = sprintf("%3.1f", (getprop("/consumables/fuel/total-fuel-lbs")/1000));

				yasim_emptyweight = getprop("/yasim/gross-weight-lbs");
				yasim_emptyweight -= getprop("/consumables/fuel/total-fuel-lbs");
				yasim_weights = props.globals.getNode("/sim").getChildren("weight");
				for (i = 0; i < size(yasim_weights); i += 1) {
					yasim_emptyweight -= yasim_weights[i].getChild("weight-lb").getValue();
				}

				line3l = sprintf("%3.1f", yasim_emptyweight/1000);
			}
		}
		if (display == "POS_INIT") {
			title = "POS INIT";
			line6l = "<INDEX";
			line6r = "ROUTE>";
		}
		if (display == "POS_REF") {
			title = "POS REF";
			line1lt = "FMC POST";
			line1l = getprop("/position/latitude-string")~" "~getprop("/position/longitude-string");
			line1rt = "GS";
			line1r = sprintf("%3.0f", getprop("/velocities/groundspeed-kt"));
			line5l = "<PURGE";
			line5r = "INHIBIT>";
			line6l = "<INDEX";
			line6r = "BRG/DIST>";
		}
		if (display == "RTE1_1") {
			title = "RTE 1";
			page = "1/2";
			line1lt = "ORIGIN";
			line1l = getprop("/autopilot/route-manager/departure/airport");
			line1rt = "DEST";
			line1r = getprop("/autopilot/route-manager/destination/airport");
			line2lt = "RUNWAY";
			line2l = getprop("/autopilot/route-manager/departure/runway");
			line2rt = "FLT NO";
			line3rt = "CO ROUTE";
			line5l = "<RTE COPY";
			line6l = "<RTE 2";
			if (getprop("/autopilot/route-manager/active") == 1){
				line6r = "ACTIVATE>";
				}
			else {
				line6r = "PERF INIT>";
				}
		}
		if (display == "RTE1_2") {
			title = "RTE 1";
			page = "2/2";
			line1lt = "VIA";
			line1rt = "TO";
			if (getprop("/autopilot/route-manager/route/wp[1]/id") != nil){
				line1r = getprop("/autopilot/route-manager/route/wp[1]/id");
				}
			if (getprop("/autopilot/route-manager/route/wp[2]/id") != nil){
				line2r = getprop("/autopilot/route-manager/route/wp[2]/id");
				}
			if (getprop("/autopilot/route-manager/route/wp[3]/id") != nil){
				line3r = getprop("/autopilot/route-manager/route/wp[3]/id");
				}
			if (getprop("/autopilot/route-manager/route/wp[4]/id") != nil){
				line4r = getprop("/autopilot/route-manager/route/wp[4]/id");
				}
			if (getprop("/autopilot/route-manager/route/wp[5]/id") != nil){
				line5r = getprop("/autopilot/route-manager/route/wp[5]/id");
				}
			line6l = "<RTE 2";
			line6r = "ACTIVATE>";
		}
		if (display == "RTE1_ARR") {
			title = getprop("/autopilot/route-manager/destination/airport")~" ARRIVALS";
			line1lt = "STARS";
			line1rt = "APPROACHES";
			line1r = getprop("/autopilot/route-manager/destination/runway");
			line2lt = "TRANS";
			line3rt = "RUNWAYS";
			line6l = "<INDEX";
			line6r = "ROUTE>";
		}
		if (display == "RTE1_DEP") {
			title = getprop("/autopilot/route-manager/departure/airport")~" DEPARTURES";
			line1lt = "SIDS";
			line1rt = "RUNWAYS";
			line1r = getprop("/autopilot/route-manager/departure/runway");
			line2lt = "TRANS";
			line6l = "<ERASE";
			line6r = "ROUTE>";
		}
		if (display == "RTE1_LEGS") {
			if (getprop("/autopilot/route-manager/active") == 1){
				title = "ACT RTE 1 LEGS";
				}
			else {
				title = "RTE 1 LEGS";
				}
			if (getprop("/autopilot/route-manager/route/wp[1]/id") != nil){
				line1l = getprop("/autopilot/route-manager/route/wp[1]/id");
				}
			if (getprop("/autopilot/route-manager/route/wp[2]/id") != nil){
				line2l = getprop("/autopilot/route-manager/route/wp[2]/id");
				}
			if (getprop("/autopilot/route-manager/route/wp[3]/id") != nil){
				line3l = getprop("/autopilot/route-manager/route/wp[3]/id");
				}
			if (getprop("/autopilot/route-manager/route/wp[4]/id") != nil){
				line4l = getprop("/autopilot/route-manager/route/wp[4]/id");
				}
			if (getprop("/autopilot/route-manager/route/wp[5]/id") != nil){
				line5l = getprop("/autopilot/route-manager/route/wp[5]/id");
				}
			line6l = "<RTE 2 LEGS";
			line6r = "RTE DATA>";
		}
		if (display == "THR_LIM") {
			title = "THRUST LIM";
			line1lt = "SEL";
			line1ct = "OAT";
			line1c = sprintf("%2.0f", getprop("/environment/temperature-degc"))~" °C";
			line1rt = "TO 1 N1";
			line2l = "<TO";
			line2r = "CLB>";
			line3lt = "TO 1";
			line3c = "<SEL> <ARM>";
			line3r = "CLB 1>";
			line4lt = "TO 2";
			line4r = "CLB 2>";
			line6l = "<INDEX";
			line6r = "TAKEOFF>";
		}
		if (display == "TO_REF") {
			title = "TAKEOFF REF";
			line1lt = "FLAP/ACCEL HT";
			line1l = getprop("/instrumentation/fmc/to-flap");
			line1rt = "REF V1";
			line1r = sprintf("%3.0f", getprop("/instrumentation/fmc/vspeeds/V1"));
			line2lt = "E/O ACCEL HT";
			line2rt = "REF VR";
			line2r = sprintf("%3.0f", getprop("/instrumentation/fmc/vspeeds/VR"));
			line3lt = "THR REDUCTION";
			line3rt = "REF V2";
			line3r = sprintf("%3.0f", getprop("/instrumentation/fmc/vspeeds/V2"));
			line4lt = "WIND/SLOPE";
			line4rt = "TRIM   CG";
			line5rt = "POS SHIFT";
			line6l = "<INDEX";
			line6r = "POS INIT>";
		}
		
		if (serviceable != 1){
			title = "";		page = "";
			line1l = "";	line2l = "";	line3l = "";	line4l = "";	line5l = "";	line6l = "";
			line1lt = "";	line2lt = "";	line3lt = "";	line4lt = "";	line5lt = "";	line6lt = "";
			line1c = "";	line2c = "";	line3c = "";	line4c = "";	line5c = "";	line6c = "";
			line1ct = "";	line2ct = "";	line3ct = "";	line4ct = "";	line5ct = "";	line6ct = "";
			line1r = "";	line2r = "";	line3r = "";	line4r = "";	line5r = "";	line6r = "";
			line1rt = "";	line2rt = "";	line3rt = "";	line4rt = "";	line5rt = "";	line6rt = "";
		}
		
		setprop("/instrumentation/cdu/output/title",title);
		setprop("/instrumentation/cdu/output/page",page);
		setprop("/instrumentation/cdu/output/line1/left",line1l);
		setprop("/instrumentation/cdu/output/line2/left",line2l);
		setprop("/instrumentation/cdu/output/line3/left",line3l);
		setprop("/instrumentation/cdu/output/line4/left",line4l);
		setprop("/instrumentation/cdu/output/line5/left",line5l);
		setprop("/instrumentation/cdu/output/line6/left",line6l);
		setprop("/instrumentation/cdu/output/line1/left-title",line1lt);
		setprop("/instrumentation/cdu/output/line2/left-title",line2lt);
		setprop("/instrumentation/cdu/output/line3/left-title",line3lt);
		setprop("/instrumentation/cdu/output/line4/left-title",line4lt);
		setprop("/instrumentation/cdu/output/line5/left-title",line5lt);
		setprop("/instrumentation/cdu/output/line6/left-title",line6lt);
		setprop("/instrumentation/cdu/output/line1/center",line1c);
		setprop("/instrumentation/cdu/output/line2/center",line2c);
		setprop("/instrumentation/cdu/output/line3/center",line3c);
		setprop("/instrumentation/cdu/output/line4/center",line4c);
		setprop("/instrumentation/cdu/output/line5/center",line5c);
		setprop("/instrumentation/cdu/output/line6/center",line6c);
		setprop("/instrumentation/cdu/output/line1/center-title",line1ct);
		setprop("/instrumentation/cdu/output/line2/center-title",line2ct);
		setprop("/instrumentation/cdu/output/line3/center-title",line3ct);
		setprop("/instrumentation/cdu/output/line4/center-title",line4ct);
		setprop("/instrumentation/cdu/output/line5/center-title",line5ct);
		setprop("/instrumentation/cdu/output/line6/center-title",line6ct);
		setprop("/instrumentation/cdu/output/line1/right",line1r);
		setprop("/instrumentation/cdu/output/line2/right",line2r);
		setprop("/instrumentation/cdu/output/line3/right",line3r);
		setprop("/instrumentation/cdu/output/line4/right",line4r);
		setprop("/instrumentation/cdu/output/line5/right",line5r);
		setprop("/instrumentation/cdu/output/line6/right",line6r);
		setprop("/instrumentation/cdu/output/line1/right-title",line1rt);
		setprop("/instrumentation/cdu/output/line2/right-title",line2rt);
		setprop("/instrumentation/cdu/output/line3/right-title",line3rt);
		setprop("/instrumentation/cdu/output/line4/right-title",line4rt);
		setprop("/instrumentation/cdu/output/line5/right-title",line5rt);
		setprop("/instrumentation/cdu/output/line6/right-title",line6rt);
		settimer(cdu,0.2);
    }
_setlistener("/sim/signals/fdm-initialized", cdu); 
