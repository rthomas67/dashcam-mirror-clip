// dash-cam mirror bracket
// Replaces the boneheaded suction cup that falls off the glass every
// time it gets a little warm.

// TODO: Set actual measurements

mirrorPostDia=23;
mirrorClipWidth=25;
mirrorClipThickness=3;
mirrorClipBlockHeight=9;

clampHingeBaseWidth=17;
clampHingeGapWidth=10.5;
clampHingeAxleHeight=12;
clampHingeAxleOuterDia=12;
clampHingeThicknessScrewSide=3;
clampHingeThicknessNutSide=3;
clampHingeAxleInnerDia=5;
clampHingeNutInsetDia=8.75;

screwSideFlangeThickness=3;
nutSideFlangeThickness=2.5;

wedgeAngle=45;
wedgeHeightLowSide=10;


// calculated
clampHingeOverallWidth=clampHingeGapWidth+clampHingeThicknessScrewSide+clampHingeThicknessNutSide;
mirrorClipBlockWidth=mirrorClipBlockHeight*2;

overlap=0.01;
$fn=50;

union() {
    postClip(mirrorPostDia, mirrorClipWidth, mirrorClipThickness, mirrorClipBlockHeight, mirrorClipBlockWidth);
    hingePositionOffset=screwSideFlangeThickness;  // Align with print bed
    translate([0,mirrorPostDia/2+mirrorClipBlockHeight-overlap,hingePositionOffset])
        rotate([0,0,90])
            clampHinge(clampHingeBaseWidth,clampHingeGapWidth,clampHingeAxleHeight,
                clampHingeAxleOuterDia,clampHingeThicknessScrewSide,
                clampHingeThicknessNutSide,clampHingeAxleInnerDia,
                screwSideFlangeThickness,nutSideFlangeThickness,
                clampHingeNutInsetDia);
   * wedge(mirrorClipWidth, mirrorClipBlockWidth, wedgeHeightLowSide, wedgeAngle);
}

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

// works like an equatorial wedge for a telescope
module wedge(blockLength, blockWidth, wedgeHeightLowSide, wedgeAngle) {
    difference() {
        cube([blockWidth,wedgeHeightLowSide*3,blockLength]);
   %     translate([-blockWidth,-wedgeHeightLowSide,0])
            rotate([wedgeAngle,0,-blockLength])
                cube([blockWidth*3,1,blockLength*3]);
    }
}


module postClip(postDia, clipWidth, thickness, blockHeight, blockWidth) {
    tieWrapWidth=6;
    tieWrapThickness=3;
    
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
        translate([0,-postDia*3/4,-overlap])
            cylinder(d=postDia*1.5, h=clipWidth+overlap*2, $fn=6);
        // tie-wrap cut 1
        translate([0,0,clipWidth/5]) 
            tieWrapCut(postDia, thickness, tieWrapThickness, tieWrapWidth);
        // tie-wrap cut 2
        translate([0,0,clipWidth*3/5])
            tieWrapCut(postDia, thickness, tieWrapThickness, tieWrapWidth);
    }
}

module tieWrapCut(postDia, thickness, tieWrapThickness, tieWrapWidth) {
    cutOuterDia=postDia+thickness*2+tieWrapThickness*2;
    difference() {
        cylinder(d=cutOuterDia, h=tieWrapWidth);
        translate([0,0,-overlap])
            cylinder(d=postDia+thickness*2, h=tieWrapWidth+overlap*2);
    }
    difference() {
        cylinder(d=postDia+thickness*2+tieWrapThickness*2, h=tieWrapWidth);
        translate([-cutOuterDia/2-overlap,tieWrapThickness,-overlap])
            cube([cutOuterDia+overlap*2,cutOuterDia,tieWrapWidth+overlap*2]);
        translate([0,tieWrapThickness,-overlap])
            cylinder(d=postDia+thickness*2, h=tieWrapWidth+overlap*2);
    }
}