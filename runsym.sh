#!/bin/bash
vcs -kdb -debug_access+all -f filelist.f -l vcs.log
./simv -gui