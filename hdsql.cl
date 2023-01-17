##################################################################
# hdsql : Subaru HDS Quick Look Script 
#  Originaly developed by Wako Aoki
#    revised by Akito Tajitsu <tajitsu@subaru.naoj.org>
#              2019.09.26 ver.2.60
###################################################################
procedure hdsql(inid)
### Input parameters
 string inid {prompt = 'Input frame ID'}
 string indirec {prompt = 'directory of Input data\n'}

 bool  batch=no {prompt = 'Batch Mode?'}
 string inlist {prompt = 'Input file list for batch-mode'}
 bool  overw=no {prompt = 'Force to overwrite existing images?\n'}

 bool   overscan=yes {prompt = 'Overscan?'}
 bool   biassub=no  {prompt = 'BIAS / Dark Subtraction?'}
 bool   maskbad=yes {prompt = 'Mask Bad Pixels?'}
 bool   linear=no   {prompt = 'Linearity Correction?'}
 bool   cosmicra=no {prompt = 'Cosmic Ray Rejection?'}
 bool   scatter=no {prompt = 'Scattered Light Subtraction?'}
 bool   xtalk=no {prompt = 'CCD Amp Cross-Talk Subtraction?'}
 bool   flat=no {prompt = 'Flat Fielding?'}
 bool   apall=no {prompt = 'Aperture Extraction?'}
 bool   isecf=no {prompt = 'Extract & Flat for IS? (override flat & apall)'}
 bool   wavecal=no  {prompt = 'Wavelength Calibration?'}
 bool   remask=no {prompt = 'Re-Mask Wave-calibrated Spectrum?'}
 bool   rvcorrect=no  {prompt = 'Heliocentric Wavelength Correction?'}
 bool   getcnt=no  {prompt = 'Measure spectrum count?'}
 bool   splot=no    {prompt = 'Splot Spectrum?\n\n### Overscan ###'}

# Parameters for overscan
 bool   os_save=yes {prompt = 'Save overscaned data?'}
 bool   os_yscan=no {prompt = 'Scan along Y-axis?'}
 int    os_ywin=5 {prompt = 'Smoothing pixels along Y-axis.\n\n### Bias/Dark Subtraction ###'}

# Parameters for BIAS Subtraction
 bool   bs_save=yes {prompt = 'Save BIAS / Dark subtracted data?'}
# string bs_in="" {prompt = 'Input frame for BIAS / Dark subtraction (if necessary)'}
 string bs_style="bias" {prompt = 'Subtraction style (bias|dark)', enum="bias|dark|both"}
 string bs_refer {prompt = 'BIAS frame'}
 string bs_dark  {prompt = 'Dark + BIAS frame\n\n### Masking Bad Pixels ###'}

# Parameters for maskbad
 bool   mb_save=yes {prompt = 'Save masked data?'}
# string mb_in="" {prompt = 'Input frame for Masking Bad Pixels (if necessary)'}
 string mb_refer {prompt = 'Bad Pix Mask frame'}
 bool   mb_auto=no {prompt = 'Auto mask creation from BIAS(bsrefer)?'}
 int   mb_upper=300 {prompt = 'Upper limit for mb_auto'}
 int   mb_lower=-100 {prompt = 'Lower limit for mb_auto'}
 bool  mb_clean=yes  {prompt = 'Cleaning by wacosm11?'}
 int   mb_base=1     {prompt = 'Baseline for wacosm11\n\n### Linearity Correction ###'}

# Parameters for Linearity Correction
 bool   ln_save=yes {prompt = 'Save Linearity Corrected data?\n\n### Cosmic-ray Rejection ###'}
# string ln_in="" {prompt = 'Input frame for Linearity Correction (if necessary)\n\n### Cosmic-ray Rejection ###'}

# Parameters for cosmicray-event rejection
 bool   cr_save=yes {prompt = 'Save cosmicray processed data?'}
# string cr_in="" {prompt = 'Input frame for wacosm1 (if necessary)'}
 string cr_proc="wacosm" {prompt = 'CR rejection procedure (wacosm|lacos)?\n### Parameters for wacosm11 ###', enum="wacosm|lacos"}
 real   cr_wbase=2000  {prompt = 'Baseline for wacosm11\n### Parameters for lacos_spec ###'}
 bool   cr_ldisp=no {prompt = 'Confirm w/Display? (need DS9)'}
 real   cr_lgain=1.67  {prompt = 'gain (electron/ADU)'}
 real   cr_lreadn=4.4  {prompt = 'read noise (electrons)'}
 int    cr_lxorder=9  {prompt = 'order of object fit (0=no fit)'}
 int    cr_lyorder=3  {prompt = 'order of sky line fit (0=no fit)'}
 real   cr_lclip=10.  {prompt = 'detection limit for cosmic rays(sigma)'}
 real   cr_lfrac=3.  {prompt = 'fractional detection limit fro neighbouring pix'}
 real   cr_lobjlim=5.  {prompt = 'contrast limit between CR and underlying object'}
 int   cr_lniter=4  {prompt = 'maximum number of iterations\n\n### Scattered-light Subtraction ###'}

# scattered light subtraction
 bool   sc_save=yes {prompt = 'Save scattered light subtracted data?'}
 string sc_in="" {prompt = 'Input frame for scattered light subtraction (if necessary)'}
 string sc_refer {prompt = 'Reference for aperture finding'}
 bool   sc_inter=yes {prompt = 'Run apscatter interactively?'}
 bool   sc_recen=yes {prompt = 'Recenter apertures for apscatter?'}
 bool   sc_resiz=yes {prompt = 'Resize apertures for apscatter?'}
 bool   sc_edit=yes  {prompt = 'Edit apertures for apscatter?'}
 bool   sc_trace=no {prompt = 'Trace apertures for apscatter?'}
 bool   sc_fittr=yes {prompt = 'Fit the traced points interactively for apscatter?\n\n### Cross-Talk Subtraction ###'}

# Cross-Talk Subtraction
 bool   xt_save=yes {prompt = 'Save cross-talk subtracted data?'}
# string xt_in="" {prompt = 'Input frame for cross-talk subtraction (if necessary)'}
 real    xt_amp=0.0012 {prompt = 'Cross-talk amplifier'}
 bool   xt_disp=no {prompt = 'Confirm w/Display? (need DS9)\n\n### Flat Fielding ###'}

# Flat fielding
 bool   fl_save=yes {prompt = 'Save flat-fielded data?'}
 string fl_in="" {prompt = 'Input frame for flat fielding (if necessary)'}
 string fl_refer {prompt = 'Flat frame\n\n### Aperture Extraction ###'}

