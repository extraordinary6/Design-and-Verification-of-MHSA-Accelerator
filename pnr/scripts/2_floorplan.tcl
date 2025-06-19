# Create by lisp
### second stage : floorplan(fp) & powerground(pg)

## 2.1 floorplan : contains die's area definition & macro placement  
# 2.1.1 floorplan -r {length/width  ratio     space*4    }. Usually, ratio is "0.7".
floorPlan -r  {1 0.7 100 100 100 100}

# 2.1.2 add dco & halo:
# addHaloBlock
addHaloToBlock {2 2 7.5 2} -allBlock
addRoutingHalo -bottom M1 -top M10 -space 1 -allBlock

#2.1.3 create PG Pin
set DieHeight [dbGet top.fPlan.box_sizey]
set DieLength [dbGet top.fPlan.box_sizex]
# VDD_box
set x1 [expr {$DieLength - 2.0000}]
set y1 [expr {$DieHeight * 0.33}]
set x2 $DieLength
set y2 [expr {$DieHeight * 0.33 + 4}]
set VDD_box [list $x1 [expr {int($y1)}] $x2 [expr {int($y2)}]]
createPGPin -geom M4 {*}$VDD_box -net VDD VDD
# VSS_box
set x1 [expr {$DieLength - 2.0000}]
set y1 [expr {$DieHeight * 0.66}]
set x2 $DieLength
set y2 [expr {$DieHeight * 0.66 + 4}]
set VSS_box [list $x1 [expr {int($y1)}] $x2 [expr {int($y2)}]]
createPGPin -geom M3 {*}$VSS_box -net VSS VSS

## 2.2 pg
# 2.2.1 core rings
addRing -nets {VDD VSS} -type core_rings -follow core \
-layer {top M5 bottom M5 left M6 right M6} \
-width {top 1.8 bottom 1.8 left 1.8 right 1.8} \
-spacing {top 1.8 bottom 1.8 left 1.8 right 1.8} \
-offset {top 1.8 bottom 1.8 left 1.8 right 1.8} 

# 2.2.3 gnc
globalNetConnect VDD -pin VDD -inst * -type pgpin -all
globalNetConnect VSS -pin VSS -inst * -type pgpin -all
globalNetConnect VDD -pin VDD -inst * -type pgpin -all
globalNetConnect VSS -pin VSS -inst * -type pgpin -all
globalNetConnect VDD -type tiehi -all
globalNetConnect VSS -type tielo -all

# 2.2.4 connect block pg & pad(io) pg
sroute -nets {VDD VSS} -connect {blockPin}
sroute -nets {VDD VSS} -connect {padPin} 

# 2.2.5 pg rail
sroute -nets {VDD VSS}

# 2.2.6 verify drc & lvs


saveDesign ./design/2_floorplan.enc
