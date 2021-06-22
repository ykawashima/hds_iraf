procedure hdsql(inid)
### Input parameters
 string inid {prompt = 'Input frame ID'}
 string indirec {prompt = 'directory of Input data\n'}

 bool   overscan {prompt = 'Overscan?'}
 bool   cosmicra {prompt = 'Cosmicray-event rejection?'}
 bool   scatter {prompt = 'Scattered light subtraction?'}
 bool   flat {prompt = 'Flat fielding?'}
 bool   apall {prompt = 'Extract spectra with apall?'}
 bool   wavecal  {prompt = 'Wavelength calibration?\n'}

# string output {prompt = 'output frame name (ID)'}
# os_out {prompt = 'Output frame of overscan'}
# string cr_out  {prompt = 'Output frame of wacosm1'}
# string sc_out  {prompt = 'Output of scattered light subtracted data'}
# string fl_out  {prompt = 'Output of flat fielded data'}
# string ap_out   {prompt = 'Output frame apalled'}
# string wv_out   {prompt = 'Output frame of wavelength-calibrated data'}

# Parameters for overscan
 bool   os_save {prompt = 'Save overscaned data?\n'}

# Parameters for cosmicray-event rejection
 string cr_in {prompt = 'Input frame for wacosm1 (if necessary)'}
 bool   cr_save {prompt = 'Save cosmicray processed data?'}
 real   cr_base  {prompt = 'Baseline for wacosm1\n'}
# real   cr_lower  {prompt = 'Lower limit of replacement window'}

# scattered light subtraction
 string sc_in {prompt = 'Input frame for scattered light subtraction (if necessary)'}
 string sc_refer {prompt = 'Reference for aperture finding'}
 bool   sc_save {prompt = 'Save scattered light subtracted data?'}
 bool   sc_inter {prompt = 'Run apscatter interactively?'}
 bool   sc_recen {prompt = 'Recenter apertures for apscatter?'}
 bool   sc_resiz {prompt = 'Resize apertures for apscatter?'}
 bool   sc_edit  {prompt = 'Edit apertures for apscatter?'}
 bool   sc_trace {prompt = 'Trace apertures for apscatter?'}
 bool   sc_fittr {prompt = 'Fit the traced points interactively for apscatter?\n'}

# Flat fielding
 string fl_in {prompt = 'Input frame for flat fielding (if necessary)'}
 string fl_refer {prompt = 'Flat frame'}
 bool   fl_save {prompt = 'Save flat-fielded data?\n'}

# Parameters for apall
 bool   ap_save {prompt = 'Save apalled data?'}
 string   ap_in {prompt = 'Input frame for apall (if necessary)?'}
 string ap_refer {prompt = 'Reference frame for apall'}
 bool   ap_inter {prompt = 'Run apall interactively?'}
 bool   ap_recen {prompt = 'Recenter apertures?'}
 bool   ap_resiz {prompt = 'Resize apertures?'}
 bool   ap_edit  {prompt = 'Edit apertures?'}
 bool   ap_trace {prompt = 'Trace apertures?'}
 bool   ap_fittr {prompt = 'Fit the traced points interactively?'}
 real   ap_llimi {prompt = 'Lower aperture limit relative to center'}
 real   ap_ulimi {prompt = 'Upper aperture limit relative to center'}
 real   ap_yleve {prompt = 'Fraction of peak for automatic width determination?'} 
 bool   ap_peak  {prompt = 'Is ylevel a fraction of the peak?\n'}

# Parameters for wavelength calibration
 bool   wv_save  {prompt = 'Save wavelength-calibrated data?'}
 string wv_in    {prompt = 'Input frame for wavelength calibration (if necessary)'}
 string wv_refer {prompt = 'Reference frame for refspectra\n'}

# string ext_f {prompt = 'Frame extraccted'}
# string thar_f {prompt = 'Reference Frame for Wavelength Calibration'}

begin
string input,output
string flag
string osfile
string crinfile,crfile
string flinfile,flfile
string scinfile,scfile
string apinfile,apfile
string wvinfile,wvfile

#   base_med = "tmp_med.imh"
#cosmf = "tmp_cosm.fits"
#scatf = "tmp_scat.fits"

flag="o"

#imgets(image=input, param="FRAMEID")
#output  = (imgets.value)
 output  = ("H"+inid)
# output  = inid
 print("output ID" + output)

 input=(indirec+inid+".fits[0]")
# input=(inid+".fits")
 print("input data= "+input)

# overscan
if (overscan ==yes){
   flag="o"
   if (os_save ==yes){
#      osfile=os_out
      osfile=(output+flag)
   } else
      osfile="tmp_os"
   print("output overscaned data= "+osfile)
   print("# Overscan is now processing...")
   overscan(inimage=input,outimage=osfile)
} else
   print("overscan not processing")

