##################################################################
# gaoes_mkblaze : Seimei GAOES-RV Make Blaze Function
#  developed by Akito Tajitsu <akito.tajitsu@nao.ac.jp>
#              2023.05.09 ver.0.10
###################################################################
procedure gaoes_mkblaze(inec,outblz)
#
file	inec	{prompt= "Input Multi-Order Flat Spectrum"}
file	outblz   {prompt= "Output Blaze Function"}
file	mask   {prompt= "Mask Image\n"}

int order=90 {prompt= "Order of fitting function"}
int niterate=0 {prompt= "Number of rejection iterations"}
bool	interact=yes   {prompt= "Interactive fit? (y/n) "}
string  sample="5140:5157,5159.5:5784.5,5787.5:5935.2,5938:5955" {prompt= "Sample point to use in fit"}
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

continuum(inimg//suf_b,inimg//suf_b//suf_c,lines="*",bands=1,type="ratio",function="spline3",order=order,low_rej=2,high_rej=0,niterate=niterate,interact=interact,sample=sample,ask="YES")

sarith(inimg//suf_b, "/", inimg//suf_b//suf_c, outimg)
printf("### Create a new Blaze function : \"%s\" \n", outimg)

bye
end
