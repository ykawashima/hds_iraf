##################################################################
# Subaru HDS Bad Pixel Auto/Manual imreplace 
#  developed by Akito Tajitsu <tajitsu@subaru.naoj.org>
#              2011.09.30 ver.1.00
###################################################################
procedure gaoes_mkmask(inimage, mask)
#
file	inimage		{prompt= "Input Flat image "}
file	mask	{prompt= "New Mask image \n"}

#

begin
string 	inimg, outimg
int i, nord, npix
bool ans
int i1, i2, ans_num
string tempix, ptmp1, ptmp2
real w1, w2
string mskimg, msk_temp, msk_temp1, msk_temp2
int msk_npix,msk_nord, msk1, msk2
real x,y, value
bool nomask, skip_flag
string createmask

value=0
inimg=inimage
outimg=inimage//"_t"

if(access(outimg//'.fits')){
   printf("!!! File %s already exists !!!\n", outimg//'.fits')
   printf(">>> Do you want to remove it? <y/n> : ")
   while(scan(ans)!=1) {}
   if (ans) {
      imdelete(outimg)
   }
   else{
      printf("!!! Cannot overwrite %s\n",outimg//'.fits')
      printf("!!! ABORT !!!\n")
      bye
   }
}


## Get Header Information
    imgets(inimg,'i_naxis2')
    nord=int(imgets.value)
    imgets(inimg,'i_naxis1')
    npix=int(imgets.value)

    imcopy(inimg, outimg)

createmask=mask
if(!access(createmask//".fits")){
   imdelete(createmask)
}
sarith(inimg, "/", inimg, createmask)

for(i=1;i<=nord;i=i+1){
    skip_flag=no

    if(!skip_flag){

    tempix = mktemp('tmp.gaoes.')
    listpixels(outimg//"[1,"//i//"]",wcs='world', formats="%g  %g", ver-, mode=mode, > tempix)
    list=tempix
    while(fscan(list, ptmp1, ptmp2)!=EOF){}
    w1=real(ptmp1)
    delete(tempix)

    tempix = mktemp('tmp.gaoes.')
    listpixels(outimg//"["//npix//","//i//"]",wcs='world', formats="%g  %g", ver-, mode=mode, > tempix)
    list=tempix
    while(fscan(list, ptmp1, ptmp2)!=EOF){}
    w2=real(ptmp1)
    delete(tempix)


    prow(outimg, row=i,wcs="logical")

    printf("*** Order%d/%d : %.2f-%.2f\n",i,nord,w1,w2)
    printf(">>> Do you want to correct this order? (y/n) : ")
    while(scan(ans)!=1) {}
    while (ans){
      prow(outimg, row=i,wcs="logical")
      printf("\n>>> Move Cursor to the START point to be cut!\n")
      printf(">>> then, HIT ANY KEY!!\n")
      = fscan (gcur, x,y)

        ans_num=int(x)
        if(ans_num<1){
        i1=1
	}
	else{
	  i1=ans_num
        }
    
      printf("\n>>> Move Cursor to the END point to be cut!\n")
      printf(">>> then, HIT ANY KEY!!\n")
      = fscan (gcur, x,y)

        ans_num=int(x)
	if(ans_num>npix){
	  i2=npix
	}
	else{
	  i2=ans_num
        }

        imreplace(outimg//"["//i1//":"//i2//","//i//"]",value=value,lower=INDEF,upper=INDEF,radius=0)
        imreplace(createmask//"["//i1//":"//i2//","//i//"]",value=value,lower=INDEF,upper=INDEF,radius=0)

        prow(outimg, row=i,wcs="logical")
        printf("\n>>> Do you want to correct this order MORE? (y/n) : ")
        while(scan(ans)!=1) {}
    }
  }
#SKIP:
}

printf("#####  Masked file : %s  has been created!\n",outimg)

#endofp:

bye
end
