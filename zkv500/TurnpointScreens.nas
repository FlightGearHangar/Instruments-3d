var screenTurnpointSelect = {
    n: 0,
    page: 0,
    pointer: 0,
    loaded: 0,
    right : func {
	me.loaded = 0;
	blocked = 1;
	var t = browse(me.n, me.pointer, me.page, arg[0]);
	me.pointer = t[0];
	me.page = t[1];
    },
    enter : func {
    },
    escape : func {
    },
    start : func {
	me.n > 0 or return;
	gps_wp.getNode("wp/latitude-deg",1).setValue(gps_data.getNode("indicated-latitude-deg",1).getValue());
	gps_wp.getNode("wp/longitude-deg",1).setValue(gps_data.getNode("indicated-longitude-deg",1).getValue());
	gps_wp.getNode("wp/altitude-ft",1).setValue(gps_data.getNode("indicated-altitude-ft",1).getValue());
	gps_wp.getNode("wp/ID").setValue("startpos");

	var bookmark = gps_data.getNode("bookmarks/bookmark["~((me.page*5)+me.pointer)~"]/");
	gps_wp.getNode("wp[1]/latitude-deg",1).setValue(bookmark.getNode("latitude-deg",1).getValue());
	gps_wp.getNode("wp[1]/longitude-deg",1).setValue(bookmark.getNode("longitude-deg",1).getValue());
	gps_wp.getNode("wp[1]/altitude-ft",1).setValue(bookmark.getNode("altitude-ft",1).getValue());
	gps_wp.getNode("wp[1]/ID").setValue(bookmark.getNode("ID",1).getValue());
	blocked = 0;
	page = 1;
	mode = 3;
	left_knob(0);
    },
    lines : func {
	if (me.loaded != 1) blocked = 1;
	if (me.n > 0)
	    for (var l = 0; l < 5; l += 1) {
		if ((me.page * 5 + l) < me.n) {
		    name = gps_data.getNode("bookmarks/bookmark["~((me.page * 5) + l)~"]/ID").getValue();
		    line[l].setValue(sprintf("%s %s",me.pointer == l ? ">" : " ", name));
		}
		else
		    line[l].setValue("");
	    }
	else
	    display([
	    " ",
	    " ",
	    " NO BOOKMARKS",
	    " ",
	    " "
	    ]);
    }
};

var screenTurnpointInfos = {
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
