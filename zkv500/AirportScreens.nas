var screenAirportMain = {
    pos: nil,
    apt_coord: nil,
    apt: nil,
    searched: 0,
    right : func {
    },
    apt_to_waypoint : func {
	gps_wp.getNode("wp/longitude-deg",1).setValue(me.pos.lat());
	gps_wp.getNode("wp/latitude-deg",1).setValue(me.pos.lon());
	gps_wp.getNode("wp/altitude-ft",1).setValue(me.pos.alt()*alt_conv[1][0]);
	gps_wp.getNode("wp/ID",1).setValue("STARTPOS");
	gps_wp.getNode("wp/name",1).setValue("start position");
 
	gps_wp.getNode("wp[1]/longitude-deg",1).setValue(me.apt_coord.lat());
	gps_wp.getNode("wp[1]/latitude-deg",1).setValue(me.apt_coord.lon());
	gps_wp.getNode("wp[1]/altitude-ft",1).setValue(me.apt_coord.alt()*alt_conv[1][0]);
	gps_wp.getNode("wp[1]/ID",1).setValue(me.apt.id);
	gps_wp.getNode("wp[1]/name",1).setValue(me.apt.name);
	mode = 2;
	page = 1;
	displayed_screen = 1; #screenNavigationMain
    },
    enter : func { #add to route
	add_waypoint(me.apt.id, me.apt.name, "APT", 
		    [me.apt_coord.lat(), me.apt_coord.lon(), 
		    me.apt_coord.alt()*alt_conv[1][0]]);
    },
    escape : func {
    },
    start : func { #add bookmark, enter turnpoint mode
	add_bookmark(me.apt.id, me.apt.name, "APT", 
		    [me.apt_coord.lat(), me.apt_coord.lon(), 
		    me.apt_coord.alt()*alt_conv[1][0]]);
	screenTurnpointSelect.selected = screenTurnpointSelect.n - 1;
	screenTurnpointSelect.start();
    },
    lines : func {
	if (me.apt == nil) {
	    me.apt = airportinfo();
	    print("youpi ", me.count);
	    me.searched = 0;
	}
	if (me.apt != nil) {
	    glide_slope_tunnel.complement_runways(me.apt);
	    var rwy = glide_slope_tunnel.best_runway(me.apt);
	    me.pos = geo.Coord.new(geo.aircraft_position());
	    me.apt_coord = geo.Coord.new().set_latlon(rwy.lat, rwy.lon);
	    var ac_to_apt = [me.pos.distance_to(me.apt_coord), me.pos.course_to(me.apt_coord)];
	    var ete = ac_to_apt[0] / getprop("instrumentation/gps/indicated-ground-speed-kt") * 3600 * 1852;
	    print ("me.searched: ",me.searched);
	    display([
	    sprintf("%s APT: %s", me.searched != nil ? "SEARCHED" : "NEAREST", me.apt.id),
	    sprintf("ELEV: %d %s", me.apt.elevation * alt_conv[1][alt_unit],alt_unit_short_name[alt_unit]),
	    sprintf("DIST: %d %s",ac_to_apt[0] * dist_conv[2][dist_unit],dist_unit_short_name[dist_unit]),
	    sprintf("BRG: %d°    RWY: %02d",ac_to_apt[1], int(rwy.heading) / 10),
	    sprintf("ETE: %s",seconds_to_string(ete))
	    ]);
	}
	else
	    display([
	    "",
	    "",
	    "NO AIRPORT FOUND",
	    "",
	    ""
	    ]);
    }
};

var screenAirportInfos = {
    page : 0,
    rwylist: [],
    right : func {
	me.page = 0;
	displayed_screen = 4;# screenAirportMain
    },
    left : func {
	np = int(size(me.rwylist) / 4) + (math.mod(size(me.rwylist),4) ? 1 : 0);
	me.page = cycle(np, me.page, arg[0]);
    },
    enter : func {
    },
    escape : func {
    },
    start : func {
    },
    lines : func {
	me.rwylist = [];
	foreach (var r; keys(apt.runways))
	    append(me.rwylist, [r, apt.runways[r].length, apt.runways[r].width]);
	line[0].setValue(sprintf("%s", apt.name)); #TODO check length to truncate if too long
	rwyindex = me.page * 4;
	for (var l = 1; l < 5; l += 1) {
	    rwyindex += 1;
	    if (rwyindex < size(me.rwylist))
		line[l].setValue(sprintf("R:%s L:%dm W:%dm", 
					me.rwylist[rwyindex][0],
					me.rwylist[rwyindex][1], 
					me.rwylist[rwyindex][2]));
	    else
		line[l].setValue("");
	}
    }
};

var screenSearchAirport = {
    right : func {
    },
    enter : func {
    },
    escape : func {
    },
    start : func {
	var searched = airportinfo(arg[0]);
	if (searched != nil) {
	    screenAirportMain.apt = searched;
	    screenAirportMain.searched = 1;
	    return 1;
	}
	else
	    return 0;
    },
    lines : func {
	EditMode(4, "AIRPORT CODE", "SEARCH");
    }
};


