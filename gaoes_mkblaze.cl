##################################################################
# gaoes_mkblaze : Seimei GAOES-RV Make Blaze Function
#  developed by Akito Tajitsu <akito.tajitsu@nao.ac.jp>
###################################################################
procedure gaoes_mkblaze(inec,outblz)
#
file	inec	{prompt= "Input Multi-Order Flat Spectrum"}
file	outblz   {prompt= "Output Blaze Function"}
file	mask   {prompt= "Mask Image"}
#

begin
string 	inimg, outimg
string suf_c, suf_b

inimg=inec
outimg=outblz

suf_b="_b"
suf_c="_c"

if(access(outimg//".fits")){ 
  imdelete(outimg)
}
if(access(inimg//suf_b//".fits")){ 
  imdelete(inimg//suf_b)
}
if(access(inimg//suf_b//suf_c//".fits")){ 
  imdelete(inimg//suf_b//suf_c)
}

sarith(inimg, "*", mask, inimg//suf_b)

continuum(inimg//suf_b,inimg//suf_b//suf_c,lines="*",bands=1,type="ratio",function="spline3",order=15,low_rej=2,high_rej=0,niterate=5,ask="YES")

sarith(inimg, "/", inimg//suf_c, outimg)
printf("### Create a new Blaze function : \"%s\" \n", outimg)

bye
end
