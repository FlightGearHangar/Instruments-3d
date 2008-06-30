var screenModeAndSettings = { # screen for changing the GPS mode and settings
    help : 0,
    mode_: 0,
    quit_help : func {
	me.help = 0;
	me.lines();
    },
    right : func {
	if (page == 1)
	    alt_unit = cycle(2, alt_unit, arg[0]);
	elsif (page == 2)
	    dist_unit = cycle(2, dist_unit, arg[0]);
	elsif (page == 3)
	    spd_unit = cycle(2, spd_unit, arg[0]);
	elsif (page == 4)
	    thresold_alert_index = cycle(size(thresold_alert), thresold_alert_index, arg[0]);
	elsif (page == 5)
	    thresold_next_waypoint = cycle(10, thresold_next_waypoint, arg[0]);
    },
    changemode : func {
	if (page == 0) me.mode_ = cycle(4, me.mode_, arg[0]);
    },
    enter : func {
	if (!me.help) {
	    display ([
	    "HERE THERE WILL SEAT",
	    "A SIMPLE EXPLANATION",
	    "TEXT ABOUT USE OF GPS",
	    "PRESS ANY OF THE",
	    "THREE BUTTONS"
	    ]);
	    me.help = 1;
	}
	else me.quit_help();
    },
    escape : func {
	if (me.help) me.quit_help();
	else me.dispatch();
    },
    start : func {
	if (me.help) me.quit_help();
	else {
	    mode = me.mode_ + 1;
	    page = 0;
	    displayed_screen = page_list[mode][page];
	}
    },
    lines : func {
	if (page == 0) {
	    if    (me.mode_ == 0) mode_str = "POSITION";
	    elsif (me.mode_ == 1) mode_str = "AIRPORT";
	    elsif (me.mode_ == 2) mode_str = "TURNPOINT";
	    else		  mode_str = "TASK";
	    l0 = "  -- GPS STATUS : --";
	    l1 = sprintf("MODE: %s", mode_str);
	}
	else {
	    if (page < 4)
		l0 = "  -- SET UNITS --";
	    else
		l0 = "- SET TIME THRESOLDS -";
	    if (page == 1) 
		l1 = sprintf("ALT: %s", alt_unit_full_name[alt_unit]);
	    elsif (page == 2)
		l1 = sprintf("DIST: %s", dist_unit_full_name[dist_unit]);
	    elsif (page == 3)
		l1 = sprintf("SPEED: %s", spd_unit_full_name[spd_unit]);
	    elsif (page == 4)
		l1 = sprintf("ALERT: %d s", thresold_alert[thresold_alert_index]);
	    elsif (page == 5)
		l1 = sprintf("NEXT WAYPOINT: %d s", thresold_next_waypoint);
	}
	display ([
	l0,
	l1,
	"",
	"ENTER -> HELP",
	"START -> ENTER MODE"
	]);
    }
};

var screenPositionMain = { # screens for POSITION mode
    coord : [0,0,0],
    right : func {
    },
    enter : func {
	var ac = geo.aircraft_position();
	me.coord = [ac.lat(), ac.lon(), ac.alt()];
	EditMode(6, "EDIT WAYPOINT ID", "SAVE");
    },
    escape : func {
    },
    start : func {
	if (mode == 5) {
	    add_bookmark(arg[0], arg[0], "GPS", me.coord);
	    return 1; #make gps quitting edition mode, back to previous mode and page
	}
    },
    lines : func {
	display ([
	sprintf("LAT: %s", 
	    props.globals.getNode("/position/latitude-string",1).getValue()),
	sprintf("LON: %s", 
	    props.globals.getNode("/position/longitude-string",1).getValue()),
	sprintf("ALT: %d %s", 
	    gps_data.getNode("indicated-altitude-ft").getValue() * alt_conv[0][alt_unit],
	    alt_unit_short_name[alt_unit]),
	sprintf("HDG: %d°", 
	    gps_data.getNode("indicated-track-true-deg").getValue()),
	sprintf("SPD: %d %s", 
	    gps_data.getNode("indicated-ground-speed-kt").getValue() * dist_conv[0][spd_unit],
	    spd_unit_short_name[spd_unit])
	]);
    }
};

