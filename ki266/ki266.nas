#########################################################################################
# $Id$
# this are the helper functions for the dme indicator ki266
# Maintainer: Torsten Dreyer (Torsten at t3r dot de)
#
# $Log$
# Revision 1.1  2008/11/03 16:18:06  torsten
# added ki266 3d-instrument, see ki266.xml for help
#
#
# Basically, we check the "time to station", "distance to station" and "speed"
# properties and generate the values to show on the displays, based on the switch-
# setting.
#
# Usage:
# just create one instance of ki266 class for each dme you have in your aircraft
# like this:
# ki266.new(0);

var ki266 = {};
ki266.new = func(idx) {
  var obj = {};
  obj.parents = [ki266];

  obj.rootNode = props.globals.getNode( "/instrumentation/dme[" ~ idx ~ "]", 1 );

  obj.powerNode = obj.rootNode.getNode( "power-btn" );
  if( obj.powerNode.getValue() == nil )
    obj.powerNode.setBoolValue( 1 );

  obj.distNode = obj.rootNode.getNode( "indicated-distance-nm", 1 );
  if( obj.distNode.getValue() == nil )
    obj.distNode.setDoubleValue( 0.0 );

  obj.timeNode = obj.rootNode.getNode( "indicated-time-min", 1 );
  if( obj.timeNode.getValue() == nil )
    obj.timeNode.setDoubleValue( 0.0 );

  obj.ktsNode = obj.rootNode.getNode( "indicated-ground-speed-kt", 1 );
  if( obj.ktsNode.getValue() == nil )
    obj.ktsNode.setDoubleValue( 0.0 );

  obj.minKtsNode = obj.rootNode.getNode( "switch-min-kts", 1 );
  if( obj.minKtsNode.getValue() == nil )
    obj.minKtsNode.setBoolValue( 1 );

  obj.minKtsDisplayNode = obj.rootNode.getNode( "min-kts-display", 1 );
  if( obj.minKtsDisplayNode.getValue() == nil )
    obj.minKtsDisplayNode.setDoubleValue(0);

  obj.milesDisplayNode = obj.rootNode.getNode( "miles-display", 1 );
  if( obj.milesDisplayNode.getValue() == nil )
    obj.milesDisplayNode.setDoubleValue(0);

  obj.leftDotNode = obj.rootNode.getNode( "left-dot", 1 );
  if( obj.leftDotNode.getValue() == nil )
    obj.leftDotNode.setBoolValue(0);

  aircraft.data.add( obj.powerNode, obj.minKtsNode );

  obj.update();

  print( "KI266 dme indicator #" ~ idx ~ " initialized" ); 
  return obj;
};

ki266.update = func {
  var v = 0.0;

  if( me.minKtsNode.getValue() ) {
    v = me.ktsNode.getValue();
  } else {
    v = me.timeNode.getValue();
  }
  if( v > 999.0 ) {
    v = 999.0;
  }
  if( v < 0.0 ) {
    v = 0.0;
  }
  me.minKtsDisplayNode.setIntValue( v );

  v = me.distNode.getValue();
  if( v > 999.9 ) {
    v = 999.9;
  }
  if( v < 0.0 ) {
    v = 0.0;
  }
  if( v < 100.0 ) {
    me.milesDisplayNode.setIntValue( v * 10.0 );
    me.leftDotNode.setBoolValue( 1 );
  } else {
    me.milesDisplayNode.setIntValue( v );
    me.leftDotNode.setBoolValue( 0 );
  }

  settimer( func { me.update() }, 0.2 );
}
