##################################################################
# HST STIS make 1d image
#  Using stsdas/hst_calib/ctools
#              2019.07 ver.1.00
###################################################################
procedure stis_mk1d(inimage,outimage)
#
file	inimage		{prompt= "Input fits image "}
file	outimage	{prompt= "Output fits image \n"}

bool    trim=no    {prompt= "Trimming X-Pixel? (y/n)"}
int     st_x=6            {prompt= "Start pixel X to trim"}
int     ed_x=1015         {prompt= "End pixel X to trim"}
#
begin

string inimg, outimg
string mspectmp, trtmp, bftmp, maskimg

inimg=inimage
outimg=outimage

mspectmp = mktemp('tmp.stis_mk1d.mspec')
trtmp = mktemp('tmp.stis_mk1d.tr')
bftmp = mktemp('tmp.stis_mk1d.bf')
maskimg="Mask_"//trtmp

tomultispec(inimg//".fits", mspectmp//".imh")

if(trim){
  scopy(mspectmp//"["//st_x//":"//ed_x//",*]", trtmp)
}
else{
  scopy(mspectmp, trtmp)
}

hdsbadfix(trtmp, bftmp, value=0.,mask-,manual+,all+,cl_mask-,new_mask+)

scombine(bftmp, bftmp//"_sum", combine="sum", group="all")
scombine(maskimg, maskimg//"_sum", combine="sum", group="all")

if(access(outimg//".fits")){
   imdelete(outimg)
}

imarith(bftmp//"_sum", "/", maskimg//"_sum", outimg)


printf("Plotting \"%s\"...\n",outimg)
splot(outimg)

bye
end