var screenOdometers = {
    begin_time : 0,
    elapsed : 0,
    odotime : func {
	me.elapsed = props.globals.getNode("/sim/time/elapsed-sec",1).getValue() - me.begin_time;
        seconds_to_string(me.elapsed);
    },
    right: func {
    },
    enter: func {
    },
    escape: func {
	startpos = geo.Coord.new(geo.aircraft_position());
	me.begin_time = props.globals.getNode("/sim/time/elapsed-sec",1).getValue();
	gps_data.getNode("odometer",1).setDoubleValue(0.0);
    },
    start: func {
    },
    lines: func {
	    display ([
	    sprintf("ODO: %d %s", 
	        gps_data.getNode("odometer",1).getValue() * dist_conv[0][dist_unit],
		dist_unit_short_name[dist_unit]),
	    sprintf("TRIP: %d %s", 
		gps_data.getNode("trip-odometer",1).getValue() * dist_conv[0][dist_unit],
		dist_unit_short_name[dist_unit]),
	    sprintf("TIME: %s", 
		me.odotime()),
	    sprintf("AVG HDG: %03d*", 
		startpos.course_to(geo.aircraft_position())),
	    sprintf("AVG SPD: %d %s",
		gps_data.getNode("odometer",1).getValue() / me.elapsed * 3600 * dist_conv[0][spd_unit],
		spd_unit_short_name[spd_unit])
	    ]);
    }
};

var screenWindInfos = {
    right: func {
    },
    enter: func {
    },
    escape: func {
    },
    start: func {
    },
    lines: func {
	if (gps_data.getNode("indicated-ground-speed-kt").getValue() > 10)
	    display ([
	    "WIND INFOS",
	    sprintf("SPEED: %d %s", 
	        props.globals.getNode("/environment/wind-speed-kt",1).getValue() * dist_conv[0][dist_unit],
	        spd_unit_short_name[spd_unit]),
	    sprintf("FROM: %d*",
	        props.globals.getNode("/environment/wind-from-heading-deg",1).getValue()),
	    "", 
	    "" 
	    ]);
	else
	    display ([
	    "WIND INFOS",
	    sprintf("SPEED: --- %s", spd_unit_short_name[spd_unit]),
	    "FROM: ---*",
	    "", 
	    "" 
	    ]);
    }
};

