##################################################################
# Subaru HDS : Making Bad Pixel Mask from BIAS & Flat
#  developed by Akito Tajitsu <tajitsu@naoj.org>
#              2020.10.09 ver.2.00
###################################################################
procedure mkbadmask(inimage,outimage)
#
file	inimage		{prompt= "Input BIAS image "}
bool    flatflag	{prompt= "Use Flat image? (y/n) "}
file	flatimage	{prompt= "Input Flat image "}
file	outimage	{prompt= "Output MASK image \n"}

real  lower=-100 {prompt="Lower limit replacement window "}
real  upper=300 {prompt="Upper limit replacement window "}
real  flower=10 {prompt="Lower limit replacement window for Flat \n"}

bool  clean=yes {prompt="Clean up by wacosm11 (y/n) "}
int  base=1 {prompt="Baseline for wacosm11 "}

#

begin
string 	inimg, flatimg, outimg
bool flatflg
string temp1, temp2, temp3, ftemp1, ftemp2, ftemp3, btemp, ftemp
real lw, up, flw

inimg=inimage
flatflg=flatflag
flatimg=flatimage
outimg=outimage

lw=lower
up=upper
flw=flower

temp1 = mktemp('tmp.mkbad.')
temp2 = mktemp('tmp.mkbad.')
btemp = mktemp('tmp.mkbad.')

imcopy(inimg, temp1)
imreplace(temp1, 0, imagina=0.,upper=up, lower=INDEF, radius=0.)
imreplace(temp1, 1, imagina=0.,upper=INDEF, lower=up, radius=0.)

imcopy(inimg, temp2)
imreplace(temp2, 6e5, imagina=0.,upper=INDEF, lower=lw, radius=0.)
imreplace(temp2, 1, imagina=0.,upper=lw, lower=INDEF, radius=0.)
imreplace(temp2, 0, imagina=0.,upper=INDEF, lower=599999, radius=0.)

if(clean){
  temp3 = mktemp('tmp.mkbad.')
  imarith(temp1, "+", temp2, temp3)

  wacosm11(temp3, btemp, base=base)
  imdelete(temp3)
}
else{
  imarith(temp1, "+", temp2, btemp)
}

imdelete(temp1)
imdelete(temp2)

if(flatflg){
  ftemp2 = mktemp('tmp.mkbad.')
  ftemp = mktemp('tmp.mkbad.')

  imcopy(flatimg, ftemp2)
  imreplace(ftemp2, 6e5, imagina=0.,upper=INDEF, lower=flw, radius=0.)
  imreplace(ftemp2, 1, imagina=0.,upper=flw, lower=INDEF, radius=0.)
  imreplace(ftemp2, 0, imagina=0.,upper=INDEF, lower=599999, radius=0.)

  if(clean){
    wacosm11(ftemp2, ftemp, base=base)
  }
  else{
    imcopy(ftemp2, ftemp)
  }

  imdelete(ftemp2)

  imarith(btemp, "+", ftemp, outimg)
  imreplace(outimg, 1, imagina=0.,upper=INDEF, lower=1, radius=0.)

  imdelete(ftemp)
}
else{
  imcopy(btemp, outimg)
}

imdelete(btemp)

printf(">>> Mask for fixpix \"%s\" has been created!\n",outimg)

bye
end
