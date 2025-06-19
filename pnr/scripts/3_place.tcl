# Create by lisp
### third stage : place (std cell)

setNanoRouteMode -routeTopRoutingLayer 6

## 3.2 place std cell & timing opt
place_design

# setOptMode-setupTargetSlack 0.01 -holdTargetSlack 0.01
optDesign -preCTS 

extractRC


## 3.3 after welltap & TIE cell, gnc again
globalNetConnect VDD -pin VDD -inst * -type pgpin -all
globalNetConnect VSS -pin VSS -inst * -type pgpin -all
globalNetConnect VDD -pin VDD -inst * -type pgpin -all
globalNetConnect VSS -pin VSS -inst * -type pgpin -all
globalNetConnect VDD -type tiehi -all
globalNetConnect VSS -type tielo -all

saveDesign ./design/3_place.enc

