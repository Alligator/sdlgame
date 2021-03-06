<?xml version="1.0" encoding="UTF-8"?>
<tileset name="plat" tilewidth="8" tileheight="8" tilecount="512" columns="16">
 <image source="plat.gif" width="128" height="256"/>
 <tile id="4">
  <properties>
   <property name="platform" type="bool" value="true"/>
  </properties>
 </tile>
 <tile id="5">
  <properties>
   <property name="platform" type="bool" value="true"/>
  </properties>
 </tile>
 <tile id="6">
  <properties>
   <property name="platform" type="bool" value="true"/>
  </properties>
 </tile>
 <tile id="7" type="Flamethrower">
  <properties>
   <property name="direction" value="up"/>
  </properties>
 </tile>
 <tile id="8" type="Flamethrower">
  <properties>
   <property name="direction" value="right"/>
  </properties>
 </tile>
 <tile id="9" type="Flamethrower">
  <properties>
   <property name="direction" value="down"/>
  </properties>
 </tile>
 <tile id="10" type="Flamethrower">
  <properties>
   <property name="direction" value="left"/>
  </properties>
 </tile>
 <tile id="11" type="Flamethrower">
  <properties>
   <property name="altCycle" type="bool" value="true"/>
   <property name="direction" value="up"/>
  </properties>
 </tile>
 <tile id="12" type="Flamethrower">
  <properties>
   <property name="altCycle" type="bool" value="true"/>
   <property name="direction" value="right"/>
  </properties>
 </tile>
 <tile id="13" type="Flamethrower">
  <properties>
   <property name="altCycle" type="bool" value="true"/>
   <property name="direction" value="down"/>
  </properties>
 </tile>
 <tile id="14" type="Flamethrower">
  <properties>
   <property name="altCycle" type="bool" value="true"/>
   <property name="direction" value="left"/>
  </properties>
 </tile>
 <tile id="224" type="Delay">
  <properties>
   <property name="delay" type="int" value="0"/>
   <property name="target" value=""/>
  </properties>
 </tile>
 <tile id="225" type="Loop">
  <properties>
   <property name="frequency" type="int" value="0"/>
   <property name="startActive" type="bool" value="true"/>
   <property name="target" value=""/>
  </properties>
 </tile>
 <tile id="226" type="Counter">
  <properties>
   <property name="count" type="int" value="0"/>
   <property name="target" value=""/>
  </properties>
 </tile>
 <tile id="238" type="Cannon">
  <properties>
   <property name="direction" value="up"/>
  </properties>
 </tile>
 <tile id="239" type="Cannon">
  <properties>
   <property name="direction" value="right"/>
  </properties>
 </tile>
 <tile id="240" type="Cannon">
  <properties>
   <property name="direction" value="down"/>
  </properties>
 </tile>
 <tile id="241" type="Cannon">
  <properties>
   <property name="direction" value="left"/>
  </properties>
 </tile>
 <tile id="242" type="Spike">
  <properties>
   <property name="startVisible" type="bool" value="true"/>
  </properties>
 </tile>
 <tile id="243" type="Spring"/>
 <tile id="244" type="FallingPlatform"/>
 <tile id="245" type="MovingPlatform">
  <properties>
   <property name="path" value=""/>
   <property name="startActive" type="bool" value="true"/>
  </properties>
 </tile>
 <tile id="246" type="Walker">
  <properties>
   <property name="flip" type="bool" value="false"/>
  </properties>
 </tile>
 <tile id="247" type="Snail">
  <properties>
   <property name="flip" type="bool" value="false"/>
  </properties>
 </tile>
 <tile id="248" type="Switch">
  <properties>
   <property name="target" value=""/>
  </properties>
 </tile>
 <tile id="249" type="Gate">
  <properties>
   <property name="startVisible" type="bool" value="true"/>
  </properties>
 </tile>
 <tile id="253" type="Coin"/>
 <tile id="254" type="LevelExit"/>
 <tile id="255" type="Player"/>
</tileset>
