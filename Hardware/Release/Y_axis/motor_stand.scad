// Cyclone PCB Factory: a 3D printable CNC machine for PCB manufacture
// Created by Carlosgs (http://carlosgs.es)
// License: Attribution - Share Alike - Creative Commons (http://creativecommons.org/licenses/by-sa/3.0/)
// History:
//  - (05/25/2013) Added @yopero's four screw suggestion for the motor stand
//  - (05/28/2013) Added @yopero's four screw suggestion for the idle stand

use <../libs/obiscad/bcube.scad>
use <../libs/build_plate.scad>

motor_width = 43;
motor_length = 49; // not used
motor_screw_distance = 31.3;
motor_center_diameter = 23;

motor_screw_diameter = 3.7;
motor_screw_head_diameter = 8;

motor_adjust_margin = 3;

bearing_diameter = 22.4;
M8_rod_diameter = 8.2;

axis_distance = 32;

wall_thickness = 8;
wall_height = 45;
wall_width = 70;

idler_width = 25;



// For the supports with screws
bottom_thickness = 5;
base_width = 20;
base_length = 20+wall_thickness;
base_screw_diameter = 5;



wall_extraWidth_left = base_width+5;
wall_extraWidth_right = 5;

totalWallWidth = wall_width+wall_extraWidth_left+wall_extraWidth_right;


module motorHolesY() {
    // Hole for the motor shaft
    hull() {
      translate([0,motor_adjust_margin/2,0])
        cylinder(r=motor_center_diameter/2,h=10*wall_thickness,center=true,$fn=40);
      translate([0,-motor_adjust_margin/2,0])
        cylinder(r=motor_center_diameter/2,h=10*wall_thickness,center=true,$fn=40);
    }

    // Hole for the screwdriver
    translate([-wall_height/2,0,wall_thickness/2]) rotate([0,90,0]) bcube([2*(wall_thickness-5),5,wall_height],cr=1);

    // Screws for holding the motor
    for(i=[-1,1]) for(j=[-1,1])
    translate([i*motor_screw_distance/2,j*motor_screw_distance/2,2.5-wall_thickness/2]) {
      hull() {
        translate([0,motor_adjust_margin/2,0])
          cylinder(r=motor_screw_diameter/2,h=10*wall_thickness,center=true,$fn=40);
        translate([0,-motor_adjust_margin/2,0])
          cylinder(r=motor_screw_diameter/2,h=10*wall_thickness,center=true,$fn=40);
      }
      hull() {
        translate([0,motor_adjust_margin/2,0])
          cylinder(r=motor_screw_head_diameter/2,h=10*wall_thickness,center=false,$fn=40);
        translate([0,-motor_adjust_margin/2,0])
          cylinder(r=motor_screw_head_diameter/2,h=10*wall_thickness,center=false,$fn=40);
      }
    }
}

module motor_stand_no_base(with_motor=true) {
difference() {
  translate([wall_height/2,totalWallWidth/2-wall_extraWidth_left,wall_thickness/2])
    bcube([wall_height,totalWallWidth,wall_thickness],cr=4,cres=10);

  // Position relative to motor shaft
  translate([motor_width/2,motor_width/2,wall_thickness/2]) {

    if(with_motor)
      motorHolesY();

    // Bearing holes
    rotate([0,0,15]) translate([0,axis_distance,2.5-wall_thickness/2]) {
      cylinder(r=(M8_rod_diameter*2)/2,h=10*wall_thickness,center=true,$fn=40);
      cylinder(r=bearing_diameter/2,h=10*wall_thickness,center=false,$fn=60);

    }

  } // End of translate relative to motor shaft
} // End of difference
}

module holder(h=35,noScrews=false,base_width_inc=0) {
    difference() {
      union() {
        translate([wall_height-bottom_thickness,0]) {
          if(!noScrews) cube([bottom_thickness,base_width+base_width_inc,base_length]);
          hull() {
            cube([bottom_thickness,5,base_length]);
            translate([-h,0,0])
              cube([0.001,5,0.001]);
          }
        }
      }
      // --- screws for the base ---
      if(!noScrews) translate([wall_height,base_width/2+2.5,base_length/1.5])
        rotate([0,90,0]) {
          translate([-5,0,0])
            cylinder(r=base_screw_diameter/2,h=100,center=true,$fn=7);
          translate([5,0,0])
            cylinder(r=base_screw_diameter/2,h=100,center=true,$fn=7);
        }
    } // End of difference
}

module motor_stand(with_motor=true) {
  union() {
    motor_stand_no_base(with_motor);
    translate([0,wall_width]) holder(noScrews=true);
    translate([0,52.4-5/2]) holder(h=12,base_width_inc=1);
    translate([0,-wall_extraWidth_left+base_width]) scale([1,-1,1]) holder();
  }
}


module idle_stand() {
	union() {
		intersection() { // Remove the motor part
			motor_stand(with_motor=false);
			translate([wall_height/2,wall_width/2+52.4-(wall_width+wall_extraWidth_right-52.4),wall_thickness/2])
			bcube([wall_height,wall_width,100],cr=4,cres=10);
		}
		translate([0,wall_width+5-2*(wall_width+wall_extraWidth_right-52.4)]) holder(noScrews=true);
		translate([0,52.4+5/2]) scale([1,-1,1]) holder(h=15,base_width_inc=1);
	}
}

//for display only, doesn't contribute to final object
build_plate(3,200,200);

//motor_stand();
idle_stand();
