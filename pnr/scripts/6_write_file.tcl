# Create by lisp
set_verify_drc_mode \
-check_only special \
-limit 1000

verify_drc

ecoRoute -fix_drc

verify_drc

verifyConnectivity \
-noAntenna \
-type special \
-error 1000 \
-warning 50

# streamOut gds

# write_sdf -version 2.1 -precision 4 ./output/adder.sdf

saveNetlist -excludeLeafCell ./output/mhsa_acc_wrapper.v

saveDesign ./design/6_writefile.enc
