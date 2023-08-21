/*
 * dash-cam mirror bracket
 * Replaces the suction cup on a ROVE R2-4K cam that eventually
 * fails from heat, even though it works relatively well for
 * a year or two.
 *
 * The clip for the mirror post is sized for the mirror in a 2020 Tundra
 */
preview=false;  // otherwise use print layout (separate parts)

mirrorPostDia=23;
mirrorClipWidth=25;
mirrorClipThickness=3;
mirrorClipBlockExtraHeight=9;
mirrorClipBlockWidth=mirrorPostDia+mirrorClipThickness*2;
mirrorClipBlockHeight=mirrorClipBlockWidth/2+mirrorClipBlockExtraHeight;

clampHingeBaseWidth=mirrorClipWidth;
clampHingeGapWidth=13;
clampHingeAxleHeight=22;
clampHingeAxleOuterDia=11;  // thumbscrew outer dia is 11.6
clampHingePlateThickness=3;
clampHingeAxleInnerDia=4;
//clampHingeNutInsetDia=8.75;
clampHingeSquareDia=5.2; // This is the diagonal, corner-to-corner

clampHingeDovetailDepth=clampHingePlateThickness;
clampHingeDovetailThickness=clampHingePlateThickness;
clampHingeSlotToleranceEnlargementFactor=1.2;

tieWrapWidth=6;
tieWrapThickness=3;


overlap=0.01;
$fn=50;

if (preview) {
    printPartClip();
    translate([0,mirrorClipBlockHeight-clampHingeDovetailDepth,clampHingeBaseWidth/2])
        mirror([1,0,0]) rotate([0,0,90])
            translate([0,clampHingeGapWidth/2,0]) // center gap on axis
                rotate([-90,0,0])  // turn sideways
        printPartAxlePlateLeft();
    translate([0,mirrorClipBlockHeight-clampHingeDovetailDepth,clampHingeBaseWidth/2])
        rotate([0,0,90])
            translate([0,clampHingeGapWidth/2,0]) // center gap on axis
                rotate([-90,0,0])  // turn sideways
                    printPartAxlePlateRight();
} else {
    spacing=5;
    printPartClip();
    translate([mirrorClipBlockWidth/2+clampHingeBaseWidth/2+spacing,-clampHingeAxleHeight/2,0]) rotate([0,0,90])
        printPartAxlePlateLeft();
    translate([-mirrorClipBlockWidth/2-clampHingeBaseWidth/2-spacing,-clampHingeAxleHeight/2,0]) rotate([0,0,90])
    printPartAxlePlateRight();

}

module printPartClip() {
    difference() {
        postClip(mirrorPostDia, mirrorClipWidth, mirrorClipThickness, mirrorClipBlockHeight, mirrorClipBlockWidth);
        // dovetail slot 1
        translate([clampHingeGapWidth/2,mirrorClipBlockHeight
                -(clampHingeDovetailDepth*clampHingeSlotToleranceEnlargementFactor)+overlap,
                clampHingeBaseWidth/2]) rotate([-90,0,0])
            clampHingeDovetail(clampHingePlateThickness, 
                clampHingeBaseWidth+2, 
                clampHingeDovetailThickness, 
                clampHingeDovetailDepth, clampHingeSlotToleranceEnlargementFactor, 0);
        // dovetail slot 2
        translate([-clampHingeGapWidth/2,mirrorClipBlockHeight
                -(clampHingeDovetailDepth*clampHingeSlotToleranceEnlargementFactor)+overlap,
                clampHingeBaseWidth/2]) mirror([1,0,0]) rotate([-90,0,0])
            clampHingeDovetail(clampHingePlateThickness, 
            clampHingeBaseWidth+2, 
            clampHingeDovetailThickness, 
            clampHingeDovetailDepth, clampHingeSlotToleranceEnlargementFactor, 0);
    }
}

module printPartAxlePlateRight() {
    clampHinge(clampHingeBaseWidth,clampHingeAxleHeight,
        clampHingeAxleOuterDia, clampHingePlateThickness,
        clampHingeAxleInnerDia, clampHingeSquareDia);
}

module printPartAxlePlateLeft() {
    clampHinge(clampHingeBaseWidth,clampHingeAxleHeight,
        clampHingeAxleOuterDia, clampHingePlateThickness,
        clampHingeAxleInnerDia, 0);
}

/*
 * This creates once side-plate for the hinge, If hingeSquareDia is not zero, the hole in the flange
 * will be cut square for the anti-rotation square-shaft portion of the axle bolt (just below the "head"),
 * carriage-bolt style.
 * Note: Design on ROVE is reversed from a fixed nut recess.  The thumbscrew has a nut embedded in it,
 * and the bolt/shaft does not rotate relative to the hinge.
 */
module clampHinge(baseWidth, axleHeight, axleOuterDia, plateThickness, 
        axleInnerDia, hingeSquareDia) {
    difference() {
        // screw (head with square insert) side
        union() {
            hull() {
                // axle (top) corner
                translate([axleHeight,0,0])
                    cylinder(d=axleOuterDia, h=plateThickness);
                translate([0,-baseWidth/2,0])
                    cube([overlap,overlap,plateThickness]);
                translate([0,baseWidth/2-overlap,0])
                    cube([overlap,overlap,plateThickness]);
            }
            // Dovetail insert 
            mirror([1,0,0]) rotate([0,-90,0])
                clampHingeDovetail(plateThickness, baseWidth, clampHingeDovetailThickness, clampHingeDovetailDepth, 1, 0.073);
        }
        // axle cut
        translate([axleHeight,0,-overlap])
            if (hingeSquareDia)
                cylinder(d=hingeSquareDia, h=plateThickness+overlap*3, $fn=4);
            else 
                cylinder(d=axleInnerDia, h=plateThickness+overlap*3);
    }
}

/**
 * Assembled centered along y-axis, in +x, +z quadrant
 * (overlaps thickness of the plate)
 */
module clampHingeDovetail(overlapThickness, baseWidth, rootThickness, edgeDepth, enlargementFactor=1, taperFactor) {
    translate([0,-baseWidth/2,0])
        hull() {
            // root/base (flat bottom side)
            cube([(overlapThickness+rootThickness)*enlargementFactor,baseWidth,overlap]);
            // Note: For now, this is narrowed so it won't protrude from the sides of the tapered plate
            // but this should probably be calculated instead of fixed.
            upperRootTrimAmount=baseWidth*taperFactor;
            // flat top side
            translate([0,upperRootTrimAmount/2,edgeDepth*enlargementFactor-overlap])
                cube([overlapThickness*enlargementFactor,baseWidth-upperRootTrimAmount,overlap]);
        }
}

module postClip(postDia, clipWidth, thickness, blockHeight, blockWidth) {
    
    echo("blockWidth calculated as: ", blockWidth);
    difference() {
        union() {
            cylinder(d=postDia+thickness*2, h=clipWidth);
            translate([-blockWidth/2,0,0])
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