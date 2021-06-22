# Procedure to make 2D Echelle complete spectrum
#
# copyright : A.Tajitsu (2001/5/7)
#
procedure hdsls_apex(inimg,outimg)
 string inimg   {prompt= 'input image'}
 string outimg  {prompt= 'output image name header\n'}
 bool   overw=yes  {prompt = 'Overwrite exsiting images? <y/n>\n'}

 string ref_ap  {prompt= 'Aperture reference image'}
 string ref_ec  {prompt= 'Extracted image of Aperture reference'}
 int lower  {prompt= 'Lower aperture limit relative to center'}
 int upper  {prompt= 'Upper aperture limit relative to center\n'}

 bool   wavecal=yes  {prompt = 'Wavelength calibration? <y/n>'}
 string ref_wv  {prompt= 'Reference ThAr (2D) header (before \"_adXX\")'}
 string ref_wv1  {prompt= 'Ecidentified (1D) reference spectra\n'}

 bool   remask=yes {prompt = 'Re-Mask wavelength calibrated spectrum?<y/n>'}
 string   mskimg {prompt = 'Mask image used in 1st reduction\n'}

 bool   scomb=yes  {prompt = 'Scombine spectrum? <y/n>'}
 int   sc_low {prompt = 'Lower pixel along dispersion to be combined'}
 int   sc_up  {prompt = 'Upper pixel along dispersion to be combined\n### Blaze correction with scombine ###'}
 bool   blzcal=yes  {prompt = 'Blaze function calibration? <y/n>'}
 string blaze    {prompt= 'Multi-order Blaze function (ex mBlaze_Red)\n'}
 
 bool   rvcal=no  {prompt = 'Shift to Heliocentric wavelength? <y/n>'}
 string observa {prompt='Observatory\n'}

begin
#
# variables
#
string version ="2.00 (06-18-2021)"
string inimage, outimage, ref, refx, refw, blz, ext, sens, refw1
bool wvflag, rvflag, blzflag, fluxflag, extflag, combflag 
int low, upp
int i, i_ord, j
string tmp, comb_tmp,  otmp, otmp2, blz_tmp
string obs
real epo, heliov
string file_ext, mask_ext,  blz_ext
int slow, sup
bool rmskflag
string maskimg, temp1
int exptime
bool ow
string crval, cdelt


inimage  = inimg
outimage = outimg

ow=overw

ref      = ref_ap
refx     = ref_ec
low = lower
upp = upper

wvflag   = wavecal
refw     = ref_wv
refw1    = ref_wv1

rmskflag=remask
maskimg=mskimg

combflag   = scomb
slow     =sc_low
sup      =sc_up

rvflag   = rvcal
obs = observa

blzflag  = blzcal
blz      = blaze

#
# start
#

imgets(refx,'i_naxis2')
i_ord=int(imgets.value)

if(combflag){
  comb_tmp =mktemp('comb.tmp')
  if(blzflag){
    blz_tmp =mktemp('blz.tmp')
  }
}


