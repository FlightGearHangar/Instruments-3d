###### Primus 1000 system ########
FDMODE = props.globals.getNode("/instrumentation/primus1000/fdmode",1);
NavPtr1=props.globals.getNode("/instrumentation/primus1000/nav1pointer",1);
NavPtr2=props.globals.getNode("/instrumentation/primus1000/nav2pointer",1);
NavPtr1_offset=props.globals.getNode("/instrumentation/primus1000/nav1pointer-heading-offset",1);
NavPtr2_offset=props.globals.getNode("/instrumentation/primus1000/nav2pointer-heading-offset",1);
RAmode=props.globals.getNode("/instrumentation/primus1000/ra-mode",1); 
NavDist=props.globals.getNode("/instrumentation/primus1000/nav-dist-nm",1);
APoff=props.globals.getNode("/autopilot/locks/passive-mode",1);
Hyd1=props.globals.getNode("systems/hydraulic/pump-psi[0]",1);
Hyd2=props.globals.getNode("systems/hydraulic/pump-psi[1]",1);
FuelPph1=props.globals.getNode("engines/engine[0]/fuel-flow-pph",1);
FuelPph2=props.globals.getNode("engines/engine[1]/fuel-flow-pph",1);
FuelDensity = 6.0;

get_pointer_offset = func{
	var test=arg[0];
	var offset = 0;
	var hdg = getprop("/orientation/heading-magnetic-deg");
	if(test==0 or test == nil){return 0.0;}
	
	if(test == 1){
		offset=getprop("/instrumentation/nav/heading-deg");
		offset -= hdg;
		if(offset < -180){offset += 360;}
		elsif(offset > 180){offset -= 360;}
		}elsif(test == 2){
			offset = getprop("/instrumentation/adf/indicated-bearing-deg");
			}elsif(test == 3){
				offset = getprop("/autopilot/internal/true-heading-error-deg");
				}
		return offset;		
	}

update_pfd = func{
	NavPtr1_offset.setValue(get_pointer_offset(NavPtr1.getValue()));
	NavPtr2_offset.setValue(get_pointer_offset(NavPtr2.getValue()));

	if(getprop("/instrumentation/nav/data-is-valid")=="true"){
		nm_calc = getprop("/instrumentation/nav/nav-distance");
		if(nm_calc == nil){nm_calc = 0.0;}
		nm_calc = 0.000539 * nm_calc;
		NavDist.setValue(nm_calc);
	}
}

update_mfd = func{
}

update_eicas = func{
	var hpsi = getprop("/engines/engine[0]/n2");
	if(hpsi == nil){hpsi=0.0;}
	hpsi = hpsi * 100;
	if(hpsi > 3000){hpsi=3000;}
	Hyd1.setValue(hpsi);
	hpsi = getprop("/engines/engine[1]/n2");
	if(hpsi == nil){hpsi=0.0;}
	hpsi = hpsi * 100;
	if(hpsi > 3000){hpsi=3000;}
	Hyd2.setValue(hpsi);

	var pph=getprop("/engines/engine[0]/fuel-flow-gph");
	if(pph == nil){pph = 0.0};
	FuelPph1.setValue(pph* FuelDensity);
	pph=getprop("/engines/engine[1]/fuel-flow-gph");
	if(pph == nil){pph = 0.0};
	FuelPph2.setValue(pph* FuelDensity);

}


update_p1000 = func {
	update_pfd();
	update_mfd();
	update_eicas();
	settimer(update_p1000,0);
	}

settimer(update_p1000,0);

setlistener("/sim/signals/fdm-initialized", func {
	setprop("/instrumentation/gps/wp/wp/waypoint-type","airport");
	setprop("/instrumentation/gps/wp/wp/ID",getprop("/sim/tower/airport-id"));
	setprop("/instrumentation/gps/serviceable","true");
	FDMODE.setBoolValue(1);
	NavPtr1.setValue(0.0);
	NavPtr2.setValue(0.0);
	NavPtr1_offset.setValue(0.0);
	NavPtr2_offset.setValue(0.0);
	RAmode.setValue(0.0);
	NavDist.setValue(0.0);
	Hyd1.setValue(0.0);
	Hyd2.setValue(0.0);
	FuelPph1.setValue(0.0);
	FuelPph2.setValue(0.0);
	APoff.setBoolValue(1);
	FuelDensity=props.globals.getNode("consumables/fuel/tank[0]/density-ppg",1).getValue();
	print("Primus 1000 systems OK");
	});

