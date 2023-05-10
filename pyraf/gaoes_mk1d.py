#!/usr/bin/env python
import sys
import os
from pyraf import iraf


if len(sys.argv) != 7:
  print(" [usage] python3 gaoes_mk1d.py inec out1d blaze mask st_x ed_x")
  print("    inec    :  Input Multi-order spectrum")
  print("    out1d   :  Output 1D spectrum")
  print("    blaze   :  Blaze function")
  print("    mask    :  Mask image")
  print("    st_x    :  Start pixel for trimming")
  print("    ed_x    :  End pixel for trimming")
  sys.exit()

  
inec    = sys.argv[1]
out1d   = sys.argv[2]
blaze   = sys.argv[3]
mask    = sys.argv[4]
st_x    = sys.argv[5]
ed_x    = sys.argv[6]

iraf.gaoes()

#inid = sys.argv[1]
iraf.set(stdimage="imt4096")
iraf.gaoes_mk1d(inec=inec, out1d=out1d, blaze=blaze, mask=mask, st_x=st_x, ed_x=ed_x)

    
