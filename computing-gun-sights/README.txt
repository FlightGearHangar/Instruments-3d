To enable full functionality of the K14 gun sight there are several things 
that need to be done.  

First change the <nasal> section of your *set.xml file so that it looks like the 
following.  

<nasal>
   <!-- your other nasal files -->
   <!-- the following three lines must be exactly like this -->
   <K14>
      <file>Aircraft/Instruments-3d/computing-gun-sights/Nasal/lead-computer.nas</file>
   </K14>
</nasal>

Animation:

For dark conditions when cabin/cockpit illumination is used all of the K14 sight 
is illuminated in response to 

<property>/controls/lighting/cabin-norm</property>

If you are using a different property for your cabin/cockpit lights you will need to map your 
lighting property to /controls/lighting/cabin-norm.

Aircraft Specific Properties:

The following properties will need to be set to configure the site for an aircraft.

The following five values can be found in the submodels.xnl configuration file.

/controls/armament/gunsight/z-gunOffsetFeet = Gun position on z axis relative to the sight line in feet.  
                                              Will = <z-offset>offset value</z-offset> + distance from 
								  	          aircraft center line to sight line height.
/controls/armament/gunsight/y-gunOffsetFeet = Gun position on y axis relative to the sight line in feet.
                                              Will = <y-offset>abs value</y-offset> 
/controls/armament/gunsight/gunElevationDegrees = <pitch-offset>gun pitch setting</pitch-offset>
/controls/armament/gunsight/ballisticCoefficienct = <eda>xxxxx</eda>
/controls/armament/gunsight/muzzleVelocity = <speed>xxxxx</speed> = In feet per second

/controls/armament/gunsight/gunHarminizationRangeFeet = Range where the sight and the bullet 
                                                        path cross is level flight in feet.
														
Below is an example from the P-51D using the K14A sight which needs some additional
settings to control power and lighting for the sight.

<controls>
   <armament>
     <gunsight>
        <power-on type="int">0</power-on>
        <intensity type="float">1.0</intensity>
		<z-offsetFeet type="float">-4.0</z-offsetFeet>
        <y-offsetFeet type="float">0.0</y-offsetFeet>
        <scale type="float">0.6</scale>
        <gunElevationDegrees type="float">3.8</gunElevationDegrees>
        <ballisticCoefficienct type="float">0.00136354</ballisticCoefficienct>
        <muzzleVelocity type="float">2900.0</muzzleVelocity>
        <gunHarminizationRangeFeet type="float">900.0</gunHarminizationRangeFeet>
		<range type="float">900.0</range>  <!-- startup default -->
     </gunsight>
   </armament>
   ...
</controls>

 