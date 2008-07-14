var screenTaskSelect = {
    page : 0,
    pointer: 0,
    n: 0,
    loaded: 0,
    right : func {
	me.loaded = 0;
	blocked = 1;
	var t = browse(size(routes), me.pointer, me.page, arg[0]);
	me.pointer = t[0];
	me.page = t[1];
    },
    load : func {
        screenWaypointsList.n = 0;
	gps_data.getNode("route",1).removeChildren("Waypoint");
	fgcommand("loadxml", props.Node.new({
            "filename": getprop("/sim/fg-home") ~ "/Routes/" ~ routes[(me.page * 5) + me.pointer],
            "targetnode": "/instrumentation/gps/route"
        }));
	foreach (var c; gps_data.getNode("route").getChildren("Waypoint"))
	    screenWaypointsList.n += 1;
	gps_wp.getNode("wp/latitude-deg",1).setValue(gps_data.getNode("indicated-latitude-deg",1).getValue());
	gps_wp.getNode("wp/longitude-deg",1).setValue(gps_data.getNode("indicated-longitude-deg",1).getValue());
	gps_wp.getNode("wp/altitude-ft",1).setValue(gps_data.getNode("indicated-altitude-ft",1).getValue());
	gps_wp.getNode("wp/ID").setValue("startpos");

	gps_wp.getNode("wp[1]/latitude-deg",1).setValue(gps_data.getNode("route/Waypoint/latitude-deg",1).getValue());
	gps_wp.getNode("wp[1]/longitude-deg",1).setValue(gps_data.getNode("route/Waypoint/longitude-deg",1).getValue());
	gps_wp.getNode("wp[1]/altitude-ft",1).setValue(gps_data.getNode("route/Waypoint/altitude-ft",1).getValue());
	gps_wp.getNode("wp[1]/waypoint-type",1).setValue(gps_data.getNode("route/Waypoint/waypoint-type",1).getValue());
	gps_wp.getNode("wp[1]/ID",1).setValue(gps_data.getNode("route/Waypoint/ID",1).getValue());

	waypointindex = 0;
	me.loaded = 1;
    },
    enter : func {
    },
    escape : func {
    },
    start : func {
	me.n > 0 or return;
	me.load();
	blocked = 0;
	left_knob(1);
    },
    lines : func {
	if (me.loaded != 1) blocked = 1;
	if (me.n == 0) {
	    display([
	    "",
	    "",
	    "NO ROUTE FOUND",
	    "",
	    ""
	    ]);
	}
	else for (var l = 0; l < LINES; l += 1) {
	    if ((me.page * LINES + l) < me.n) {
		name = routes[me.page * LINES + l];
		if (substr(name, -4) == ".xml") name = substr(name, 0, size(name) - 4);
		name = string.uc(name);
		line[l].setValue(sprintf("%s %s",me.pointer == l ? ">" : " ", name));
	    }
	    else
		line[l].setValue("");
	}
    }
};

var screenWaypointsList = {
    n: 0,
    page: 0,
    pointer: 0,
    right : func {
	var t = browse(me.n, me.pointer, me.page, arg[0]);
	me.pointer = t[0];
	me.page = t[1];
    },
    enter : func {
    },
    escape : func {
    },
    start : func {
    },
    lines : func {
	for (var l = 0; l < LINES; l += 1) {
	   if ((me.page * LINES + l) < me.n) {
		name = gps_data.getNode("route/Waypoint["~((me.page * LINES) + l)~"]/ID").getValue();
		line[l].setValue(sprintf("%s %s",me.pointer == l ? ">" : " ", name));
	    }
	    else
		line[l].setValue("");
	}
    }
};

var screenWaypointInfos = {
    right : func {
    },
    enter : func {
    },
    escape : func {
    },
    start : func {
    },
    lines : func {
	display(NOT_YET_IMPLEMENTED);
    }
};



