##################################################################
# Subaru HDS Bad Pixel Auto/Manual imreplace 
#  developed by Akito Tajitsu <tajitsu@subaru.naoj.org>
#              2011.09.30 ver.1.00
###################################################################
procedure hdsbadfix(inimage,outimage)
#
file	inimage		{prompt= "Input image "}
file	outimage	{prompt= "Output image \n"}

real	value=0	{prompt= "Replacement Pixel value\n"}

bool mask=yes {prompt="Use Mask? [y/n]"}
file	maskimage {prompt= "Mask image (blank for auto [using H_MASK])\n"}

bool manual=yes {prompt="Manual Cleaning? [y/n]"}
bool all=no {prompt="Attempt to all orders? [y/n]"}
bool cl_mask=no {prompt="Apply same Cleaning for Mask? [y/n]\n"}
bool new_mask=no {prompt="Create new Mask? [y/n]\n"}
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
real x,y
bool nomask, skip_flag
string createmask


inimg=inimage
outimg=outimage
mskimg=maskimage

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


if((!mask) && (!manual)){
  printf("!!! Skip Processing !!!\n")
  bye
}

## Get Header Information
    imgets(inimg,'i_naxis2')
    nord=int(imgets.value)
    imgets(inimg,'i_naxis1')
    npix=int(imgets.value)

    if(mask){
      if(mskimg==""){
        imgets(inimg,'H_MASK')
        mskimg=imgets.value


        if(mskimg=="0"){
          printf("### Cannot find MASK in the image header in \"%s\"\n",inimg)
          printf("### Processing without mask!\n")
          nomask=yes
#          goto NOMASK
        }
        else if(!access(mskimg//".fits")){
          printf("### Cannot access to the mask file \"%s\"\n",mskimg)
          printf("### Processing without mask!\n")
          nomask=yes
#          goto NOMASK
        }
	else{
          printf("### Automatically, Mask \"%s\" will be used...\n",mskimg)
          nomask=no
        }
      }
      else{
         nomask=no
      }

      if(!nomask){      
        imgets(mskimg,'i_naxis2')
        msk_nord=int(imgets.value)
        imgets(mskimg,'i_naxis1')
        msk_npix=int(imgets.value)

        msk_temp=mktemp("tmp.blaze_msk")
        if(msk_nord!=nord){
            printf("### Order Number is mismatched between Mask & Blaze!!\n")
            printf("### skipped!!!\n")
            bye
        }
        else{
           if(msk_npix==npix){
             imcopy(mskimg,msk_temp)
             msk1=1
             msk2=npix
           }
          else if (msk_npix>npix){
            printf("### Dimension mismatch between Mask and Blaze!!\n")
            printf("### Dimension of Blaze image X=%d.\n",npix)
            printf("### Dimension of Mask image X=%d.\n",msk_npix)

            printf(">>> Please input START X : ")
            while( scan( ans_num) == 0 )
            print(ans_num)
            msk1=ans_num

	    msk2=msk1+npix-1

            imcopy(mskimg//"["//msk1//":"//msk2//",*]",msk_temp)
          }
          else{
            printf("### X Dimension must be  X_Mask > X_Blaze!!\n")
            printf("### skipped!!!\n")
            bye
          }

          msk_temp1=mktemp("tmp.blaze_msk")
          msk_temp2=mktemp("tmp.blaze_msk")
      
          imarith(inimg,"*",msk_temp,msk_temp1)
          imarith(inimg,"-",msk_temp1,msk_temp2)
          imdelete(msk_temp1)

          imarith(msk_temp,"*",value,msk_temp1)
          imarith(msk_temp2,"+",msk_temp1,outimg)
	

          imdelete(msk_temp)
          imdelete(msk_temp1)
          imdelete(msk_temp2)
        }
      }
      else{
        imcopy(inimg, outimg)
      }
    }
    else{ 
#NOMASK:
      imcopy(inimg, outimg)
    }

if(new_mask){ 
  createmask="Mask_"//inimg
  if(!access(createmask//".fits")){
     imdelete(createmask)
  }
  sarith(inimg, "/", inimg, createmask)
}

if(manual){
for(i=1;i<=nord;i=i+1){
   if(mask){
     if(all){
       skip_flag=no
     }
     else{
       if((i>2) && (i<nord-1)){
         printf("*** Skipped Order%d/%d ...\n",i,nord)
         skip_flag=yes
       }
       else{
         skip_flag=no
       }
     }
    }
    else{
       skip_flag=no
    }

    if(!skip_flag){

    tempix = mktemp('tmp.hdsbadfix.')
    listpixels(outimg//"[1,"//i//"]",wcs='world', formats="%g  %g", ver-, mode=mode, > tempix)
    list=tempix
    while(fscan(list, ptmp1, ptmp2)!=EOF){}
    w1=real(ptmp1)
    delete(tempix)

    tempix = mktemp('tmp.hdsbadfix.')
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
	if(cl_mask){
          imreplace(mskimg//"["//i1+msk1-1//":"//i2+msk1-1//","//i//"]",value=1,lower=INDEF,upper=INDEF,radius=0)
        }
	if(new_mask){
          imreplace(createmask//"["//i1//":"//i2//","//i//"]",value=value,lower=INDEF,upper=INDEF,radius=0)
        }

        prow(outimg, row=i,wcs="logical")
        printf("\n>>> Do you want to correct this order MORE? (y/n) : ")
        while(scan(ans)!=1) {}
    }
  }
#SKIP:
}
}

printf("#####  Masked file : %s  has been created!\n",outimg)

#endofp:

bye
end
