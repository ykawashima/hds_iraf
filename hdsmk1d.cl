##################################################################
# Subaru HDS Make 1D Flux calibrated Spectrum
#       from 1st reduce Echelle spectrum and Blaze Function (mkblaze-ed)
#  developed by Akito Tajitsu <tajitsu@subaru.naoj.org>
#              2013.07.13 ver.1.00
###################################################################
procedure hdsmk1d(inec,out1d,blaze)
#
file	inec	{prompt= "Input Multi-Order Spectrum"}
file	out1d   {prompt= "Output Flux Calibrated 1D Spectrum"}
file    blaze   {prompt= "(Modefied) Blaze Function\n"}

bool    trim=no    {prompt= "Trimming X-Pixel? (y/n)"}
int     st_x=1    {prompt= "Start X"}
int     ed_x=4096    {prompt= "End X\n"}

bool    adjexp=yes    {prompt= "Auto ExpTime Adjustment? (y/n)"}
#

begin
string 	inimg, outimg, blz, suf_b, suf_s, suf_t, adjtmp, vrtmp
bool  trm, aexp
int x1, x2
int expt, bexpt
real efact


inimg=inec
outimg=out1d
blz=blaze

trm=trim
x1=st_x
x2=ed_x

aexp=adjexp

suf_t="_t"
suf_b="_b"
suf_s="_sum"

if(access(inimg//suf_t//".fits")){ 
  imdelete(inimg//suf_t)
}
if(access(inimg//suf_t)){ 
  delete(inimg//suf_t)
}
if(access(blz//suf_t//".fits")){ 
  imdelete(blz//suf_t)
}
if(access(blz//suf_t)){ 
  delete(blz//suf_t)
}
if(trm){
  printf("##### X Trimming #####\n")
  scopy(inimg//"["//x1//":"//x2//",*]", inimg//suf_t)
  scopy(blz//"["//x1//":"//x2//",*]", blz//suf_t)
}
else{
  scopy(inimg, inimg//suf_t)
  scopy(blz, blz//suf_t)
}

printf("##### Removal Bad Pix #####\n")
if(access(inimg//suf_b//".fits")){ 
  imdelete(inimg//suf_b)
}
if(access(inimg//suf_b)){ 
  delete(inimg//suf_b)
}
hdsbadfix(inimg//suf_t, inimg//suf_b,manual+,mask+,cl_mask+,value=0)

if(access(blz//suf_b//".fits")){ 
  imdelete(blz//suf_b)
}
if(access(blz//suf_b)){ 
  delete(blz//suf_b)
}
hdsbadfix(blz//suf_t, blz//suf_b,manual-,mask+,cl_mask-,value=0)

printf("##### Scombine All Orders #####\n")
if(access(inimg//suf_b//suf_s//".fits")){ 
  imdelete(inimg//suf_b//suf_s)
}
if(access(inimg//suf_b//suf_s)){ 
  delete(inimg//suf_b//suf_s)
}
scombine(inimg//suf_b, inimg//suf_b//suf_s,combine="sum",
         group="images",reject="none")

if(access(blz//suf_b//suf_s//".fits")){ 
  imdelete(blz//suf_b//suf_s)
}
if(access(blz//suf_b//suf_s)){ 
  delete(blz//suf_b//suf_s)
}
scombine(blz//suf_b, blz//suf_b//suf_s,combine="sum",
         group="images",reject="none")


printf("##### Make Flux-Calibrated 1D Spectrum #####\n")
sarith(inimg//suf_b//suf_s,"/",blz//suf_b//suf_s,outimg)
#imarith(inimg//suf_b//suf_s,"/",blz//suf_b//suf_s,outimg)
imgets(inimg,'EXPTIME')
expt=int(imgets.value)

if(aexp){
  imgets(blz,'EXPTIME')
  bexpt=int(imgets.value)
  efact=real(expt)/real(bexpt)
  printf("##### Auto ExpTime Adjustment /(%d/%d)\n",expt,bexpt)
  adjtmp = mktemp('tmp.hdsmk1d.')
  imrename (outimg, adjtmp)
  sarith (adjtmp, '/', efact, outimg)
  imdelete (adjtmp)
}

hedit(outimg,"EXPTIME",expt,del-,add-,ver-,show+,update+)
printf("## Created : %s   ... done\n",outimg)

bye
end
