##################################################################
# Scopy -> Continuum Fit -> XY_out
#  developed by Akito Tajitsu <tajitsu@subaru.naoj.org>
#              2013.11.06 ver.1.00
###################################################################
procedure vcfitxy(inimage,outxy)
#
file	inimage		{prompt= "Input image "}
file	outxy   	{prompt= "Output XY aschii file"}

string  otype="vpfit"  {prompt="Output type",enum="vpfit|specfit|vel"}
bool    cfit=yes       {prompt= "Continuum Fit? [yes/no]"}
bool    save_c=yes     {prompt= "Save Normalized Fits? [yes/no]"}
bool    save_p=yes     {prompt= "Save Profile Fits? [yes/no]"}
bool    save_t=no      {prompt= "Save Trimmed Fits? [yes/no]"}
bool    save_e=no      {prompt= "Save Emission Fits? [yes/no]"}
real    v_min          {prompt= "Minimum velocity [km/s]"}
real    v_max          {prompt= "Maximum velocity [km/s]"}
int     order=15       {prompt= "Order of fitting function"}
#

begin
string 	inimg, outimg
real  	wv0, vmax, vmin
real 	wmin, wmax, c, wv, count, vel
string 	tmp0, tmp1, tmp2
string 	stmp1, stmp2, stmp3, stmp4, stmp5, stmp6
string 	outfits
real   	ans_num
bool 	ans_ok
string 	templog
real   	rms,ave
real 	onda, vacuum, n, sigma, sigma2
int 	pixnum
string proffits

inimg=inimage
outimg=outxy
vmax=v_max
vmin=v_min

c=3e5
ans_ok=yes

printf(" ######## Sample lines table #######\n")
printf(" ### H I\n")
printf("   a 6562.819,  b 4861.333,  g 4340.471,  d 4101.7415\n")
printf("   e 3970.0788, 2-8 3889.0556, 2-9 3835.3909, 2-10 3797.9043\n")
printf(" ### He I\n")
printf("   7281.351, 7065.217, 6678.152, 5875.621, 5047.739\n")
printf("   5015.678, 4921.931, 4713.146, 4471.480, 4120.815\n")
printf("   4026.191, 3888.648, 3819.607, 3187.745\n")
printf(" ### He II\n")
printf("   4685.71 , 3203.10\n")
printf(" ### Li I\n")
printf("   6707.912, 6707.761, 3232.6306\n")
printf(" ### Be II\n")
printf("   3131.065, 3130.420\n")
printf(" ### \n")
printf(">>> Please input Wavelength to be centered [A] : ")
while( scan( ans_num) == 0 )
print(ans_num)
wv0=ans_num

wmin=vmin/c*wv0+wv0
wmax=vmax/c*wv0+wv0

tmp0=mktemp("tmp.vcfitxy")
scopy(inimg,tmp0,w1=wmin,w2=wmax)

tmp1=mktemp("tmp.vcfitxy")
if(cfit){
  printf("### Continuum fit\n")
CFIT:
  continuum(tmp0,tmp1,type="ratio", order=order, ask="YES")
#  prow (tmp1,1)
  splot (tmp1,1)
  printf(">>> Plotting Fitting Result. Accept it? [yes/no] : ")
  while( scan(ans_ok) == 0 )
  print(ans_ok)
  if(!ans_ok){
    imdelete(tmp1)
    goto CFIT
  }
}
else{
  printf("### Skipping Continuum fit\n")
  scopy(tmp0,tmp1)  
}



tmp2=mktemp("tmp.vcfitxy")
listpix(tmp1,wcs="world",>>tmp2)

if(access(outimg)) delete(outimg)

imgets(tmp1,'i_naxis1')
pixnum=int(imgets.value)

if(otype!="vel"){
  templog=mktemp("splot.tmp")
  printf("### Plotting spectrum.\n")
  printf(">>> Measure rms noise with \'m\' and \'m\', then hit \'q\'.\n")
  splot(tmp1, save_file=templog)

  list=templog
  while(fscan(list, stmp1, stmp2, stmp3, stmp4, stmp5, stmp6)!=EOF){}
  rms=real(stmp4)
  delete(templog)
}

if(otype=="specfit"){
  imgets(tmp1,'i_title')
  stmp1 = imgets.value
  imgets(tmp1,'EXPTIME')
  stmp2 = imgets.value
  print("### "//stmp1//"  line at "//wv0//"A",>outimg)
  print(pixnum, stmp2, >>outimg)
}

list=tmp2
while(fscan(list,wv,count)==2){
  if(otype=="vpfit"){
# Wavelength conversion air --> vac
# from
# http://www.sdss.org/dr7/products/spectra/phist.html
# wcalc.cl
    {
      onda = wv
      sigma2 = (10**8.)/wv**2.
      n = 1 + 0.000064328 + 0.0294981/(146.-sigma2.) + 0.0002554/(41.-sigma2.)
      vacuum = wv * n
    }
    print(vacuum, count, rms, >>outimg)
  }
  else if(otype=="specfit"){
    print(wv, count, rms, >>outimg)
  }
  else{
    vel=(wv-wv0)/wv0*c
    print(vel, count, wv, >>outimg)
  }
}

if(save_t){
  outfits=inimg//"_trim_"//int(wv0)
  if(access(outfits) || access(outfits//".fits")) imdelete(outfits)
  scopy(tmp0,outfits)
  printf("Trimmed fits : %s\n",outfits)
}
else{
  printf("Trimmed fits : (skipped)\n")
}

if(save_p){
  outfits=inimg//"_prof_"//int(wv0)
  if(access(outfits) || access(outfits//".fits")) imdelete(outfits)
  sarith(tmp0,"/",tmp1,outfits)
  printf("Profile fits : %s\n",outfits)

  if(save_e){
    templog=mktemp("splot.tmp")
    printf("### Plotting Profile spectrum.\n")
    printf(">>> Measure Continuum Level with \'m\' and \'m\', then hit \'q\'.\n")
    splot(outfits, save_file=templog)

    list=templog
    while(fscan(list, stmp1, stmp2, stmp3, stmp4, stmp5, stmp6)!=EOF){}
    ave=real(stmp2)
    delete(templog)

    proffits=outfits

    outfits=inimg//"_emit_"//int(wv0)
    if(access(outfits) || access(outfits//".fits")) imdelete(outfits)
    sarith(proffits,"-",ave,outfits)
     printf("Emission Profile fits : %s\n",outfits)
  }
  else{
    printf("Emission Profile fits : (skipped)\n")
  }
}
else{
  printf("Profile fits : (skipped)\n")
}



if(save_c){
  outfits=inimg//"_cfit_"//int(wv0)
  if(access(outfits) || access(outfits//".fits")) imdelete(outfits)
  imrename(tmp1, outfits)
  printf("C-fitted fits : %s\n",outfits)
}
else{
  printf("C-fitted fits : (skipped)\n")
  imdelete(tmp1)
}
imdelete(tmp0)
delete(tmp2)

if(otype=="vpfit"){
  printf("!!! CAUTION : Output is converted to VACUUM wavelength for vpfit !!!\n\n")
}


bye
end
