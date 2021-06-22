# Procedure for correcting the misalignment between grating and ccd
#
# copyright : A.Tajitsu (2001/5/7)
#
procedure hdsls_apex(inimg,outimg)
 string inimg   {prompt= "input image"}
 string outimg  {prompt= "output image"}

 string referen {prompt= "Aperture reference image"}
 string refex   {prompt= "Extracted image of Aperture reference"}

 int lower  {prompt= "Lower aperture limit relative to center"}
 int upper  {prompt= "Upper aperture limit relative to center"}


begin
#
# variables
#
string inimage, outimage, ref, refx
int low, upp
int i, i_ord

inimage  = inimg
outimage = outimg
ref      = referen
refx     = refex

low = lower
upp = upper

imgets(refx,'i_naxis2')
i_ord=int(imgets.value)


for(i=1;i<i_ord;i=i+1)
{
     apall(input=inimage,output=outimage//'_ec'//i,\
      apertur=i,\
      format='multispec',reference=ref,profile='',nfind=1,\
      interac-,recente-,resize-,\
      edit-,trace-,fittrac-,extract+,extras-,review-,\
      b_funct='chebyshev',b_order=1,b_niter=3,\
      b_low_r=3,b_high_=3,b_sample='*',\
      width=30,radius=30,thresho=0,\
      peak+,avglimi+,\
      t_niter=3,t_low_r=3,t_high_=3,t_order=4,t_funct='legendre',\
      t_nsum=10,t_step=3,\
      find=yes,llimit=low,ulimit=upp,\
      lower=low,upper=upp,\
      nsubaps=upp-low)
}

bye
end
