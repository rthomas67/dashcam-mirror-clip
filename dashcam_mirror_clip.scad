// dash-cam mirror bracket
// Replaces the boneheaded suction cup that falls off the glass every
// time it gets a little warm.

// TODO: Set actual measurements

mirrorPostDia=24;
mirrorClipWidth=25;
mirrorClipThickness=3;
mirrorClipBlockHeight=9;

clampHingeBaseWidth=17;
clampHingeGapWidth=9;
clampHingeAxleHeight=12;
clampHingeAxleOuterDia=12;
clampHingeThicknessScrewSide=3;
clampHingeThicnessNutSide=3;
clampHingeAxleInnerDia=4.2;
clampHingeNutInsetDia=9;

screwSideFlangeThickness=3.5;
nutSideFlangeThickness=2;


// calculated
clampHingeOverallWidth=clampHingeGapWidth+clampHingeThicknessScrewSide+clampHingeThicnessNutSide;

overlap=0.01;
$fn=50;

union() {
    postClip(mirrorPostDia, mirrorClipWidth, mirrorClipThickness, mirrorClipBlockHeight);
    hingeCenterOffset=mirrorClipWidth/2-clampHingeOverallWidth/2;
    translate([0,mirrorPostDia/2+mirrorClipBlockHeight-overlap,hingeCenterOffset])
        rotate([0,0,90])
            clampHinge(clampHingeBaseWidth,clampHingeGapWidth,clampHingeAxleHeight,
                clampHingeAxleOuterDia,clampHingeThicknessScrewSide,
                clampHingeThicnessNutSide,clampHingeAxleInnerDia,
                screwSideFlangeThickness,nutSideFlangeThickness,
                clampHingeNutInsetDia);
}

// TODO: add Flange and nut inset
// Note: Taper flange for vertical printing w/o support (i.e. > 45 degrees)
module clampHinge(baseWidth, gapWidth, axleHeight, axleOuterDia, thicknessScrewSide, 
        thicknessNutSide, axleInnerDia,
        screwSideFlangeThickness, nutSideFlangeThickness,
        nutInsetDia) {
    hingeOverallWidth=gapWidth+thicknessScrewSide+thicknessNutSide;
    hingeOverallWidthWithFlanges=hingeOverallWidth+screwSideFlangeThickness
        +nutSideFlangeThickness;
    difference() {
        // screw side
        union() {
            hull() {
                // axle (top) corner
                translate([axleHeight,0,0])
                    cylinder(d=axleOuterDia, h=thicknessScrewSide);
                translate([0,-baseWidth/2,0])
                    cylinder(d=1, h=thicknessScrewSide, $fn=3);
                translate([0,baseWidth/2,0])
                    cylinder(d=1, h=thicknessScrewSide, $fn=3);
            }
            // Screw-side flange
            translate([axleHeight,0,-screwSideFlangeThickness+overlap])
                cylinder(d=axleOuterDia, h=screwSideFlangeThickness);
            // nut side
            translate([0,0,thicknessScrewSide+gapWidth])
                hull() {
                    // axle (top) corner
                    translate([axleHeight,0,0])
                        cylinder(d=axleOuterDia, h=thicknessNutSide);
                    translate([0,-baseWidth/2,0])
                        cylinder(d=1, h=thicknessNutSide, $fn=3);
                    translate([0,baseWidth/2,0])
                        cylinder(d=1, h=thicknessNutSide, $fn=3);
                }
                // Nut-side flange
                translate([axleHeight,0,hingeOverallWidth])
                    difference() {
                        cylinder(d1=axleOuterDia, d2=axleOuterDia*0.85, h=nutSideFlangeThickness);
                        translate([0,0,-overlap])
                            cylinder(d=nutInsetDia, h=nutSideFlangeThickness+overlap*2, $fn=6);
                    }
                
        }
        // axle cut
        translate([axleHeight,0,-screwSideFlangeThickness-overlap])
           cylinder(d=axleInnerDia,h=hingeOverallWidthWithFlanges+overlap*2);
    }
}


module postClip(postDia, clipWidth, thickness, blockHeight) {
    tieWrapWidth=6;
    tieWrapThickness=3;
    blockWidth=blockHeight*2;
    echo("blockWidth calculated as: ", blockWidth);
    difference() {
        union() {
            cylinder(d=postDia+thickness*2, h=clipWidth);
            translate([-blockWidth/2,postDia/2,0])
                cube([blockWidth, blockHeight, clipWidth]);
        }
        // center
        translate([0,0,-overlap])
            cylinder(d=postDia, h=clipWidth+overlap*2);
        // side opening
        translate([0,-postDia/2,-overlap])
            cylinder(d=postDia, h=clipWidth+overlap*2, $fn=6);
        // tie-wrap cut 1
        translate([0,0,clipWidth/5])
            difference() {
                cylinder(d=postDia+thickness*2+tieWrapThickness*2, h=tieWrapWidth);
                cylinder(d=postDia+thickness*2, h=tieWrapWidth);
            }
        // tie-wrap cut 2
        translate([0,0,clipWidth*3/5])
            difference() {
                cylinder(d=postDia+thickness*2+tieWrapThickness*2, h=tieWrapWidth);
                cylinder(d=postDia+thickness*2, h=tieWrapWidth);
            }
            
    }
}