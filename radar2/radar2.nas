##### radar2.nas Multiplayer radar and ECM/RWR system.

# Alexis Bory, 2008.
 
# Cycles through the list of multiplayers and tankers, then triggers 
# radar or ECM/RWR computations if those features are enabled in our aircraft -set.xml file.

# Needs radardist.nas for some visibilty computations based on radardist radar and RCS database.
# watch_aimp_models() has to be periodicaly called from one of our aircraft
# nasal files. Do not forget to init both scripts. 

# Input properties:
# -----------------
# instrumentation/radar/enabled (bool) (radar display)
# instrumentation/ecm/enabled (bool) (RWR display)
	# At least one of these true.
# /instrumentation/radar/range : fixed limit to any computation (both radar and ECM/RWR)
# /instrumentation/radar/radar2-range : our own and current display range.
# TODO: /instrumentation/radar/symbols-enabled (bool) as we could also display raw spots on the screen.
# /instrumentation/radar/radar-standby (int), shall be transmited via sim/multiplay/generic/int[2]
	# (until we get a good definition of radar and related properties that could be added to the
	# standard set of MP transmited parameters). With this property set to 1, your radar [1] is not
	# updated anymore but continue to show targets as they where before entering standby [2] it
	# enter silent mode and do not trigger any alert on other players using a RWR.
# /instrumentation/ecm/on-off (bool) (disable RWR computations)

# Output properties:
# ------------------
# /instrumentation/ecm/alert-type1 (bool) alert type 1: at least one weak scan detected. 
# /instrumentation/ecm/alert-type1 (bool) alert type 2: at least one strong scan detected. 
# /ai/models/multiplayer[n]/radar/carrier (bool)
# /ai/models/multiplayer[n]/radar/display (bool)
# /ai/models/multiplayer[n]/radar/ecm-signal (double)
# /ai/models/multiplayer[n]/radar/ecm-signal-norm (int)
	# 0 = none, 1 = strong, 2 = weak, used as a translate prop in the xml animation. 
# /ai/models/multiplayer[n]/radar/ecm_type_num (int)
	# used for RWR which recognize and display the radar type




var watch_i      = 0;
var list_count   = 0;
var radar_able   = nil;
var ecm_able = nil;
var impact_able  = nil;
var synbols_enabled = nil;
var my_radarcorr = 0;
var Mp = props.globals.getNode("ai/models");
var watch_list = [];

# Our aircraft controls.
var OurRadarStandby = props.globals.getNode("instrumentation/radar/radar-standby", 1);
var RangeRadar = props.globals.getNode("instrumentation/radar/range");
var RangeRadar2 = props.globals.getNode("instrumentation/radar/radar2-range");
var EcmOn = props.globals.getNode("instrumentation/ecm/on-off", 1);

var OurAlt = props.globals.getNode("position/altitude-ft");

# ECM warnings.
var EcmAlert1 = props.globals.getNode("instrumentation/ecm/alert-type1", 1);
var EcmAlert2 = props.globals.getNode("instrumentation/ecm/alert-type2", 1);
var ecm_alert1      = 0;
var ecm_alert2      = 0;
var ecm_alert1_last = 0;
var ecm_alert2_last = 0;


var init = func {
	var our_ac_name = getprop("sim/aircraft");
	# Check which feature are enabled for our aircraft to avoid computing useless things.
	radar_able    = props.globals.getNode("instrumentation/radar/enabled").getValue();
	ecm_able    = props.globals.getNode("instrumentation/ecm/enabled").getValue();
	# TODO: synbols_enabled = props.globals.getNode("instrumentation/radar/symbols_enabled");
	# Get our radar max range.
	if (radar_able) { 
		my_radarcorr = radardist.my_maxrange( our_ac_name ); # in kilometers
	}
	if ( OurRadarStandby.getValue() == nil ) {
		OurRadarStandby.setBoolValue(0);
	}
}


