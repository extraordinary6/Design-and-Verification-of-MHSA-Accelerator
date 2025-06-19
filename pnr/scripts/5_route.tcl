# Create by lisp
### fifth stage : route
## 5.1 route
setNanoRouteMode -routeTopRoutingLayer 6
routeDesign -globalDetail

## 5.2 check timing
reset_parasitics

extractRC

setAnalysisMode -analysisType onChipVariation

timeDesign -postRoute
timeDesign -postRoute -hold

## 5.3 timing opt
#setOptMode -setupTargetSlack 0.05 -holdTargetSlack 0.10
# optDesign -postRoute -setup -hold

saveDesign ./design/5a_routebeforeopt.enc
