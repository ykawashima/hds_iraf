##################################################################
# Subaru HDS Combined Spectrum from Object & Blaze
#  developed by Akito Tajitsu <tajitsu@subaru.naoj.org>
#              2011.10.17 ver.1.00
###################################################################
procedure hdsmkcombine(inimage,blaze,outimage)
#
file	inimage		{prompt= "Input multi-order spectrum"}
file	blaze		{prompt= "Input multi-order blaze function "}
file	outimage	{prompt= "Output combined spectrum \n"}

#

begin
string 	inimg, outimg, blz
string       tmp_sum, tmp_blz

inimg=inimage
blz=blaze
outimg=outimage

tmp_sum=mktemp("tmp.combine.obj")
tmp_blz=mktemp("tmp.combine.blz")

scombine(inimg, tmp_sum,combine="sum",group="images")	
scombine(blz, tmp_blz,combine="sum",group="images")	
sarith(tmp_sum, "/", tmp_blz, outimg)

imdelete(tmp_sum)
imdelete(tmp_blz)

printf("#####  Combined file : %s  has been created!\n",outimg)

endofp:

bye
end