# Main loop.
var watch_aimp_models = func {
	# Cycle through an ordered list of multiplayers and tankers.
	if ( watch_i == 0 ) {
		list_count = get_list();
	}
	var target_type = watch_list[watch_i][0];
	var target_index = watch_list[watch_i][1];
	var target_string = "ai/models/" ~ target_type ~ "[" ~ target_index ~ "]";
	target_process( target_string );
	if ( watch_i == ( list_count - 1 )) {
		watch_i = 0;
	} else {
		watch_i += 1;
	}
}


var get_list = func {
	watch_list = [];
	var raw_list = Mp.getChildren();
	foreach( var c; raw_list ) {
		var type = c.getName();
		# TODO: watch for AI carriers instead of only reconize mp-carriers.
		if (type == "multiplayer" or type == "tanker") {
			append(watch_list, [type, c.getIndex()]);
		}
	}
	return size(watch_list);
}





var target_process = func ( target ) {
	var TNode         = props.globals.getNode(target);
	var TRadar        = TNode.getNode("radar");
	var TRadarStandby = TNode.getNode("sim/multiplay/generic/int[2]");
	# This propery used by ECM over MP should be standardized,
	# like "ai/models/multiplayer[0]/radar/radar-standby"
	var THeading      = TNode.getNode("orientation/true-heading-deg");
	var TInRange      = TRadar.getNode("in-range");
	if ( TInRange == nil ) { return }
	var TCarrier      = TRadar.getNode("carrier", 1);
	var TDisplay      = TRadar.getNode("display", 1);
	var TEcmSignal    = TRadar.getNode("ecm-signal", 1);
	var TEcmSignalNorm    = TRadar.getNode("ecm-signal-norm", 1);
	var TEcmTypeNum   = TRadar.getNode("ecm_type_num", 1);
	# Set variables.
	var t_carrier     = 0;
	var t_display     = 0;
	var t_ecm_signal  = 0;
	var t_ecm_signal_norm  = 0;
	var t_radar_standby = 0;
	var t_ecm_type_num = 0;

	if ( TRadarStandby != nil ) {
		t_radar_standby = TRadarStandby.getValue();
		if ( t_radar_standby == nil ) {
			t_radar_standby = 0;
		} elsif ( t_radar_standby != 1 ) {
			t_radar_standby = 0;
		}
	}	
	var our_radar_standby = OurRadarStandby.getValue();
	var t_in_range = TInRange.getValue();
	if ( t_in_range ) {
		var TPosition     = TNode.getNode("position");
		var TRange        = TRadar.getNode("range-nm");
		var t_range       = TRange.getValue();
		var TBearing      = TRadar.getNode("bearing-deg");
		var t_bearing     = TBearing.getValue();
		var TAlt          = TPosition.getNode("altitude-ft");
		var t_alt         = TAlt.getValue();
		var TDrawRangeNm  = TRadar.getNode("draw-range-nm", 1);
		var TRoundedAlt   = TRadar.getNode("rounded-alt-ft", 1);
		var t_heading     = THeading.getValue();
		var range_radar   = RangeRadar.getValue();
		var range_radar2   = 0;
		if ( RangeRadar2 != nil ) { range_radar2 = RangeRadar2.getValue(); }
		var TPath         = TNode.getNode("sim/model/path");
		var TACType       = TNode.getNode("sim/model/ac-type");
		if (( t_bearing == nil ) or ( t_alt == nil ) or ( TPath == nil )) {
			return;
		}
		var t_ac_type = "none";
		if ( TACType != nil ) { t_ac_type = TACType.getValue() }
		if ( t_ac_type == "MP-Nimitz" or t_ac_type == "MP-Eisenhower") {
			t_carrier = 1;
		}
		# TODO: add AWAKS and ATC.
		var our_alt = OurAlt.getValue();
		var horizon = radardist.radar_horizon( our_alt, t_alt );
		# RADAR stuff.
		# Check if mp within our radar field (hard coded 74°) and if detectable.
		print( radar_able ~ "  " ~ t_range ~ "  " ~ range_radar2 ~ "  " ~ our_radar_standby );
		if ( radar_able and t_range <= range_radar2 and !our_radar_standby ) {
			var true_heading = getprop("orientation/heading-deg");
			var deviation_deg = deviation_normdeg(true_heading, t_bearing);
			if ( deviation_deg > -37  and  deviation_deg < 37 and radardist.radis(target, my_radarcorr) and t_range < horizon ) {
				# Compute mp position in our radar display. (Horizontal situation)
				if ( range_radar2 == 0 ) { range_radar2 = 0.00000001 }
				var factor_range_radar = 0.15 / range_radar2;
				var draw_radar = factor_range_radar * t_range;
				TDrawRangeNm.setValue(draw_radar);
				# Compute first digit of mp altitude rounded to nearest thousand. (labels).
				var rounded_alt = rounding1000(t_alt) / 1000;
				TRoundedAlt.setValue(rounded_alt);
				t_display = 1;
			}
		}
		# ECM/RWR stuff.
		# Test if target has a radar. Computes if we are illuminated.
		ecm_on = EcmOn.getValue();
		if ( ecm_able and ecm_on and t_radar_standby == 0 ) {
			# TODO: overide display when alert.
			t_path = TPath.getValue();
			var t_name = radardist.get_aircraft_name(target);
			var t_maxrange = radardist.my_maxrange(t_name); # in kilometer, 0 is unknown or no radar.
			if ( t_maxrange > 0  and t_range < horizon ) {
				# Test if we are in its radar field (hard coded 74°) or if we have a carrier.
				# Compute the signal strength.
				var t_reciprocal_bearing = geo.normdeg(t_bearing + 180);
				var our_deviation_deg = deviation_normdeg(t_heading, t_reciprocal_bearing);
				if ( our_deviation_deg < 0 ) { our_deviation_deg *= -1 }
				if ( our_deviation_deg < 37 or t_carrier == 1 ) {
					t_ecm_signal = ( (((-our_deviation_deg/20)+2.5)*(!t_carrier )) + (-t_range/20) + 2.6 + (t_carrier*1.8));
					t_ecm_type_num = radardist.get_ecm_type_num(t_name);
				}
			}
			# Compute global threat situation for undiscriminant warning lights
			# and discrete (normalized) definition of threat strength.
			if ( t_ecm_signal > 1 and t_ecm_signal < 3 ) {
				EcmAlert1.setBoolValue(1);
				ecm_alert1 = 1;
				t_ecm_signal_norm = 2;
			} elsif ( t_ecm_signal >= 3 ) {
				EcmAlert2.setBoolValue(1);
				ecm_alert2 = 1;
				t_ecm_signal_norm = 1;
			}
		}
	}
	# Outputs:
	if ( ! our_radar_standby ) {
		# If stanby: stop updating but do not erase targets positions.
		TCarrier.setBoolValue(t_carrier);
		TDisplay.setBoolValue(t_display);
	}
	if ( watch_i == 0 ) {
		if ( ecm_alert1 == 0 and ecm_alert1_last == 0 ) { EcmAlert1.setBoolValue(0) }
		if ( ecm_alert2 == 0 and ecm_alert1_last == 0 ) { EcmAlert2.setBoolValue(0) }
		# Avoid alert blinking at each loop.
		ecm_alert1_last = ecm_alert1;
		ecm_alert2_last = ecm_alert2;
		ecm_alert1 = 0;
		ecm_alert2 = 0;
	}	
	TEcmSignal.setValue(t_ecm_signal);
	TEcmSignalNorm.setIntValue(t_ecm_signal_norm);
	TEcmTypeNum.setIntValue(t_ecm_type_num);
}


# Utilities.
var deviation_normdeg = func(our_heading, target_bearing) {
			var dev_norm = our_heading - target_bearing;
			while (dev_norm < -180) dev_norm += 360;
			while (dev_norm > 180) dev_norm -= 360;
			return(dev_norm);
}

var rounding1000 = func(n) {
	var a = int( n / 1000 );
	var l = ( a + 0.5 ) * 1000;
	n = (n >= l) ? ((a + 1) * 1000) : (a * 1000);
	return( n );
}


