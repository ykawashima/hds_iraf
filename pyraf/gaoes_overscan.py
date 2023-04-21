#!/usr/bin/env python
import sys
import os
from pyraf import iraf

iraf.gaoes()

num = 1

image in  sys.argv[1:]:
    iraf.set(stdimage="imt4096")
    basename = os.path.splitext(os.path.basename(image))[0]
    outname = basename +"o"
    iraf.gaoes_overscan(image, outname)

    num += 1
    
