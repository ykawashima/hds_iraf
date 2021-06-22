##################################################################
# Subaru HDS CCD Amp Cross-Talk Subtraction 
#  developed by Akito Tajitsu <tajitsu@subaru.naoj.org>
#              2013.04.18 ver.1.00
###################################################################
procedure hdssubx(inimage,outimage)
#
file	inimage	{prompt= "Input image "}
file	outimage	{prompt= "Output image \n"}

real	amp=0.0012   {prompt= "Amplitude of Cross-Talk\n"}
bool disp=no {prompt="Confirm w/Display (DS9)? [y/n]"}
real  z1=-100 {prompt="Minimum greylevel to be displayed"}
real  z2=30000 {prompt="Maximum greylevel to be displayed"}
#

begin
string 	inimg, outimg
string xt_tmp1, xt_tmp2
real xamp
bool ans, ans_next
real ans_real


inimg=inimage
outimg=outimage
xamp=amp
ans=no

if(disp){
   display(inimg,1,zr-,zs-,ztrans="log",z1=z1,z2=z2)
}
xt_tmp1=mktemp("tmp_xt")
print("flipping ",inimg, " ...")
imcopy(inimg//"[-*,*]",xt_tmp1)
xt_tmp2=mktemp("tmp_xt")

START:
print(xt_tmp1," * ",xamp," => ",xt_tmp2) 
imarith(xt_tmp1,"*", xamp, xt_tmp2, pixtype="real")
print(inimg," - ", xt_tmp2," => ",outimg) 
imarith(inimg,"-",xt_tmp2,outimg)
if(disp){
   display(outimg,2,zr-,zs-,ztrans="log",z1=z1,z2=z2)
   printf(">>> Subtraction OK? (y/n) : ") 
   while(scan(ans)!=1) {}
   if(!ans){
      printf(">>> Input New Amplitude (%f) : ",xamp) 
      while( scan(ans_real) == 0 )
      print(ans_real)
      xamp=real(ans_real)
      imdelete(xt_tmp2)
      imdelete(outimg)
      goto START
   }
}
imdelete(xt_tmp1)
imdelete(xt_tmp2)


bye
end