# Parameters for apall
 bool   ap_save=yes {prompt = 'Save apalled data?'}
 string   ap_in="" {prompt = 'Input frame for apall (if necessary)?'}
 string ap_refer {prompt = 'Reference frame for apall'}
 bool   ap_inter=yes {prompt = 'Run apall interactively?'}
 bool   ap_recen=yes {prompt = 'Recenter apertures?'}
 bool   ap_resiz=yes {prompt = 'Resize apertures?'}
 bool   ap_edit=yes  {prompt = 'Edit apertures?'}
 bool   ap_trace=no {prompt = 'Trace apertures?'}
 bool   ap_fittr=no {prompt = 'Fit the traced points interactively?'}
 real   ap_nsum=10  {prompt = 'Number of Dispersion tosum for apfind'}
 real   ap_llimi=-30 {prompt = 'Lower aperture limit relative to center'}
 real   ap_ulimi=30 {prompt = 'Upper aperture limit relative to center'}
 real   ap_yleve=0.05 {prompt = 'Fraction of peak for automatic width determination?'} 
 bool   ap_peak=yes  {prompt = 'Is ylevel a fraction of the peak?'}
 string   ap_bg="none"  {prompt = 'Background to subtract\n\n### IS Extraction and Flat fielding ###', enum="none|average|median|minimum|fit"}

# Flat fielding
 bool   is_save=yes {prompt = 'Save IS extract & flat-fielded data?'}
 string is_in="" {prompt = 'Input frame for flat fielding (if necessary)'}
 bool   is_plot=yes{prompt= "Plot image and extract manually"}
 int is_stx=-12  {prompt ="Start pixel to extract (for is_plot=no)"}
 int is_edx=12  {prompt ="End pixel to extract (for is_plot=no)"}
 string is_bfix="fixpix"  {prompt = 'Fixing method for Bad Pix', enum="none|zero|fixpix"}
 real is_up=0.001 {prompt = 'Upper Limit for Bad Pix in ApNormalized Flat\n\n### Wavelength Calibration ###'}

# Parameters for wavelength calibration
 bool   wv_save=yes  {prompt = 'Save wavelength-calibrated data?'}
 string wv_in=""    {prompt = 'Input frame for wavelength calibration (if necessary)'}
 string wv_refer {prompt = 'Reference frame for refspectra'}
 bool wv_log=no   {prompt = 'Logarithmic wavelength scale?\n\n### Re-Mask after Wavelength Calibration###'}

# Parameters for remask
 bool  zm_save=yes  {prompt = 'Save re-masked data?'}
# string zm_in=""    {prompt = 'Input frame for re-mask afre wave calib. (if necessary)'}
 real   zm_val=1.0 {prompt = 'Pixel Value replaced to All Bad Pixels'}
 real   zm_thresh=0.1 {prompt = 'Threshold pixel value for bad column [0-1]\n\n### Heliocentric Wavelength Correction ###'}

# Parameters for Heliocentric wavelength correction
 string rv_in=""    {prompt = 'Input frame for radial velocity correction (if necessary)'}
 string rv_obs="subaru"    {prompt = 'Observatory\n\n### Get Spectrum Count ###'}

# Parameters for Get Spectrum Count
 int ge_stx=1900  {prompt ="Start pixel to get count"}
 int ge_edx=2100  {prompt ="End pixel to get count"}
 real ge_low=0.5  {prompt ="Low rejection in sigma of fit"}
 real ge_high=1.5   {prompt ="High rejection in sigma of fit\n\n### Splot ###"}
 
 int sp_line=1 {prompt = 'Splot image line/aperture to plot\n'}

begin
string version="3.00 (01-17-2023)"
string input_id
string input0,input,output
string flag0,flag
string osfile
string mbinfile,mbfile
string bsinfile,bsfile
string irinfile,irfile
string lninfile,lnfile
string crinfile,crfile
string flinfile,flfile
string isinfile,isfile
string xtinfile,xtfile
string scinfile,scfile
string apinfile,apfile
string wvinfile,wvfile
string zminfile,zmfile
string rvinfile,rvfile
string apbg
string rvobs
string mask_ap, mask_wv,temp1, temp2, temp3, maskimg, masktemp, mask0, mskap
int x_in, y_in, x_msk, y_msk, ccd_in, ccd_msk
string dktemp1, dktemp2
int et_in, et_dk
real et_ratio
bool os_done, bs_done, mb_done, ln_done, cr_done,sc_done,fl_done,is_done,xt_done,ap_done
bool wv_done, zm_done,rv_done
string hq_tmp
bool d_ans,la_ans, do_flag
string nextin
string temp_id, batch_id[2000]
int batch_n, batch_i
real is_low, is_upp
real ls_gain, ls_readn, ls_sigclip, ls_sigfrac,ls_objlim
int  ls_xorder, ls_yorder, ls_niter
int ans_int
real ans_real
int mean_cnt, max_cnt, cont_cnt
string cnt_out

task    $ln    = $foreign

ls_gain=cr_lgain
ls_readn=cr_lreadn
ls_sigclip=cr_lclip
ls_sigfrac=cr_lfrac
ls_objlim=cr_lobjlim
ls_xorder=cr_lxorder
ls_yorder=cr_lyorder
ls_niter=cr_lniter


if(batch){
  list=inlist
  batch_n=0

  printf("\n############################################\n")
  printf("###   Starting hdsql in Batch Mode\n")
  printf("############################################\n")
  printf("  Input files are...\n")
  while(fscan(list,temp_id)==1){
    printf("   %s%s\n",indirec,temp_id)
    batch_n=batch_n+1
    batch_id[batch_n]=temp_id
  }

  printf(" Total frame number=%d.\n",batch_n)
  printf(">>> Do you want to start Batch mode? (y/n) : ")
  while(scan(d_ans)!=1) {}
  if(!d_ans){
    printf("!!! ABORT !!!\n")
    bye
  }

  list=inlist
}

