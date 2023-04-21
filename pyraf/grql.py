#!/usr/bin/env python
import sys
import os
from pyraf import iraf


if len(sys.argv) != 9:
  print(" [usage] python3 grql.py inid indirec ref_ap flatimg thar1d thar2d st_x ed_x")
  print("    inid    :  8 digit frame number")
  print("    indirec :  directory of RAW data")
  print("    ref_ap  :  Aperture reference image")
  print("    flatimg :  ApNormalized flat image")
  print("    thar1d  :  1D wavelength calibrated ThAr image")
  print("    thar2d  :  2D ThAr image")
  print("    st_x    :  Start pixel number to extract (-54 in usual)")
  print("    ed_x    :  Ebd pixel number to extract (53 in usual)")
  sys.exit()

  
inid    = sys.argv[1]
indirec = sys.argv[2]
ref_ap  = sys.argv[3]
flatimg = sys.argv[4]
thar1d  = sys.argv[5]
thar2d  = sys.argv[6]
st_x    = sys.argv[7]
ed_x    = sys.argv[8]

iraf.gaoes()

#inid = sys.argv[1]
iraf.set(stdimage="imt4096")
iraf.grql(inid=inid, indirec=indirec, batch="no", interactive="no", ref_ap=ref_ap, flatimg=flatimg, thar1d=thar1d, thar2d=thar2d, st_x=st_x, ed_x=ed_x, cosmicr="yes", scatter="yes", ecfw="yes", splot="yes", cr_proc="wacosm", cr_wbas=2000., sc_inte="no")

    