# wacosm11
if (cosmicra ==yes){
   flag=flag+"c"	
   if (overscan==no){
#      crinfile=cr_in
      crinfile=inid
   }else
      crinfile=osfile
#
   if (cr_save ==yes){
#      crfile=cr_out
      crfile=(output+flag)
      print("output cosmic-ray removed data= "+crfile)
   } else
      crfile="tmp_cr"
#
   print("# wacosm11 is now processing...")
   wacosm11 (in_f=crinfile,out_f=crfile,base=cr_base)
} else 
   print("wacosm11 not processing")     

# scattered light subtraction
if (scatter ==yes){
  flag=flag+"s"
   if (cosmicra==no){
      if (overscan==no){
#        scinfile=fl_in
        scinfile=inid
      } else
        scinfile=osfile
   } else
      scinfile=crfile
#
   if (sc_save ==yes){
#      scfile=sc_out
      scfile=output+flag
   } else
      scfile="tmp_sc"
#
   print("# Scattered light subtracting is now processing...")
   apscatter(scinfile,scfile,interac=sc_inter,referen=sc_refer,recente=sc_recen,resize=sc_resiz,edit=sc_edit,trace=sc_trace,fittrac=sc_fittr)
} else 
   print("Scattered light subtraction not processing")     

# flat fielding
if (flat ==yes){
   flag=flag+"f"
   if (scatter==no){
     if (cosmicra==no){
        if (overscan==no){
c          flinfile=fl_in
          flinfile=inid
        }else
          flinfile=osfile
     } else
        flinfile=crfile
  } else
        flinfile=scfile
#
   if (fl_save ==yes){
#      flfile=fl_out
      flfile=(output+flag)
      print("output flatted data= "+flfile)
   } else
      flfile="tmp_fl"
#
   print("# Flat fielding is now processing...")
   print(flinfile,"/",fl_refer,"=>",flfile)     
   imarith(flinfile,"/",fl_refer,flfile)
} else 
   print("flat-fielding not processing")     

# apall
if (apall ==yes){
  flag=flag+"_ec"
  if (flat==no){
    if(scatter==no){
      if (cosmicra==no){
        if (overscan==no){
#          apinfile=ap_in
          apinfile=inid
        } else
          apinfile=osfile
      } else 
        apinfile=crfile
    }else
      apinfile=scfile
  } else
    apinfile=flfile
#
   if (ap_save ==yes){
#      apfile=ap_out
      apfile=output+flag
   } else
      apfile="tmp_ap"
#
   print("# apall is now processing...")
   apall (input=apinfile, ,output=apfile, apertures=" ", format="echelle",
     references=ap_refer,profiles=" ", interactive=ap_inter, find=no, 
     recenter=ap_recen, resize=ap_resiz, edit=ap_edit,trace=ap_trace,
     fittrace=ap_fittr, extract=yes, extras=no, review=no, line=INDEF,
     nsum=100, lower=-10., upper=10., apidtable="",
     width=10.,radius=5.,threshold=0., 
     minsep=5., maxsep=1000.,order="increasing",aprecenter="",
     npeaks=INDEF, shift=no,llimit=ap_llimi,ulimit=ap_ulimi, 
     ylevel=ap_yleve, peak=yes, 
     bkg=no,r_grow=0.1, avglimits=yes, t_nsum=10, t_step=3, t_nlost=10,
     t_function="legendre",t_order=3,t_sample="*",t_naverage=1,t_niterate=2,
     t_low_reject=3., t_high_rejec=3., t_grow=0., background="none", skybox=1,
     weights="none", pfit="fit1d", clean=no, saturation=INDEF, readnoise="0.",
     gain="1.", lsigma=4., usigma=4., nsubaps=1)

} else
   print("apall not processing")

# Wavelength calibration (refspectra + dispcor)
if (wavecal ==yes){
   flag=flag+"w"
   if (apall==no){
      wvinfile=wv_in
   }else
      wvinfile=apfile
#
   if (wv_save ==yes){
#      wvfile=wv_out
      wvfile=output+flag
   } else
      wvfile="tmp_wv"
#
   print("# Wavelength calibration is now processing...")
   refspectra(input=wvinfile,answer=yes,referen=wv_refer,sort="MJD", group=" ")
   dispcor(input=wvinfile,output=wvfile)
} else
   print("wavelength-calibration not processing")

#
if (overscan ==yes){
  if (os_save ==no){
    imdel(images=osfile)
  }
}
if (cosmicra ==yes){
  if (cr_save ==no){
    imdel(images=crfile)
  }
}
if (flat ==yes){
  if (fl_save ==no){
    imdel(images=flfile)
  }
}
if (scatter ==yes){
  if (sc_save ==no){
    imdel(images=scfile)
  }
}
if (apall ==yes){
  if (ap_save ==no){
    imdel(images=apfile)
  }
}
if (wavecal ==yes){
  if (wv_save ==no){
    imdel(images=wvfile)
  }
}
end