do_flag=yes
batch_i=1
while(do_flag){

if(batch){
  if(batch_i<batch_n+1){
    input_id=batch_id[batch_i]
    printf("\n##########################\n")
    printf("###   Batch Mode\n")
    printf("###     Input ID = %s\n", input_id)
    printf("##########################\n\n")
  }
  else{
    do_flag=no
    bye
  }
}
else{
  input_id=inid
}

os_done=no
bs_done=no
mb_done=no
ln_done=no
cr_done=no
sc_done=no
fl_done=no
is_done=no
xt_done=no
ap_done=no
wv_done=no
zm_done=no
rv_done=no

apbg=ap_bg
rvobs=rv_obs

flag=""
nextin=""


 output  = ("H"+input_id)
 print("output ID" + output)

 input0=(indirec+input_id+".fits[0]")

 input=(indirec+input_id+".fits")
 print("input data= "+input)

# overscan
if (overscan){
printf("\n")
printf("##################################\n")
printf("# [ 1/13] Overscan\n")
printf("##################################\n")

   flag0=flag
   flag="o"
   if (os_save){
#      osfile=os_out
      osfile=(output+flag)
   } else
      osfile=mktemp("tmp_os")
   if((access(osfile))||access(osfile//".fits")){
     printf("*** OverScanned file \"%s\" already exsits!!\n",osfile)
     if(overw){
        printf("*** Automatcally Rmoving \"%s\" ...\n",osfile)
        imdelete(osfile)
     }
     else{
       printf(">>> Do you want to overwrite this file? (y/n) : ")
       while(scan(d_ans)!=1) {}
       if(d_ans){
          imdelete(osfile)
       }
       else{
          printf("!!! Please remove exsiting file !!! ABORT !!!\n")
          bye
       }
     }
   }
   print("output overscaned data= "+osfile)
   print("# Overscan is now processing...")
   overscan(inimage=input0,outimage=osfile)
   hedit(osfile,'HQ_OS',"done",add+,del-, ver-,show-,update+)
   os_done=yes
   nextin=osfile
} else {
   print("overscan not processing")
   os_done=no
}


# bias
if (biassub){
printf("\n")
printf("##################################\n")
printf("# [ 2/13] Bias / Dark Subtraction\n")
printf("##################################\n")

   flag0=flag
   flag=flag+"b"	
   if(flag0==""){
#      if(bs_in==""){
        bsinfile=input
#      }
#      else{
#        bsinfile=bs_in
#        output =bs_in
#      }
   }
   else{
     bsinfile=nextin
   }
 #
   if (bs_save){
      bsfile=(output+flag)
      print("output Bias/Dark Subtracted data= "+bsfile)
   } else
      bsfile=mktemp("tmp_bs")
   if((access(bsfile))||access(bsfile//".fits")){
     printf("*** Bias/Dark subtracted file \"%s\" already exsits!!\n",bsfile)
     if(overw){
        printf("*** Automatcally Rmoving \"%s\" ...\n",bsfile)
        imdelete(bsfile)
     }
     else{
       printf(">>> Do you want to overwrite this file? (y/n) : ")
       while(scan(d_ans)!=1) {}
       if(d_ans){
          imdelete(bsfile)
       }
       else{
          printf("!!! Please remove exsiting file !!! ABORT !!!\n")
          bye
       }
     }
   }
#
   if (bs_style == "bias"){
     print("# bias subtraction is now processing...")
     imarith(bsinfile,'-', bs_refer, bsfile, ver-,noact-)
   }
   else {
     dktemp1=mktemp("tmp_dk")
     imarith(bs_dark,'-', bs_refer, dktemp1, ver-,noact-)

     imgets(bsinfile,'EXPTIME')
     et_in=int(imgets.value)
     imgets(dktemp1,'EXPTIME')
     et_dk=int(imgets.value)

     if(et_in==et_dk){
       print("# dark subtraction is now processing...")
       imarith(bsinfile,'-', dktemp1, bsfile, ver-,noact-)
     }
     else{
       dktemp2=mktemp("tmp_dk")
       printf("# scaling dark frame x %d/%d...\n",et_in,et_dk)
       et_ratio=real(et_in)/real(et_dk)
       imarith(dktemp1,'*', et_ratio, dktemp2, ver-,noact-)
       print("# dark subtraction is now processing...")
       imarith(bsinfile,'-', dktemp2, bsfile, ver-,noact-)
       
       imdelete(dktemp2)
     }
     imdelete(dktemp1)

     if (bs_style == "both"){
       dktemp1=mktemp("tmp_dk")
       imrename(bsfile,dktemp1)

       print("# bias subtraction is now processing...")
       imarith(dktemp1,'-', bs_refer, bsfile, ver-,noact-)

       imdelete(dktemp1)
     }
   }
   hedit(bsfile,'HQ_BS',"done",add+,del-, ver-,show-,update+)
   bs_done=yes
   nextin=bsfile
} else  {
   print("bias/dark subtraction not processing")     
   bs_done=no
}


# mask bad column
if (maskbad){
printf("\n")
printf("##################################\n")
printf("# [ 3/13] Masking Bad Pixels\n")
printf("##################################\n")

   flag0=flag
   flag=flag+"m"	
   if(flag0==""){
#      if(mb_in==""){
        mbinfile=input
#      }
#      else{
#        mbinfile=mb_in
#        output =mb_in
#      }
   }
   else{
     mbinfile=nextin
   }
#
   if (mb_save){
      mbfile=(output+flag)
      print("output bad pix masked data= "+mbfile)
   } else
      mbfile=mktemp("tmp_mb")
   if((access(mbfile))||access(mbfile//".fits")){
     printf("*** Masked file \"%s\" already exsits!!\n",mbfile)
     if(overw){
        printf("*** Automatcally Rmoving \"%s\" ...\n",mbfile)
        imdelete(mbfile)
     }
     else{
       printf(">>> Do you want to overwrite this file? (y/n) : ")
       while(scan(d_ans)!=1) {}
       if(d_ans){
          imdelete(mbfile)
       }
       else{
          printf("!!! Please remove exsiting file !!! ABORT !!!\n")
          bye
       }
     }
   }
#
   print("# masking bad pixels...")

## Auto Creation
   if(mb_auto){
     masktemp=mktemp("tmp_msk")
     printf("# Creating mask from BIAS \"%s\"...\n",bs_refer)
     mkbadmask(bs_refer, masktemp, lower=mb_lower, upper=mb_upper, clean=mb_clean, base=mb_base)
     maskimg=masktemp
   }
   else{
     maskimg=mb_refer
   }

## Get Header Information
    imgets(mbinfile,'i_naxis1')
    x_in=int(imgets.value)
    imgets(mbinfile,'i_naxis2')
    y_in=int(imgets.value)

    imgets(maskimg,'i_naxis1')
    x_msk=int(imgets.value)
    imgets(maskimg,'i_naxis2')
    y_msk=int(imgets.value)

    if( (x_msk!=x_in) || (y_msk!=y_in) ){
      printf("####### Error !! MASK dimenstion mismatch!! ABORT!! #######\n")
      bye
    }

    imgets(mbinfile,'DET-ID')
    ccd_in=int(imgets.value)
    imgets(maskimg,'DET-ID')
    ccd_msk=int(imgets.value)

    if(ccd_msk!=ccd_in){
      printf("####### Error !! MASK CCD Color mismatch!! ABORT!! #######\n")
      bye
    }

   imcopy(mbinfile, mbfile)
   fixpix(mbfile, maskimg,linterp=INDEF, cinterp=2, ver+, pixels-)
   hedit(mbfile,'H_MASK0',maskimg,add+,del-, ver-,show-,update+)
   hedit(mbfile,'HQ_MB',"done",add+,del-, ver-,show-,update+)
   mb_done=yes
   nextin=mbfile
   mask0=maskimg
} else {
   print("bad column mask not processing")     
   mb_done=no
}

# linearity
if (linear){
printf("\n")
printf("##################################\n")
printf("# [ 4/13] Linearity Correction\n")
printf("##################################\n")

   flag0=flag
   flag=flag+"l"	
   if(flag0==""){
#      if(ln_in==""){
        lninfile=input
#      }
#      else{
#        lninfile=ln_in
#        output=ln_in
#      }

      imgets(lninfile,'HQ_MB')
      hq_tmp=imgets.value
      if(hq_tmp=="done"){
         mb_done=yes
         hq_tmp=""
          
         imgets(lninfile,'H_MASK0')
         mask0=imgets.value
      }
   }
   else{
     lninfile=nextin
   }
#
   if (ln_save){
      lnfile=(output+flag)
      print("output linearity corrected data= "+lnfile)
   } else
      lnfile=mktemp("tmp_ln")
   if((access(lnfile))||access(lnfile//".fits")){
     printf("*** Linearity Corrected file \"%s\" already exsits!!\n",lnfile)
     if(overw){
        printf("*** Automatcally Rmoving \"%s\" ...\n",lnfile)
        imdelete(lnfile)
     }
     else{
       printf(">>> Do you want to overwrite this file? (y/n) : ")
       while(scan(d_ans)!=1) {}
       if(d_ans){
          imdelete(lnfile)
       }
       else{
          printf("!!! Please remove exsiting file !!! ABORT !!!\n")
          bye
       }
     }
   }
#
   print("# linearity correction is now processing...")
   hdslinear(lninfile,lnfile,outtype="real", auto_b+)
   hedit(lnfile,'HQ_LN',"done",add+,del-, ver-,show-,update+)
   ln_done=yes
   nextin=lnfile
} else {
   print("linearity correction not processing")     
   ln_done=no
}



# wacosm11
if (cosmicra){
printf("\n")
printf("##################################\n")
printf("# [ 5/13] Cosmic Ray Rejection\n")
printf("##################################\n")

   flag0=flag
   if (cr_proc == "lacos"){
     flag=flag+"C"
     printf("### Using lacos_spec for CR Rejection ###\n")
   }else{
     flag=flag+"c"
     printf("### Using wacosm for CR Rejection ###\n")
   }
   if(flag0==""){
#      if(cr_in==""){
        crinfile=input
#      }
#      else{
#        crinfile=cr_in
#        output=cr_in
#      }

      imgets(crinfile,'HQ_MB')
      hq_tmp=imgets.value
      if(hq_tmp=="done"){
         mb_done=yes
         hq_tmp=""
          
         imgets(crinfile,'H_MASK0')
         mask0=imgets.value
      }
   }
   else{
     crinfile=nextin
   }
#
   if (cr_save){
      crfile=(output+flag)
      print("output cosmic-ray removed data= "+crfile)
   } else
      crfile=mktemp("tmp_cr")
   if((access(crfile))||access(crfile//".fits")){
     printf("*** Cosmic Ray Rejected file \"%s\" already exsits!!\n",crfile)
     if(overw){
        printf("*** Automatcally Rmoving \"%s\" ...\n",crfile)
        imdelete(crfile)
     }
     else{
       printf(">>> Do you want to overwrite this file? (y/n) : ")
       while(scan(d_ans)!=1) {}
       if(d_ans){
          imdelete(crfile)
       }
       else{
          printf("!!! Please remove exsiting file !!! ABORT !!!\n")
          bye
       }
     }
   }
#

   if (cr_proc == "lacos"){
LACOSM:
     print("# lacos_spec is now processing...")
     printf("### If failed, load STSDAS then retry ###\n")
     if((access(crinfile//"_badpix"))||access(crinfile//"_badpix"//".fits")){
        imdelete(crinfile//"_badpix")
     }
     lacos_spec(crinfile,crfile,crinfile//"_badpix",
       gain=ls_gain,readn=ls_readn,xorder=ls_xorder,yorder=ls_yorder,
       sigclip=ls_sigclip,sigfrac=ls_sigfrac,objlim=ls_objlim,
       niter=ls_niter,ver+)
     if(cr_ldisp){
       display(crinfile,1)
       display(crfile,2)
       display(crinfile//"_badpix",3)
       printf("# Displaying [1]IN  [2]OUT  [3]BadPix ...\n")     
       printf("# If you want to compare please tile them in your DS9\n")     
       printf(">>> OK to go to the next step? (y/n) : ")     
       while(scan(la_ans)!=1) {}
       if(!la_ans){
         printf(">>> Input New Xorder (%d) : ",ls_xorder) 
         while( scan(ans_int) == 0 )
         print(ans_int)
         ls_xorder=ans_int
         printf(">>> Input New Yorder (%d) : ",ls_yorder) 
         while( scan(ans_int) == 0 )
         print(ans_int)
         ls_yorder=ans_int
         printf(">>> Input New SigClip (%.2f) : ",ls_sigclip) 
         while( scan(ans_real) == 0 )
         print(ans_real)
         ls_sigclip=ans_real
         printf(">>> Input New SigFrac (%.2f) : ",ls_sigfrac) 
         while( scan(ans_real) == 0 )
         print(ans_real)
         ls_sigfrac=ans_real
         printf(">>> Input New ObjLim (%.2f) : ",ls_objlim) 
         while( scan(ans_real) == 0 )
         print(ans_real)
         ls_objlim=ans_real

         imdelete(crfile)
         goto LACOSM
       }
     }
   }
   else{
# wacosm
     print("# wacosm11 is now processing...")
     wacosm11 (in_f=crinfile,out_f=crfile,base=cr_wbase)
  }
  hedit(crfile,'HQ_CR',"done",add+,del-, ver-,show-,update+)
  cr_done=yes
  nextin=crfile
}
else {
   print("CR rejection not processing")     
   cr_done=no
}

# scattered light subtraction
if (scatter){
printf("\n")
printf("##################################\n")
printf("# [ 6/13] Scattered Light Subtraction\n")
printf("##################################\n")

   flag0=flag
   flag=flag+"s"	
   if(flag0==""){
      if(sc_in==""){
        scinfile=input
      }
      else{
        scinfile=sc_in
        output=sc_in
      }

      imgets(scinfile,'HQ_MB')
      hq_tmp=imgets.value
      if(hq_tmp=="done"){
         mb_done=yes
         hq_tmp=""
          
         imgets(scinfile,'H_MASK0')
         mask0=imgets.value
      }
   }
   else{
     scinfile=nextin
   }
#
   if (sc_save){
#      scfile=sc_out
      scfile=output+flag
   } else
      scfile=mktemp("tmp_sc")
   if((access(scfile))||access(scfile//".fits")){
     printf("*** Scattered Light Subtracted file \"%s\" already exsits!!\n",scfile)
     if(overw){
        printf("*** Automatcally Rmoving \"%s\" ...\n",scfile)
        imdelete(scfile)
     }
     else{
       printf(">>> Do you want to overwrite this file? (y/n) : ")
       while(scan(d_ans)!=1) {}
       if(d_ans){
          imdelete(scfile)
       }
       else{
          printf("!!! Please remove exsiting file !!! ABORT !!!\n")
          bye
       }
     }
   }
#
    imgets(scinfile,'DET-ID')
    ccd_in=int(imgets.value)
    imgets(sc_refer,'DET-ID')
    ccd_msk=int(imgets.value)

    if(ccd_msk!=ccd_in){
      printf("####### Error !! Aperture Reference CCD Color mismatch!! ABORT!! #######\n")
      bye
    }

   print("# Scattered light subtracting is now processing...")
   apscatter(scinfile,scfile,interac=sc_inter,referen=sc_refer,recente=sc_recen,resize=sc_resiz,edit=sc_edit,trace=sc_trace,fittrac=sc_fittr)
   hedit(scfile,'HQ_SC',"done",add+,del-, ver-,show-,update+)
   sc_done=yes
   nextin=scfile
} else {
   print("Scattered light subtraction not processing")     
   sc_done=no
}

# xtalk subtraction
if (xtalk){
printf("\n")
printf("##################################\n")
printf("# [ 7/13] Cross-Talk Subtraction\n")
printf("##################################\n")

   flag0=flag
   flag=flag+"x"	
   if(flag0==""){
#      if(xt_in==""){
        xtinfile=input
#      }
#      else{
#        xtinfile=xt_in
#        output=xt_in
#      }

      imgets(xtinfile,'HQ_MB')
      hq_tmp=imgets.value
      if(hq_tmp=="done"){
         mb_done=yes
         hq_tmp=""
          
         imgets(xtinfile,'H_MASK0')
         mask0=imgets.value
      }
   }
   else{
     xtinfile=nextin
   }
#
   if (xt_save){
      xtfile=(output+flag)
      print("output flatted data= "+xtfile)
   } else
      xtfile=mktemp("tmp_xt")
   if((access(xtfile))||access(xtfile//".fits")){
     printf("*** Cross-Talk Subtracted file \"%s\" already exsits!!\n",xtfile)
     if(overw){
        printf("*** Automatcally Rmoving \"%s\" ...\n",xtfile)
        imdelete(xtfile)
     }
     else{
       printf(">>> Do you want to overwrite this file? (y/n) : ")
       while(scan(d_ans)!=1) {}
       if(d_ans){
          imdelete(xtfile)
       }
       else{
          printf("!!! Please remove exsiting file !!! ABORT !!!\n")
          bye
       }
     }
   }
#  
   print("# Cross-Talk Subtraction is now processing...")
   hdssubx(xtinfile, xtfile, amp=xt_amp, disp=xt_disp)
   hedit(xtfile,'HQ_XT',"done",add+,del-, ver-,show-,update+)
   xt_done=yes
   nextin=xtfile
} else {
   print("cross-talk subtraction not processing")     
   xt_done=no
}


# flat fielding
if (isecf){
printf("\n")
printf("##################################\n")
printf("# [(8+9)/13] Flat Fielding & Extraction for IS\n")
printf("##################################\n")

   flag0=flag
   flag=flag+"_ecf"	
   if(flag0==""){
      if(is_in==""){
        isinfile=input
      }
      else{
        isinfile=is_in
        output=is_in
      }

      imgets(isinfile,'HQ_MB')
      hq_tmp=imgets.value
      if(hq_tmp=="done"){
         mb_done=yes
         hq_tmp=""
          
         imgets(isinfile,'H_MASK0')
         mask0=imgets.value
      }
   }
   else{
     isinfile=nextin
   }
#
   if (is_save){
      isfile=(output+flag)
      print("output IS extracted & flatted data= "+isfile)
   } else
      isfile=mktemp("tmp_is")
   if((access(isfile))||access(isfile//".fits")){
     printf("*** IS Extracted & Flat Fielded file \"%s\" already exsits!!\n",isfile)
     if(overw){
        printf("*** Automatcally Rmoving \"%s\" ...\n",isfile)
        imdelete(isfile)
     }
     else{
       printf(">>> Do you want to overwrite this file? (y/n) : ")
       while(scan(d_ans)!=1) {}
       if(d_ans){
          imdelete(isfile)
       }
       else{
          printf("!!! Please remove exsiting file !!! ABORT !!!\n")
          bye
       }
     }
   }
#
    imgets(isinfile,'DET-ID')
    ccd_in=int(imgets.value)
    imgets(fl_refer,'DET-ID')
    ccd_msk=int(imgets.value)

    if(ccd_msk!=ccd_in){
      printf("####### Error !! Flat CCD Color mismatch!! ABORT!! #######\n")
      bye
    }

   print("# IS Extraction & Flat fielding is now processing...")
   hdsis_ecf(isinfile,isfile,flatimg=fl_refer,ref_ap=ap_refer,
              badfix=is_bfix,fix_up=is_up,plot=is_plot,st_x=is_stx,ed_x=is_edx)
   hedit(isfile,'HQ_IS',"done",add+,del-, ver-,show-,update+)
   is_done=yes
   fl_done=yes
   ap_done=yes
   mskap=isinfile
   nextin=isfile
}
else{
if (flat){
printf("\n")
printf("##################################\n")
printf("# [ 8/13] Flat Fielding\n")
printf("##################################\n")

   flag0=flag
   flag=flag+"f"	
   if(flag0==""){
      if(fl_in==""){
        flinfile=input
      }
      else{
        flinfile=fl_in
        output=fl_in
      }

      imgets(flinfile,'HQ_MB')
      hq_tmp=imgets.value
      if(hq_tmp=="done"){
         mb_done=yes
         hq_tmp=""
          
         imgets(flinfile,'H_MASK0')
         mask0=imgets.value
      }
   }
   else{
     flinfile=nextin
   }
#
   if (fl_save){
#      flfile=fl_out
      flfile=(output+flag)
      print("output flatted data= "+flfile)
   } else
      flfile=mktemp("tmp_fl")
   if((access(flfile))||access(flfile//".fits")){
     printf("*** Flat Fielded file \"%s\" already exsits!!\n",flfile)
     if(overw){
        printf("*** Automatcally Rmoving \"%s\" ...\n",flfile)
        imdelete(flfile)
     }
     else{
       printf(">>> Do you want to overwrite this file? (y/n) : ")
       while(scan(d_ans)!=1) {}
       if(d_ans){
          imdelete(flfile)
       }
       else{
          printf("!!! Please remove exsiting file !!! ABORT !!!\n")
          bye
       }
     }
   }
#
    imgets(flinfile,'DET-ID')
    ccd_in=int(imgets.value)
    imgets(fl_refer,'DET-ID')
    ccd_msk=int(imgets.value)

    if(ccd_msk!=ccd_in){
      printf("####### Error !! Flat CCD Color mismatch!! ABORT!! #######\n")
      bye
    }

   print("# Flat fielding is now processing...")
   print(flinfile,"/",fl_refer,"=>",flfile)     
   imarith(flinfile,"/",fl_refer,flfile)
   hedit(flfile,'HQ_FL',"done",add+,del-, ver-,show-,update+)
   fl_done=yes
   nextin=flfile
} else {
   print("flat-fielding not processing")     
   fl_done=no
}


# apall
if (apall){
  printf("\n")
  printf("##################################\n")
  printf("# [ 9/13] Aperture Extraction\n")
  printf("##################################\n")

   flag0=flag
   flag=flag+"_ec"	
   if(flag0==""){
      if(ap_in==""){
        apinfile=input
      }
      else{
        apinfile=ap_in
        output=ap_in
      }

      imgets(apinfile,'HQ_MB')
      hq_tmp=imgets.value
      if(hq_tmp=="done"){
         mb_done=yes
         hq_tmp=""
          
         imgets(apinfile,'H_MASK0')
         mask0=imgets.value
      }
   }
   else{
     apinfile=nextin
   }
#
   if (ap_save){
#      apfile=ap_out
      apfile=output+flag
   } else
      apfile=mktemp("tmp_ap")
   if((access(apfile))||access(apfile//".fits")){
     printf("*** Aperture Extracted file \"%s\" already exsits!!\n",apfile)
     if(overw){
        printf("*** Automatcally Rmoving \"%s\" ...\n",apfile)
        imdelete(apfile)
     }
     else{
       printf(">>> Do you want to overwrite this file? (y/n) : ")
       while(scan(d_ans)!=1) {}
       if(d_ans){
          imdelete(apfile)
       }
       else{
          printf("!!! Please remove exsiting file !!! ABORT !!!\n")
          bye
       }
     }
   }
#
    imgets(apinfile,'DET-ID')
    ccd_in=int(imgets.value)
    imgets(ap_refer,'DET-ID')
    ccd_msk=int(imgets.value)

    if(ccd_msk!=ccd_in){
      printf("####### Error !! Aperture Reference CCD Color mismatch!! ABORT!! #######\n")
      bye
    }

   print("# apall is now processing...")

  if(apbg=='none'){
     apall (input=apinfile,output=apfile, apertures="", format="echelle",
       references=ap_refer,profiles=" ", interactive=ap_inter, find=no, 
       recenter=ap_recen, resize=ap_resiz, edit=ap_edit,trace=ap_trace,
       fittrace=ap_fittr, extract=yes, extras=yes, review=no, line=INDEF,
       nsum=ap_nsum, lower=-10., upper=10., apidtable="",
       width=10.,radius=5.,threshold=0., 
       minsep=5., maxsep=1000.,order="increasing",aprecenter="",
       npeaks=INDEF, shift=no,llimit=ap_llimi,ulimit=ap_ulimi, 
       ylevel=ap_yleve, peak=yes, 
       bkg=no,r_grow=0.1, avglimits=yes, t_nsum=10, t_step=3, t_nlost=10,
       t_function="legendre",t_order=3,t_sample="*",t_naverage=1,t_niterate=2,
       t_low_reject=3., t_high_rejec=3., t_grow=0., background=apbg, skybox=1,
       weights="none", pfit="fit1d", clean=no, saturation=INDEF, readnoise="0.",
       gain="1.", lsigma=4., usigma=4., nsubaps=1)
   }else{
     apall (input=apinfile,output=apfile, apertures="", format="echelle",
       references=ap_refer,profiles=" ", interactive=ap_inter, find=no, 
       recenter=ap_recen, resize=ap_resiz, edit=ap_edit,trace=ap_trace,
       fittrace=ap_fittr, extract=yes, extras=no, review=no, line=INDEF,
       nsum=ap_nsum, lower=-10., upper=10., apidtable="",
       width=10.,radius=5.,threshold=0., 
       minsep=5., maxsep=1000.,order="increasing",aprecenter="",
       npeaks=INDEF, shift=no,llimit=ap_llimi,ulimit=ap_ulimi, 
       ylevel=ap_yleve, peak=yes, 
       bkg=no,r_grow=0.1, avglimits=yes, t_nsum=10, t_step=3, t_nlost=10,
       t_function="legendre",t_order=3,t_sample="*",t_naverage=1,t_niterate=2,
       t_low_reject=3., t_high_rejec=3., t_grow=0., background=apbg, skybox=1,
       weights="none", pfit="fit1d", clean=no, saturation=INDEF, readnoise="0.",
       gain="1.", lsigma=4., usigma=4., nsubaps=1)
  }

   hedit(apfile,'HQ_AP',"done",add+,del-, ver-,show-,update+)
   hedit(apfile,'H_MSKAP',apinfile,add+,del-, ver-,show-,update+)
   mskap=apinfile
   ap_done=yes
   nextin=apfile
} else {
    print("apall not processing")
   ap_done=no
}
}


# Wavelength calibration (refspectra + dispcor)
  if (wavecal){
printf("\n")
printf("##################################\n")
printf("# [10/13] Wavelength Calibration\n")
printf("##################################\n")

   flag0=flag
   flag=flag+"w"	
   if(flag0==""){
      if(wv_in==""){
        wvinfile=input
      }
      else{
        wvinfile=wv_in
        output=wv_in
      }

      imgets(wvinfile,'HQ_AP')
      hq_tmp=imgets.value
      if(hq_tmp=="done"){
         ap_done=yes
         hq_tmp=""
      }
      else {
         printf("####### Error !! Input file for Wavelength Calibration must be aperture extracyed!! ABORT!! #######\n")
         bye
      }

      imgets(wvinfile,'HQ_MB')
      hq_tmp=imgets.value
      if(hq_tmp=="done"){
         mb_done=yes
         hq_tmp=""
          
         imgets(wvinfile,'H_MASK0')
         mask0=imgets.value

         imgets(wvinfile,'H_MSKAP')
         mskap=imgets.value
      }
   }
   else{
      if(!ap_done){
         printf("####### Error !! Input file for Wavelength Calibration must be aperture extracted!! ABORT!! #######\n")
         bye
      }
      wvinfile=nextin
   }

   if (wv_save){
      wvfile=output+flag
   } else
      wvfile=mktemp("tmp_wv")
   if((access(wvfile))||access(wvfile//".fits")){
     printf("*** Wavelength Calibrated file \"%s\" already exsits!!\n",wvfile)
     if(overw){
        printf("*** Automatcally Rmoving \"%s\" ...\n",wvfile)
        imdelete(wvfile)
     }
     else{
       printf(">>> Do you want to overwrite this file? (y/n) : ")
       while(scan(d_ans)!=1) {}
       if(d_ans){
          imdelete(wvfile)
       }
       else{
          printf("!!! Please remove exsiting file !!! ABORT !!!\n")
          bye
       }
     }
   }
#

   imgets(wvinfile,'DET-ID')
   ccd_in=int(imgets.value)
   imgets(wv_refer,'DET-ID')
   ccd_msk=int(imgets.value)

   if(ccd_msk!=ccd_in){
     printf("####### Error !! Aperture Reference CCD Color mismatch!! ABORT!! #######\n")
     bye
   }

   print("# Wavelength calibration is now processing...")
   refspectra(input=wvinfile,answer=yes,referen=wv_refer,sort="MJD", group=" ", answer=yes)
   dispcor(input=wvinfile,output=wvfile, log-)
   hedit(wvfile,'HQ_WV',"done",add+,del-, ver-,show-,update+)
   wv_done=yes
   nextin=wvfile
} else {
     print("wavelength-calibration not processing")
     wv_done=no
}

if(remask){
printf("\n")
printf("##################################\n")
printf("# [11/13] Re-Mask Wave-Calibrated Spectrum\n")
printf("##################################\n")

   flag0=flag
   flag=flag+"z"	
   if(flag0==""){
#      if(zm_in==""){
        zminfile=input
#      }
#      else{
#        zminfile=zm_in
#        output=zm_in
#      }

      imgets(zminfile,'HQ_AP')
      hq_tmp=imgets.value
      if(hq_tmp=="done"){
         ap_done=yes
         hq_tmp=""
      }
      else {
         printf("####### Error !! Input file for Re-Masking must be aperture extracted!! ABORT!! #######\n")
         bye
      }

      imgets(zminfile,'HQ_WV')
      hq_tmp=imgets.value
      if(hq_tmp=="done"){
         wv_done=yes
         hq_tmp=""
      }
      else {
         printf("####### Warning! Re-Masking only for Aperture Extracted data\n")
      }


      imgets(zminfile,'HQ_MB')
      hq_tmp=imgets.value
      if(hq_tmp=="done"){
         mb_done=yes
         hq_tmp=""
          
         imgets(zminfile,'H_MASK0')
         mask0=imgets.value

         imgets(zminfile,'H_MSKAP')
         mskap=imgets.value
      }
      else{
         printf("####### Error !! Input file has not been masked!! ABORT!! #######\n")
         bye
      }
   }
   else{
      if(!mb_done){
         printf("####### Error !! Input file for Re-masking has not been masked!! ABORT!! #######\n")
         bye
      }
      if(!ap_done){
         printf("####### Error !! Input file for Re-masking must be aperture extracted!! ABORT!! #######\n")
         bye
      }
      if(!wv_done){
         printf("####### Warning! Re-Masking only for Aperture Extracted data\n")
      }
      zminfile=nextin
    }
  
    printf("# Extracting mask referring \"%s\"...\n", mskap)
    mask_ap=mktemp("tmp.mask")
    
    if(access(mask_ap//".fits")) imdelete(mask_ap)
     
    if(isecf){
      imgets(isfile,'H_IS_LOW')
      is_low=real(imgets.value)
      imgets(isfile,'H_IS_UPP')
      is_upp=real(imgets.value)

      apresize(isinfile, referen=ap_refer, interac-, find-, recenter-,
             resize+,edit-, llimit=is_low, ulimit=is_upp, ylevel=0.0)

      apall (input=mask0 ,output=mask_ap, apertures=" ", format="echelle",
         references=isinfile,profiles=" ", interactive=no, find=no, 
         recenter=no, resize=no, edit=no,trace=no,
         lower=is_low, upper=is_upp,llimit=is_low,ulimit=is_upp,
         fittrace=no, extract=yes, extras=no, review=no, ylevel=INDEF)
    }
    else{
      apall (input=mask0 ,output=mask_ap, apertures=" ", format="echelle",
         references=mskap,profiles=" ", interactive=no, find=no, 
         recenter=no, resize=no, edit=no,trace=no,
         fittrace=no, extract=yes, extras=no, review=no)
    }

    imreplace(mask_ap, 1, imagina=0.,upper=INDEF, lower=1.0, radius=0.)

    printf(">>> Mask for fixpix \"%s\" has been created!\n",mask_ap)

    if (zm_save){
       zmfile=output+flag
     } else 
       zmfile=mktemp("tmp_zm")
    
   if((access(zmfile))||access(zmfile//".fits")){
     printf("*** Re-masked file \"%s\" already exsits!!\n",zmfile)
     if(overw){
        printf("*** Automatcally Rmoving \"%s\" ...\n",zmfile)
        imdelete(zmfile)
     }
     else{
       printf(">>> Do you want to overwrite this file? (y/n) : ")
       while(scan(d_ans)!=1) {}
       if(d_ans){
          imdelete(zmfile)
       }
       else{
          printf("!!! Please remove exsiting file !!! ABORT !!!\n")
          bye
       }
     }
   }

    temp1=mktemp("tmp_mask")
    temp2=mktemp("tmp_mask")

   if(!wv_done){
        imreplace(mask_ap, 0, imagina=0.,upper=zm_thresh, lower=INDEF, radius=0.)
        imreplace(mask_ap, 1, imagina=0.,upper=INDEF, lower=zm_thresh, radius=0.)

        imarith(zminfile,"*", mask_ap, temp1)

        temp3=mktemp("tmp_mask")
        imarith(mask_ap,"*", zm_val, temp3)
        imarith(temp1,"-", temp3, temp2)
        imdelete(temp3)

        imarith(zminfile,"-", temp2, zmfile)

        mask_wv="Mask_"//nextin
        if(access(mask_wv//".fits")) imdelete(mask_wv)
        imrename (mask_ap, mask_wv)
   }else{
      print("# Wavelength calibration for MASK is now processing...")
      if(access(mask_ap//".fits")){
        mask_wv="Mask_"//wvfile
        if(access(mask_wv//".fits")) imdelete(mask_wv)
 
        refspectra(input=mask_ap,answer=yes,referen=wv_refer,sort="MJD", group=" ", answer=yes)
        dispcor(input=mask_ap,output=mask_wv, log-)
        imreplace(mask_wv, 0, imagina=0.,upper=zm_thresh, lower=INDEF, radius=0.)
        imreplace(mask_wv, 1, imagina=0.,upper=INDEF, lower=zm_thresh, radius=0.)
      }

      imarith(zminfile,"*", mask_wv, temp1)

      temp3=mktemp("tmp_mask")
      imarith(mask_wv,"*", zm_val, temp3)
      imarith(temp1,"-", temp3, temp2)
      imdelete(temp3)

      imarith(zminfile,"-", temp2, zmfile)
      imdelete(mask_ap)

    }
    imdelete(temp2)
    imdelete(temp1)

    hedit(zmfile,'H_MASK',mask_wv,add+,del-, ver-,show-,update+)
    hedit(zmfile,'HQ_ZM',"done",add+,del-, ver-,show-,update+)
    zm_done=yes
    nextin=zmfile
}
else{
     print("re-masking not processing")
     zm_done=no
}


# Heliocentric wavelength  (rvcorrect + rvhds)
if (rvcorrect){
printf("\n")
printf("##################################\n")
printf("# [12/13] Heliocentric Wavelength Correction\n")
printf("##################################\n")

   flag0=flag
   flag=flag+"r"	
   if(flag0==""){
      if(rv_in==""){
        rvinfile=input
      }
      else{
        rvinfile=rv_in
        output=rv_in
      }

      imgets(rvinfile,'HQ_WV')
      hq_tmp=imgets.value
      if(hq_tmp=="done"){
         wv_done=yes
         hq_tmp=""
      }
      else {
         printf("###### ERROR !! Input for RV correction must be Wavelength Calibrated !!\n")
	 bye
      }
   }
   else{
     if(!wv_done){
         printf("###### ERROR !! Input for RV correction must be Wavelength Calibrated !!\n")
	 bye
     }
     rvinfile=nextin
   }

   rvfile=output+flag

   if((access(rvfile))||access(rvfile//".fits")){
     printf("*** Heliocentric RV Corrected file \"%s\" already exsits!!\n",rvfile)
     if(overw){
        printf("*** Automatcally Rmoving \"%s\" ...\n",rvfile)
        imdelete(rvfile)
     }
     else{
       printf(">>> Do you want to overwrite this file? (y/n) : ")
       while(scan(d_ans)!=1) {}
       if(d_ans){
          imdelete(rvfile)
       }
       else{
          printf("!!! Please remove exsiting file !!! ABORT !!!\n")
          bye
       }
     }
   }

   rvhds(inimage=rvinfile,outimage=rvfile, observa=rvobs)
   hedit(rvfile,'HQ_RV',"done",add+,del-, ver-,show-,update+)
   rv_done=yes
   nextin=rvfile
   printf(">>> Heliocentric wavelength corrected \"%s\" has been created.\n", rvfile)
}
else{
     print("heliocentric wavelength correction not processing")
     rv_done=no
}
 


#
if (overscan){
  if (!os_save){
    imdel(images=osfile)
  }
}
if (biassub){
  if (!bs_save){
    imdel(images=bsfile)
  }
}
if (maskbad){
  if (!mb_save){
    imdel(images=mbfile)
  }
  if (mb_auto){
    imdel(images=masktemp)
  }
}
if (cosmicra){
  if (!cr_save){
    imdel(images=crfile)
  }
}
if (flat){
  if (!fl_save){
    imdel(images=flfile)
  }
}
if (scatter){
  if (!sc_save){
    imdel(images=scfile)
  }
}
if (apall){
  if (!ap_save){
    imdel(images=apfile)
  }
}
if (remask){
  if (!zm_save){
    imdel(images=zmfile)
  }
}
if (wavecal){
  if (!wv_save){
    imdel(images=wvfile)
  }
}

#### Make Result link file
if(!access("result")){
  mkdir("result")
}

if(access("result/H"//input_id//".fits")){
  imdelete("result/H"//input_id//".fits")
}
imcopy(nextin//".fits","result/H"//input_id//".fits")


if (getcnt && ap_done){
   temp1=mktemp("tmp_getcnt")
   temp2=mktemp("tmp_getcnt_c")
   temp3=mktemp("tmp_getcnt_cp")
#   scopy(nextin//"["//ge_stx//":"//ge_edx//","//sp_line//"]",temp1)
   scopy(nextin//"[*,"//sp_line//"]",temp1)
   continuum(temp1,temp2,bands=1,type="fit",functio="spline3",order=6,high_rej=ge_high,low_rej=ge_low,ask="no")
   scopy(temp2//"["//ge_stx//":"//ge_edx//"]",temp3)
   imstat(image=temp3, field='mean', format-) |scan(mean_cnt)
   imstat(image=temp3, field='max', format-) |scan(max_cnt)
   cnt_out="result/H"//input_id//"_cnt"
   cont_cnt=(max_cnt+mean_cnt)/2
   print(cont_cnt, > cnt_out)
   imdelete(temp1)
   imdelete(temp2)
   imdelete(temp3)
   printf("\n")
   printf("*** Continuum Count is %de- at order %d. ***\n",cont_cnt,sp_line)
   printf("\n")
}


#### Splot
if (splot && ap_done){
printf("\n")
printf("##################################\n")
printf("# [13/13] Plotting Resultant Spectrum\n")
printf("##################################\n")

      splot (images=nextin,line=sp_line,band=1)
}

printf("\n")
printf("##############################################################\n")
printf("# hdsql : FINISH\n")
printf("#   ver %s developped by W.Aoki and A.Tajitsu\n",version)
printf("#\n")
printf("#  Resultant File :   %s%s.fits\n",output,flag)
if ((zm_done)&&(mb_done)){
  printf("#       Mask File :   %s.fits\n",mask_wv)
}
printf("##############################################################\n")

#endofp:

if(batch){
  batch_i=batch_i+1
}
else{
  do_flag=no
  bye
}
}

bye
end