var screenNavigationMain = {
    nextWaypoint : func {
	waypointindex += 1;
	next = gps_data.getNode("route/Waypoint[" ~ waypointindex ~ "]/",1);
	if (next != nil) {
	    gps_wp.getNode("wp/longitude-deg",1).setValue(gps_wp.getNode("wp[1]/longitude-deg",1).getValue());
	    gps_wp.getNode("wp/latitude-deg",1).setValue(gps_wp.getNode("wp[1]/latitude-deg",1).getValue());
	    gps_wp.getNode("wp/altitude-ft",1).setValue(gps_wp.getNode("wp[1]/altitude-ft",1).getValue());
	    gps_wp.getNode("wp/ID",1).setValue(gps_wp.getNode("wp[1]/ID",1).getValue());
 
	    gps_wp.getNode("wp[1]/longitude-deg",1).setValue(next.getNode("longitude-deg",1).getValue());
	    gps_wp.getNode("wp[1]/latitude-deg",1).setValue(next.getNode("latitude-deg",1).getValue());
	    gps_wp.getNode("wp[1]/altitude-ft",1).setValue(next.getNode("altitude-ft",1).getValue());
	    gps_wp.getNode("wp[1]/ID",1).setValue(next.getNode("ID",1).getValue());
	}
	else {
	    page = 0; #screenTaskSelect
	    refresh_display();
	}
    },
    right : func {
    },
    enter : func {
	if (mode == 4) me.nextWaypoint();
	else add_waypoint(gps_wp.getNode("wp[1]/ID",1).getValue(),
			  gps_wp.getNode("wp[1]/name",1).getValue(),
			  gps_wp.getNode("wp[1]/waypoint-type",1).getValue(),
			  [gps_wp.getNode("wp[1]/latitude-deg",1).getValue(),
			   gps_wp.getNode("wp[1]/longitude-deg",1).getValue(),
			   gps_wp.getNode("wp[1]/altitude-ft",1).getValue()]);
    },
    escape : func {
    },
    start : func {
	if (mode != 4) save_route();
    },
    lines : func {
	me.waypoint = gps_wp.getNode("wp[1]",1);
	crs_deviation = gps_wp.getNode("leg-course-deviation-deg").getValue();
	if (crs_deviation > 5)
	    me.graph = "[- - - - - ^ > > > > >]";
	elsif (crs_deviation < -5)
	    me.graph = "[< < < < < ^ - - - - -]";
	else {
	    me.graph = "[+ + + + + ^ + + + + +]";
	    cursor = int((crs_deviation * 2) + 11);
	    me.graph = substr(me.graph,0, cursor) ~ "|" ~ substr(me.graph, cursor+1, size(me.graph));
	}
	display ([
	sprintf("ID: %s [%s]",
	    me.waypoint.getNode("ID",1).getValue() != nil ? me.waypoint.getNode("ID",1).getValue() : "WP NOT NAMED!",
	    me.waypoint.getNode("type",1).getValue() != nil ? me.waypoint.getNode("type").getValue() : "---"),
	sprintf("BRG: %d°  DST: %d %s",
	    me.waypoint.getNode("bearing-mag-deg",1).getValue(),
	    me.waypoint.getNode("distance-nm",1).getValue() * dist_conv[0][dist_unit],
	    dist_unit_short_name[dist_unit]),
	sprintf("XCRS: %d* (%.1f %s)",
	    gps_wp.getNode("leg-course-deviation-deg").getValue(), 
	    gps_wp.getNode("leg-course-error-nm").getValue() * dist_conv[0][dist_unit],
	    dist_unit_short_name[dist_unit]),
	sprintf("TTW: %s", 
	    me.waypoint.getNode("TTW").getValue()),
	me.graph
	]);

    }
};

var screenEdit = {
    previous_mode: 0,
    previous_page: 0,
    alphanum: ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P",
	       "Q","R","S","T","U","V","W","X","Y","Z",
	       "0","1","2","3","4","5","6","7","8","9"],
    numeric: ["0","1","2","3","4","5","6","7","8","9","."],
    start_command: "",
    edit_zone: "",
    edit_title : "",
    carset: [],
    map: [],
    pointer: 0,
    value: 0,
    init: func (length, title, start_command, set = 0) {
	for (var i = 0; i < length; i += 1) append(me.map, "-");
	me.edit_title = title;
	me.start_command = start_command;
	me.carset = set != 0 ? me.numeric : me.alphanum;
	left_knob(0); # force display
    },
    right : func {
	me.value = cycle(size(me.carset), me.value, arg[0]);
	me.map[me.pointer] = me.carset[me.value];
    },
    enter : func {
	me.pointer = cycle(size(me.map), me.pointer, 1);
	me.value = 0;
    },
    escape : func {
	me.map = [];
	me.pointer = 0;
	me.value = 0;
	me.start_command = "";
	me.edit_zone = "";
	me.edit_title = "";
	me.carset = [];
	me.map = [];
	mode = me.previous_mode;
	page = me.previous_page;
	left_knob(0); # force new display
    },
    start : func {
	var str = "";
	for (var i = 0; i < size(me.map); i += 1)
	    str ~= me.map[i] != "-" ? me.map[i] : "";
	if (screen[page_list[me.previous_mode][me.previous_page]].start(str)) me.escape();
    },
    lines : func {
	me.right(0); #init car
	me.edit_zone = "";
	for (var i=0; i < size(me.map); i+=1) me.edit_zone ~= me.map[i];
	display([
	me.edit_title,
	me.edit_zone,
	"",
	"ESC -> AVOID",
	sprintf("START -> %s", me.start_command)
	]);
    }
};