for(i=1;i<=i_ord;i=i+1)
{
     printf("\n#################################\n")
     printf("########## Order %2d/%2d ##########\n",i,i_ord)
     printf("#################################\n")

     file_ext="_a"

     if(access(outimage//file_ext//i//'.fits')){
        if(ow){
	   imdelete(outimage//file_ext//i)
	}
	else{
           printf("!!! Cannot overwrite %s\n",outimage//file_ext//i//'.fits')
           printf("!!! ABORT !!!\n")
           bye
	}
     }

     apall(input=inimage,output=outimage//file_ext//i,\
      apertur=i,\
      format='multispec',reference=ref,profile=ref,nfind=2,\
      interac-,recente-,resize+,\
      edit-,trace-,fittrac-,extract+,extras-,review-,\
      b_funct='chebyshev',b_order=1,b_niter=3,\
      b_low_r=3,b_high_=3,b_sample='*',\
      width=30,radius=30,thresho=0,\
      ylevel=INDEF, peak-, avglimi-,\
      t_niter=3,t_low_r=3,t_high_=3,t_order=4,t_funct='legendre',\
      t_nsum=10,t_step=3,\
      find=no,llimit=low,ulimit=upp,\
      lower=low,upper=upp,\
      nsubaps=upp-low, pfit='fit1d', clean-, weights='none')

     imgets(outimage//file_ext//i,'APNUM1')
     tmp=imgets.value

### Overwrite Aperture Info
     for(j=2;j<(upp-low+1);j=j+1)
     {
         hedit(outimage//file_ext//i,"APNUM"//j,tmp,del-,add-,ver-,show-,update+)
     }

    if(wvflag){
      printf("##### wavelength calibration #####\n")
      refspectra(input=outimage//file_ext//i, referen=refw1,\
		apertur='',refaps='',ignorea-,select='interp',\
		sort='',group='',time-,timewra=17.,\
		override+,confirm-,assign+,verbose-,answer+)

      if(access(outimage//file_ext//'d'//i//'.fits')){
        if(ow){
	   imdelete(outimage//file_ext//'d'//i)
	}
	else{
           printf("!!! Cannot overwrite %s\n",outimage//file_ext//'d'//i//'.fits')
           printf("!!! ABORT !!!\n")
           bye
	}
      }
      
      dispcor(input=outimage//file_ext//i,output=outimage//file_ext//'d'//i,\
      	 	lineari+,table='',w1=INDEF,w2=INDEF,dw=INDEF,nw=INDEF,\
		log-,flux-,blank=0.,samedis-,global-,ignorea-,confirm-,\
		listonl-,verbose+)
      file_ext=file_ext//'d'

      hedit(outimage//file_ext//i,"CRPIX1",1,del+,add-,ver-,show-,update+)
      hedit(outimage//file_ext//i,"APNUM*",0,del+,add-,ver-,show-,update+)
      hedit(outimage//file_ext//i,"WAT*",0,del+,add-,ver-,show-,update+)
      hedit(outimage//file_ext//i,"BAND*",0,del+,add-,ver-,show-,update+)
      hedit(outimage//file_ext//i,"DISPAXIS",1,del-,add+,ver-,show-,update+)

      if(access(outimage//file_ext//'w'//i//'.fits')){
        if(ow){
	   imdelete(outimage//file_ext//'w'//i)
	}
	else{
           printf("!!! Cannot overwrite %s\n",outimage//file_ext//'w'//i//'.fits')
           printf("!!! ABORT !!!\n")
           bye
	}
     }

      transform(outimage//file_ext//i,outimage//file_ext//'w'//i,\
	 	fitname=refw//'_ad'//i,databas='database',\
		interpt='poly3',y1=INDEF,dy=INDEF,x1=INDEF,\
		y2=INDEF,ny=INDEF,\
		x2=INDEF,dx=INDEF,nx=INDEF,mode=mode )
      file_ext=file_ext//'w'

      imgets(outimage//file_ext//i,'CRVAL1')
      crval=imgets.value
      imgets(outimage//file_ext//i,'CDELT1')
      cdelt=imgets.value

      if(rmskflag){
        mask_ext="_a"

        if(access('MASK_'//outimage//mask_ext//i//'.fits')){
          if(ow){
  	   imdelete('MASK_'//outimage//mask_ext//i)
    	  }
	  else{
             printf("!!! Cannot overwrite %s\n",'MASK_'//outimage//mask_ext//i//'.fits')
             printf("!!! ABORT !!!\n")
             bye
	  }
        }
        apall(input=maskimg,output='MASK_'//outimage//mask_ext//i,\
        apertur=i,\
        format='multispec',reference=ref,profile=ref,nfind=2,\
        interac-,recente-,resize+,\
        edit-,trace-,fittrac-,extract+,extras-,review-,\
        b_funct='chebyshev',b_order=1,b_niter=3,\
        b_low_r=3,b_high_=3,b_sample='*',\
        width=30,radius=30,thresho=0,\
        ylevel=INDEF, peak-, avglimi-,\
        t_niter=3,t_low_r=3,t_high_=3,t_order=4,t_funct='legendre',\
        t_nsum=10,t_step=3,\
        find=no,llimit=low,ulimit=upp,\
        lower=low,upper=upp,\
        nsubaps=upp-low, pfit='fit1d', clean-, weights='none')

       imgets('MASK_'//outimage//mask_ext//i,'APNUM1')
       tmp=imgets.value

### Overwrite Aperture Info
       for(j=2;j<(upp-low+1);j=j+1)
       {
           hedit('MASK_'//outimage//mask_ext//i,"APNUM"//j,tmp,del-,add-,ver-,show-,update+)
       }


        refspectra(input='MASK_'//outimage//mask_ext//i, referen=refw1,\
		apertur='',refaps='',ignorea-,select='interp',\
		sort='',group='',time-,timewra=17.,\
		override+,confirm-,assign+,verbose-,answer+)

        if(access('MASK_'//outimage//mask_ext//'d'//i//'.fits')){
          if(ow){
  	   imdelete('MASK_'//outimage//mask_ext//'d'//i)
    	  }
	  else{
             printf("!!! Cannot overwrite %s\n",'MASK_'//outimage//mask_ext//'d'//i//'.fits')
             printf("!!! ABORT !!!\n")
             bye
	  }
        }
        dispcor(input='MASK_'//outimage//mask_ext//i,\
                output='MASK_'//outimage//mask_ext//'d'//i,\
      	 	lineari+,table='',w1=INDEF,w2=INDEF,dw=INDEF,nw=INDEF,\
		log-,flux-,blank=0.,samedis-,global-,ignorea-,confirm-,\
		listonl-,verbose+)
        mask_ext=mask_ext//'d'

        hedit('MASK_'//outimage//mask_ext//i,"CRPIX1",1,del+,add-,ver-,show-,update+)
        hedit('MASK_'//outimage//mask_ext//i,"APNUM*",0,del+,add-,ver-,show-,update+)
        hedit('MASK_'//outimage//mask_ext//i,"WAT*",0,del+,add-,ver-,show-,update+)
        hedit('MASK_'//outimage//mask_ext//i,"BAND*",0,del+,add-,ver-,show-,update+)
        hedit('MASK_'//outimage//mask_ext//i,"DISPAXIS",1,del-,add+,ver-,show-,update+)

        if(access('MASK_'//outimage//mask_ext//'w'//i//'.fits')){
          if(ow){
  	   imdelete('MASK_'//outimage//mask_ext//'w'//i)
    	  }
	  else{
             printf("!!! Cannot overwrite %s\n",'MASK_'//outimage//mask_ext//'w'//i//'.fits')
             printf("!!! ABORT !!!\n")
             bye
	  }
        }
        transform('MASK_'//outimage//mask_ext//i,'MASK_'//outimage//mask_ext//'w'//i,\
	 	fitname=refw//'_ad'//i,databas='database',\
		interpt='poly3',y1=INDEF,dy=INDEF,x1=INDEF,\
		y2=INDEF,ny=INDEF,\
		x2=INDEF,dx=INDEF,nx=INDEF,mode=mode )
        mask_ext=mask_ext//'w'

        imreplace('MASK_'//outimage//mask_ext//i, 0, imagina=0.,upper=0.1, lower=INDEF, radius=0.)
        imreplace('MASK_'//outimage//mask_ext//i, 1, imagina=0.,upper=INDEF, lower=0.1, radius=0.)

        temp1=mktemp("tmp_mask")
        imarith(outimage//mask_ext//i,"*", 'MASK_'//outimage//mask_ext//i, temp1)
        if(access(outimage//file_ext//'z'//i//'.fits')){
          if(ow){
  	    imdelete(outimage//file_ext//'z'//i)
  	  }
	  else{
             printf("!!! Cannot overwrite %s\n",outimage//file_ext//'z'//i//'.fits')
             printf("!!! ABORT !!!\n")
             bye
	  }
        }
        imarith(outimage//mask_ext//i,"-", temp1,\
               outimage//mask_ext//'z'//i)
        imdelete(temp1)
        file_ext=file_ext//"z"
      }

### BLAZE
      if(blzflag){
        blz_ext="_aw"
	
        if(access('BLZ_'//blz//blz_ext//i//'.fits')){
          if(ow){
  	   imdelete('BLZ_'//blz//blz_ext//i)
    	  }
	  else{
             printf("!!! Cannot overwrite %s\n",'BLZ_'//blz//blz_ext//i//'.fits')
             printf("!!! ABORT !!!\n")
             bye
	  }
        }
        scopy(blz//'[*,'//i//']', 'BLZ_'//blz//blz_ext//i)
        hedit('BLZ_'//blz//blz_ext//i,"CRVAL1",crval,del-,add-,ver-,show-,update+)
        hedit('BLZ_'//blz//blz_ext//i,"CDELT1",cdelt,del-,add-,ver-,show-,update+)
      }
    }

    if(combflag){
        printf("##### combine spextrum #####\n")
        print(outimage//file_ext//i//'['//sc_low//':'//sc_up//',*]',>>comb_tmp)
	if(blzflag){
           print('BLZ_'//blz//blz_ext//i//'['//sc_low//':'//sc_up//']',>>blz_tmp)
	}
    }
    else{
     if(rvflag){
       printf("##### radial velocity calibration #####\n")
       
       imgets(outimage//file_ext//i,"EQUINOX")
       epo=real(imgets.value)
       hedit(outimage//file_ext//i,'EPOCH',epo,add+,del-,ver-,show-,update+)

# This line replace 'OBSERVAT' form  "NAOJ" to "subaru".
#   "naoj" might be too ambiguous for obsdb.
       hedit(outimage//file_ext//i,'OBSERVAT',obs,add-,del-,ver-,show-,update+)

       rvcorrect(images=outimage//file_ext//i,header+,input+,imupdate+,\
                 observa=observa)

       imgets(outimage//file_ext//i,"VHELIO")
       heliov= real(imgets.value) * (-1.)
       printf("vhelio = %fkm/s\n",-heliov)
       if(access(outimage//file_ext//'r'//i//'.fits')){
         if(ow){
 	   imdelete(outimage//file_ext//'r'//i)
   	 }
         else{
           printf("!!! Cannot overwrite %s\n",outimage//file_ext//'r'//i//'.fits')
           printf("!!! ABORT !!!\n")
           bye
	 }
       }
       dopcor(outimage//file_ext//i, outimage//file_ext//'r'//i, \
                    heliov, isveloc+, add-, disp+, flux-)
       file_ext=file_ext//'r'
    }
  }
}

if(combflag){
    imgets(inimage,"EXPTIME")
    exptime=int(imgets.value)
    if(access(outimage//file_ext//'_sum.fits')){
       if(ow){
         imdelete(outimage//file_ext//'_sum')
       }
       else{
         printf("!!! Cannot overwrite %s\n",outimage//file_ext//'_sum.fits')
         printf("!!! ABORT !!!\n")
         bye
       }
    }
    scombine('@'//comb_tmp,outimage//file_ext//'_sum',\
	group='apertures', combine='sum', reject='none')
    del(comb_tmp)
    hedit(outimage//file_ext//'_sum','EXPTIME',exptime,add-,del-,ver-,show-,update+)
    file_ext=file_ext//'_sum'

    if(blzflag){
        printf("##### Creating a summed blaze function #####\n")
	
        if(access('BLZ_'//blz//blz_ext//'_sum.fits')){
          if(ow){
  	   imdelete('BLZ_'//blz//blz_ext//'_sum')
    	  }
	  else{
             printf("!!! Cannot overwrite %s\n",'BLZ_'//blz//blz_ext//'_sum.fits')
             printf("!!! ABORT !!!\n")
             bye
	  }
        }
        scombine('@'//blz_tmp,'BLZ_'//blz//blz_ext//'_sum',\
   	    group='all', combine='sum', reject='none')
        for(i=1;i<=i_ord;i=i+1){
	   imdelete('BLZ_'//blz//blz_ext//i)
	}
        del(blz_tmp)
#        imgets(outimage//file_ext,'CRVAL1')
#        crval=imgets.value
#        imgets(outimage//file_ext,'CDELT1')
#        cdelt=imgets.value
#        hedit('BLZ_'//blz//blz_ext//'_sum',"CRVAL1",crval,del-,add-,ver-,show-,update+)
#        hedit('BLZ_'//blz//blz_ext//'_sum',"CDELT1",cdelt,del-,add-,ver-,show-,update+)
	
        if(access(outimage//file_ext//'_fc.fits')){
          if(ow){
  	   imdelete(outimage//file_ext//'_fc')
    	  }
	  else{
             printf("!!! Cannot overwrite %s\n",outimage//file_ext//'_fc.fits')
             printf("!!! ABORT !!!\n")
             bye
	  }
        }
        printf("##### Deviding by blaze function #####\n")
        sarith(outimage//file_ext,'/','BLZ_'//blz//blz_ext//'_sum',outimage//file_ext//'_fc',\
		format='multispec', ignorea+)
        printf("Done.\n")

        file_ext=file_ext//'_fc'

     if(rvflag){
       printf("##### Radial velocity calibration to Heliocentric #####\n")
       
       imgets(outimage//file_ext,"EQUINOX")
       epo=real(imgets.value)
       hedit(outimage//file_ext,'EPOCH',epo,add+,del-,ver-,show-,update+)

# This line replace 'OBSERVAT' form  "NAOJ" to "subaru".
#   "naoj" might be too ambiguous for obsdb.
       hedit(outimage//file_ext,'OBSERVAT',obs,add-,del-,ver-,show-,update+)

       rvcorrect(images=outimage//file_ext,header+,input+,imupdate+,\
                 observa=observa)

       imgets(outimage//file_ext,"VHELIO")
       heliov= real(imgets.value) * (-1.)
       printf("vhelio = %fkm/s\n",-heliov)
       if(access(outimage//file_ext//'_rv.fits')){
         if(ow){
 	   imdelete(outimage//file_ext//'_rv')
   	 }
         else{
           printf("!!! Cannot overwrite %s\n",outimage//file_ext//'_rv.fits')
           printf("!!! ABORT !!!\n")
           bye
	 }
       }
       dopcor(outimage//file_ext, outimage//file_ext//'_rv', \
                    heliov, isveloc+, add-, disp+, flux-)
       file_ext=file_ext//'_rv'
    }
  }
  printf("\n")
  printf("##############################################################\n")
  printf("# hdsls_apex : FINISH\n")
  printf("#   ver %s developped by A.Tajitsu\n",version)
  printf("#\n")
  printf("#  Resultant File :   %s.fits\n",outimage//file_ext)
  printf("##############################################################\n")
}
else{
    printf("\n")
    printf("##############################################################\n")
    printf("# hdsls_apex : FINISH\n")
    printf("#   ver %s developped by A.Tajitsu\n",version)
    printf("#\n")
    printf("#  Resultant File :   %sXX.fits  (XX=ordernum)\n",outimage//file_ext)
    printf("##############################################################\n")
}

bye
end
