 var m877 = {
    new : func(prop1){
        m = { parents : [m877]};
        m.MODE =0;
        m.digit_to_set=0;
        m.digit=[];
        m.set_mode=0;
        m.et_start_time=0;
        m.et_countdown=0;
        m.et_running=0;
        m.et_elapsed=0;
        m.ft_start_time=0;
        m.modetext =["GMT","LT","FT","ET"];
        m.M877 = props.globals.initNode(prop1);
        m.tenths=m.M877.initNode("tenths",0,"BOOL");
        m.ET_alarm=m.M877.initNode("et-alarm",0,"BOOL");
        m.FT_alarm=m.M877.initNode("ft-alert",0,"BOOL");
        m.FT_alarm_time=m.M877.initNode("ft-alarm-time",0,"BOOL");
        append(m.digit,m.M877.initNode("digit[0]",1,"BOOL"));
        append(m.digit,m.M877.initNode("digit[1]",1,"BOOL"));
        append(m.digit,m.M877.initNode("digit[2]",1,"BOOL"));
        append(m.digit,m.M877.initNode("digit[3]",1,"BOOL"));
        m.modestring=m.M877.initNode("mode-string",m.modetext[m.MODE],"STRING");
        m.power=m.M877.initNode("power",1,"BOOL");
        m.HR=m.M877.initNode("indicated-hour",0,"INT");
        m.MN=m.M877.initNode("indicated-min",0,"INT");
        m.ET_HR=m.M877.initNode("ET-hr",0,"INT");
        m.ET_MN=m.M877.initNode("ET-min",0,"INT");
        m.FT_HR=m.M877.initNode("FT-hr",0,"INT");
        m.FT_MN=m.M877.initNode("FT-min",0,"INT");
        return m;
    },
#### displayed mode  ####
    select_display : func(){
        if(me.set_mode==0){
            me.MODE +=1;
            if(me.MODE>3)me.MODE -=4;
            me.modestring.setValue(me.modetext[me.MODE]);
        }else{
            me.digit[me.digit_to_set].setValue(1);
            me.digit_to_set+=1;
            if(me.digit_to_set>3){
                me.digit_to_set=0;
                me.set_mode=0;
            }
        }
    },
#### set displayed mode  ####
    set_time : func(){
        me.set_mode=1-me.set_mode;
    },
#### CTL button action ####
    control_action : func(){
        if(me.set_mode==0){
            if(me.MODE==3){
                if(me.et_running==0){
                me.et_start_time=getprop("/sim/time/elapsed-sec");
                    me.et_running=1;
                }else{
                    me.et_start_time=getprop("/sim/time/elapsed-sec");
                    me.et_elapsed=0;
                    me.et_running=0;
                }
            }
        }else{
            if(me.MODE==0){
                me.set_gmt();
            }elsif(meMODE==1){
                me.set_lt();
            }elsif(meMODE==2){
                me.set_ft();
            }elsif(meMODE==3){
                me.set_et();
            }
        }
    },

#### set GMT  ####
    set_gmt : func(){
    
    },

#### set LT  ####
    set_lt : func(){
    
    },

#### set FT  ####
    set_ft : func(){
    
    },

#### set ET  ####
    set_et : func(){
    
    },

#### elapsed time  ####
    update_ET : func(){
        if(me.et_running!=0){
        me.et_elapsed=getprop("/sim/time/elapsed-sec") - me.et_start_time;
        }
        var ethour = me.et_elapsed/3600;
        var hr= int(ethour);
        var etmin=(ethour-hr) * 60;
        var min = int(etmin);
        var etsec= (etmin- min) *60;
        if(ethour <1){
            me.ET_HR.setValue(min);
            me.ET_MN.setValue(etsec);
        }else{
            me.ET_HR.setValue(hr);
            me.ET_MN.setValue(min);
        }
    },
#### update clock  ####
    update_clock : func{
        var pwr=me.power.getValue();
        if(me.set_mode==0){
            pwr=1-pwr;
        }else{
            pwr=1;
        }
        me.power.setValue(pwr);
        me.update_ET();
        var cm = me.MODE;
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
        if(me.set_mode==1){
            var flsh=me.digit[me.digit_to_set].getValue();
            flsh=1-flsh;
            me.digit[me.digit_to_set].setValue(flsh);
        }else{
            me.digit[me.digit_to_set].setValue(1);
        }
    },
};
#####################################

var davtron=m877.new("instrumentation/clock/m877");
var ETmeter = aircraft.timer.new("/instrumentation/clock/m877/ET-sec", 10);


setlistener("/sim/signals/fdm-initialized", func {
    settimer(update,2);
    print("Chronometer ... Check");
});

var update = func{
davtron.update_clock();
settimer(update,0.5);
}