###### Primus 1000 system ########
var FDMODE = props.globals.getNode("/instrumentation/primus1000/fdmode",1);
var NavPtr1=props.globals.getNode("/instrumentation/primus1000/dc550/nav1ptr",1);
var NavPtr2=props.globals.getNode("/instrumentation/primus1000/dc550/nav2ptr",1);
var NavPtr1_offset=props.globals.getNode("/instrumentation/primus1000/dc550/nav1ptr-hdg-offset",1);
var NavPtr2_offset=props.globals.getNode("/instrumentation/primus1000/dc550/nav2ptr-hdg-offset",1);
var RAmode=props.globals.getNode("/instrumentation/primus1000/ra-mode",1);
var DC550 = props.globals.getNode("/instrumentation/primus1000/dc550",1);
var fms_enabled =0;

NavDist=props.globals.getNode("/instrumentation/primus1000/nav-dist-nm",1);
NavType=props.globals.getNode("/instrumentation/primus1000/nav-type",1);
NavString=props.globals.getNode("/instrumentation/primus1000/nav-string",1);
NavID=props.globals.getNode("/instrumentation/primus1000/nav-id",1);
FMSMode=props.globals.getNode("/instrumentation/primus1000/fms-mode",1);
APoff=props.globals.getNode("/autopilot/locks/passive-mode",1);
Hyd1=props.globals.getNode("systems/hydraulic/pump-psi[0]",1);
Hyd2=props.globals.getNode("systems/hydraulic/pump-psi[1]",1);
FuelPph1=props.globals.getNode("engines/engine[0]/fuel-flow_pph",1);
FuelPph2=props.globals.getNode("engines/engine[1]/fuel-flow_pph",1);
FuelDensity = 6.0;
FMS_VNAV =["VNV","FMS"];
NAV_SRC = ["VOR1","VOR2","ILS1","ILS2","FMS"];

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
            offset = props.globals.getNode("/instrumentation/adf/indicated-bearing-deg").getValue();
            }elsif(test == 3){
                offset = props.globals.getNode("/autopilot/internal/true-heading-error-deg").getValue();
                }
        return offset;
    }

update_pfd = func{
    NavPtr1_offset.setValue(get_pointer_offset(NavPtr1.getValue()));
    NavPtr2_offset.setValue(get_pointer_offset(NavPtr2.getValue()));
    var id = "   ";
    var nm_calc=0.0;
    if(fms_enabled ==0){
        if(props.globals.getNode("/instrumentation/nav/data-is-valid").getBoolValue()){
            nm_calc = getprop("/instrumentation/nav/nav-distance");
            if(nm_calc == nil){nm_calc = 0.0;}
            nm_calc = 0.000539 * nm_calc;
            if(getprop("/instrumentation/nav/has-gs")){NavType.setValue(2);}
            id = getprop("instrumentation/nav/nav-id");
            if(id ==nil){id= "   ";}
        }
    }else{
        nm_calc = getprop("/autopilot/route-manager/wp/dist");
        if(nm_calc == nil){nm_calc = 0.0;}
        id = getprop("autopilot/route-manager/wp/id");
        if(id ==nil){id= "   ";}
     }
    NavDist.setValue(nm_calc);
    var ns= NavType.getValue();
    setprop("/instrumentation/primus1000/nav-string",NAV_SRC[ns]);
    setprop("/instrumentation/primus1000/nav-id",id);
}



update_mfd = func{
}

update_fuel = func{
var total_fuel = 0;
if(getprop("/sim/flight-model")=="yasim"){
        FuelDensity=props.globals.getNode("consumables/fuel/tank[0]/density-ppg",1).getValue();
        var pph=getprop("/engines/engine[0]/fuel-flow-gph");
        if(pph == nil){pph = 0.0};
        FuelPph1.setValue(pph* FuelDensity);
        pph=getprop("/engines/engine[1]/fuel-flow-gph");
        if(pph == nil){pph = 0.0};
        FuelPph2.setValue(pph* FuelDensity);
        }else{
        total_fuel=props.globals.getNode("/fdm/jsbsim/propulsion/total-fuel-lbs").getValue();
        setprop("consumables/fuel/total-fuel-lbs",total_fuel);
    }
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
    update_fuel();
    }

setlistener("/instrumentation/primus1000/dc550/fms", func {
var mode = cmdarg().getValue();
    FMSMode.setValue(FMS_VNAV[mode]);
    if(mode){NavType.setValue(4);
        fms_enabled=1;
        }else{
        NavType.setValue(0);
        fms_enabled=0;
    }
});



update_p1000 = func {
    update_pfd();
    update_mfd();
    update_eicas();
    settimer(update_p1000,0);
    }

setlistener("/sim/signals/fdm-initialized", func {
    FDMODE.setBoolValue(1);
    NavPtr1.setDoubleValue(0.0);
    NavPtr2.setDoubleValue(0.0);
    NavPtr1_offset.setDoubleValue(0.0);
    NavPtr2_offset.setDoubleValue(0.0);
    DC550.getNode("hsi",1).setBoolValue(0);
    DC550.getNode("cp",1).setBoolValue(0);
    DC550.getNode("hpa",1).setBoolValue(0);
    DC550.getNode("ttg",1).setBoolValue(0);
    DC550.getNode("et",1).setBoolValue(0);
    DC550.getNode("fms",1).setBoolValue(0);
    FMSMode.setValue(" VNV");
    NavType.setIntValue(0);
    NavString.setValue("VOR1");
    RAmode.setValue(0.0);
    NavDist.setValue(0.0);
    Hyd1.setValue(0.0);
    Hyd2.setValue(0.0);
    FuelPph1.setValue(0.0);
    FuelPph2.setValue(0.0);
    APoff.setBoolValue(1);
    print("Primus 1000 systems ... check");
    settimer(update_p1000,1);
    });

