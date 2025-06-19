analyze -format sverilog -vcs "-f ../rtl/filelist.f"
elaborate $top

check_design
