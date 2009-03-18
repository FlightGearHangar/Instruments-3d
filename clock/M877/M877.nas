var m877 = {
    new : func(prop1){
        m = { parents : [m877]};
        m.MODE =0;
        m.modetext =["GMT","LT","FT","ET"];
        m.M877 = props.globals.getNode(prop1,1);
        m.set_hour=m.M877.getNode("set-hour",1);
        m.set_hour.setBoolValue(0);
        m.set_min=m.M877.getNode("set-min",1);
        m.set_min.setBoolValue(0);
        m.mode=m.M877.getNode("mode",1);
        m.mode.setIntValue(m.MODE);
        m.tenths=m.M877.getNode("display-tenths",1);
        m.tenths.setBoolValue(0);
        m.modestring=m.M877.getNode("mode-string",1);
        m.modestring.setValue(m.modetext[m.MODE]);
        m.HR=m.M877.getNode("indicated-hour",1);
        m.HR.setIntValue(0);
        m.MN=m.M877.getNode("indicated-min",1);
        m.MN.setIntValue(0);
        m.ET_HR=m.M877.getNode("ET-hr",1);
        m.ET_HR.setIntValue(0);
        m.ET_MN=m.M877.getNode("ET-min",1);
        m.ET_MN.setIntValue(0);
        m.ET_string=m.M877.getNode("ET-string",1);
        m.ET_string.setValue("00:00");
        return m;
    },
#### next mode  ####
    set_clock : func(){
        var cmode = me.mode.getValue();
        cmode +=1;
        if(cmode>3)cmode -=4;
        me.mode.setValue(cmode);
    },
#### elapsed time  ####
    update_ET : func(){
        var fmeter = getprop("/instrumentation/clock/m877/ET-sec");
        var fhour = fmeter/3600;
        var inthour =int(fhour);
        me.ET_HR.setValue(inthour);
        var fmin = (fhour - inthour);
        if(me.tenths.getBoolValue()){
            fmin *=100;
        }else{
            fmin *=60;
        }
        me.ET_MN.setValue(fmin);
        var str = sprintf("%02.0f:%02.0f",inthour,fmin);
        me.ET_string.setValue(str);
    },
#### update clock  ####
    update_clock : func{
        me.update_ET();
        var cm = me.mode.getValue();
        if(cm ==0){
            me.HR.setValue(getprop("/instrumentation/clock/indicated-hour"));
            me.MN.setValue(getprop("/instrumentation/clock/indicated-min"));
        }elsif(cm == 1) {
            me.HR.setValue(getprop("/instrumentation/clock/local-hour"));
            me.MN.setValue(getprop("/instrumentation/clock/indicated-min"));
        }elsif(cm == 2) {
            var FTH = getprop("instrumentation/clock/flight-meter-sec");
            if(FTH != nil){
                me.HR.setValue(getprop("instrumentation/clock/flight-meter-hour"));
                me.MN.setValue(getprop("instrumentation/clock/flight-meter-min"));
            }
        }elsif(cm == 3) {
            var ETH = me.ET_HR.getValue();
            if(ETH != nil){
                me.HR.setValue(me.ET_HR.getValue());
                me.MN.setValue(me.ET_MN.getValue());
            }
        }
    },
};


var davtron=m877.new("instrumentation/clock/m877");
var ETmeter = aircraft.timer.new("/instrumentation/clock/m877/ET-sec", 10);

##################################

setlistener("/sim/signals/fdm-initialized", func {
    ETmeter.reset();
    settimer(update,2);
    print("Chronometer ... Check");
});

setlistener("/gear/gear[1]/wow", func(gr){
    if(gr.getBoolValue()){
        ETmeter.stop();
    }else{
        ETmeter.start();
    }
},0,0);

var update = func{
davtron.update_clock();
settimer(update,1);
}