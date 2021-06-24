##################################################################
# Subaru HDS making corrected (better) blaze function 
#  developed by Akito Tajitsu <tajitsu@subaru.naoj.org>
#              2011.09.28 ver.1.10
#                  added ajustment scheme by scaling factor
#              2011.09.26 ver.1.00
###################################################################
procedure mkblaze(inimage,outimage)
#
file	inimage		{prompt= "Input image "}
file	outimage	{prompt= "Output image \n"}

bool mask {prompt="Use Mask? [y/n]"}
file	maskimage {prompt= "Mask image \n"}

#

begin
string 	inimg, outimg
int i, nord,j,num,npix
bool ans
int ans_num
real ans_real
string tmp0, tmp1, tmp2, tempix
int ord1[50], ord2[50]
bool ford[50]
int fsty[50]
real frac
string ptmp1, ptmp2
real w1, w2
int i_st, i_ed
real imin, imax, omin, omax
string mskimg, msk_temp, msk_temp1, msk_temp2
int msk_npix,msk_nord, msk1, msk2
bool nomask
int w_ha, w_hb, w_hg, w_hd, w_he, w_h28
int npix0

inimg=inimage
outimg=outimage
num=0;

mskimg=maskimage

w_ha=6563
w_hb=4861
w_hg=4340
w_hd=4101
w_he=3970
w_h28=3889

START:

for(i=1;i<=50;i=i+1){
	ford[i]=no
}
    
## Get Header Information

    imgets(inimg,'i_naxis2')
    nord=int(imgets.value)
    imgets(inimg,'i_naxis1')
    npix=int(imgets.value)
    npix0=npix-1

    if(access(outimg//'.fits')){
       printf(">>>> %s already exsists. Dow you want to remove it? <y/n> : ",\
              outimg//'.fits')
       while(scan(ans)!=1) {}
       if (!ans) {
          bye
       }
       imdelete(outimg//'.fits')
    }

    imstat(image=inimg, field='max', format-) | scan(imax)
    imstat(image=inimg, field='min', format-) | scan(imin)

    for(i=1;i<=nord;i=i+1){
          if(i==1){
    	    prow(inimg,row=i,wy1=imin,wy2=imax,app-,wcs="logical",pointmo-)
          }
          else{
  	    prow(inimg,row=i,wy1=imin,wy2=imax,app+,wcs="logical",pointmo-)
          }
    }

    printf("### These are current blaze functions for all orders.\n")
    printf(">>> OK to proceed? (y/n) : ")
    while(scan(ans)!=1) {}
    if (!ans) {
       bye
    }

    printf(">>> Do you want to change Y-MIN for plot? (y/n) : ")
    while(scan(ans)!=1) {}
    if (ans){
        printf(">>> Input Y-MIN for plot :  ")
        while( scan(ans_real) == 0 )
        print(ans_real)
        imin=real(ans_real)
    }

    printf(">>> Do you want to change Y-MAX for plot? (y/n) : ")
    while(scan(ans)!=1) {}
    if (ans){
        printf(">>> Input Y-MAX for plot :  ")
        while( scan(ans_real) == 0 )
        print(ans_real)
        imax=real(ans_real)
    }

    printf("\n**********************************\n")
    printf("***** [1/3] Order Selection  *****\n")
    printf("**********************************\n")


    for(i=1;i<=nord;i=i+1){
        for(j=1;j<i;j=j+1){
          if(j==1){
    	    prow(inimg,row=j,wy1=imin,wy2=imax,app-,wcs="logical",pointmo-)
          }
          else{
  	    prow(inimg,row=j,wy1=imin,wy2=imax,app+,wcs="logical",pointmo-)
          }
        }
 
       if(i==1){
          prow(inimg,row=i,wy1=imin,wy2=imax,app-,wcs="logical",pointmo+)
       }
       else{
          prow(inimg,row=i,wy1=imin,wy2=imax,app+,wcs="logical",pointmo+)
       }

       print( '    return : show all used orders' )
       =gcur

        for(j=i+1;j<=nord;j=j+1){
 	  prow(inimg,row=j,wy1=imin,wy2=imax,app+,wcs="logical",pointmo-)
        }

       tempix = mktemp('tmpix.mkblaze.')
       listpixels(inimg//"[1:2,"//i//"]",wcs='world', formats="%g  %g", ver-, mode=mode, > tempix)       
       list=tempix
       while(fscan(list, ptmp1, ptmp2)!=EOF){}
       w1=real(ptmp1)
       delete(tempix)
      
       tempix = mktemp('tmpix.mkblaze.')
       listpixels(inimg//"["//npix-1//":"//npix//","//i//"]",wcs='world', formats="%g  %g", ver-, mode=mode, > tempix)
       list=tempix
       while(fscan(list, ptmp1, ptmp2)!=EOF){}
       w2=real(ptmp1)
       delete(tempix)

	printf("=== Order%02d : Wavelength %d - %d\n",i,int(w1),int(w2))
	if((w1 < w_ha) && (w_ha < w2)){
	   print("#############################################################")
	   print("###!!!!!!!!! CAUTION!  This order includes H-alpha !!!!!!!###")
	   print("#############################################################")
	}
	else if((w1 < w_hb) && (w_hb < w2)){
	   print("############################################################")
	   print("###!!!!!!!!! CAUTION!  This order includes H-beta !!!!!!!###")
	   print("############################################################")
	}
	else if((w1 < w_hg) && (w_hg < w2)){
	   print("#############################################################")
	   print("###!!!!!!!!! CAUTION!  This order includes H-gamma !!!!!!!###")
	   print("#############################################################")
	}
	else if((w1 < w_hd) && (w_hd < w2)){
	   print("#############################################################")
	   print("###!!!!!!!!! CAUTION!  This order includes H-delta !!!!!!!###")
	   print("#############################################################")
	}
	else if((w1 < w_he) && (w_he < w2)){
	   print("###########################################################")
	   print("###!!!!!!!!! CAUTION!  This order includes H 2-7 !!!!!!!###")
	   print("###########################################################")
	}
	else if((w1 < w_h28) && (w_h28 < w2)){
	   print("###########################################################")
	   print("###!!!!!!!!! CAUTION!  This order includes H 2-8 !!!!!!!###")
	   print("###########################################################")
	}
	
	printf(">>> Do you want to use this order? (y/n) : ")
        while(scan(ans)!=1) {}
	if(ans){
	   ford[i]=yes
	   num=num+1
        }
        else{
	   ford[i]=no
        }
    }

REMAKEBLAZE:
for(i=1;i<=50;i=i+1){
	ord1[i]=0
	ord2[i]=0
	fsty[i]=-1
}

    if(num<2){
       printf("Number of useful orders must be > 2 .  Abort!!\n")
       bye
    }

    for(i=1;i<=nord;i=i+1){
        if(ford[i]){
            fsty[i]=0
        }
        else{
	    for(j=i-1;j>0;j=j-1){
	       if(ford[j]){
                  ord1[i]=j
                  goto JFIN1
               }
            }
JFIN1:
	    for(j=i+1;j<=nord;j=j+1){
	       if(ford[j]){
                  ord2[i]=j
                  goto JFIN2
               }
            }
JFIN2:
            if(ord1[i]==0){
               fsty[i]=2

               ord1[i]=ord2[i]
   	       for(j=ord1[i]+1;j<=nord;j=j+1){
	          if(ford[j]){
                     ord2[i]=j
                     goto JFIN3
                 }
               }
JFIN3:
            }
            else if (ord2[i]==0){
               fsty[i]=3

               ord2[i]=ord1[i]
   	       for(j=ord2[i]-1;j>0;j=j-1){
	          if(ford[j]){
                     ord1[i]=j
                     goto JFIN4
                 }
               }
JFIN4:
            }
            else{
               fsty[i]=1
            }
        }
	if(fsty[i]==0){
          printf(" Order%02d  :  ===== USE =====\n",i)
	}
	else{
          printf(" Order%02d  :  Style=%d  %02d  %02d\n",i,fsty[i],ord1[i],ord2[i])
	}
   }

    imcopy(inimg,outimg)

    for(i=1;i<=nord;i=i+1){
      tmp0 = mktemp('tmp0.mkblaze.')
      tmp1 = mktemp('tmp1.mkblaze.')
      tmp2 = mktemp('tmp2.mkblaze.')

      if(fsty[i]==1){
        frac=(real(i)-real(ord1[i]))/(real(ord2[i])-real(ord1[i]))
	imarith(inimg//"[*,"//ord1[i]//"]","*",frac,tmp1)
           
        frac=(real(ord2[i])-real(i))/(real(ord2[i])-real(ord1[i]))
	imarith(inimg//"[*,"//ord2[i]//"]","*",frac,tmp2)

        imarith(tmp1, "+", tmp2, tmp0)
        imcopy(tmp0,outimg//"[*,"//i//"]")

	imdelete(tmp0)
	imdelete(tmp1)
	imdelete(tmp2)
      }
      else if(fsty[i]==2){
	imarith(inimg//"[*,"//ord2[i]//"]","-",inimg//"[*,"//ord1[i]//"]",tmp1)

        frac=(real(ord1[i])-real(i))/(real(ord2[i])-real(ord1[i]))
	imarith(tmp1,"*",frac,tmp2)

	imarith(inimg//"[*,"//ord1[i]//"]","+",tmp2,tmp0)

        imcopy(tmp0,outimg//"[*,"//i//"]")

	imdelete(tmp0)
	imdelete(tmp1)
	imdelete(tmp2)
      }
      else if(fsty[i]==3){
	imarith(inimg//"[*,"//ord2[i]//"]","-",inimg//"[*,"//ord1[i]//"]",tmp1)

        frac=(real(i)-real(ord2[i]))/(real(ord2[i])-real(ord1[i]))
	imarith(tmp1,"*",frac,tmp2)

	imarith(inimg//"[*,"//ord2[i]//"]","+",tmp2,tmp0)

        imcopy(tmp0,outimg//"[*,"//i//"]")

	imdelete(tmp0)
	imdelete(tmp1)
	imdelete(tmp2)
      }
    } 


    for(i=1;i<=nord;i=i+1){
          if(i==1){
    	    prow(outimg,row=i,wy1=imin,wy2=imax,app-,wcs="logical",pointmo-)
          }
          else{
  	    prow(outimg,row=i,wy1=imin,wy2=imax,app+,wcs="logical",pointmo-)
          }
    }

    printf("\n")
    printf("USE    = ")
    for(i=1;i<=nord;i=i+1){
          if(ford[i]){
	    printf("%2d,",i)
           }
    }
    printf("\n")

    printf("NOT USE= ")
    for(i=1;i<=nord;i=i+1){
          if(!ford[i]){
	    printf("%2d,",i)
           }
    }
    printf("\n")
    printf("\n")
    

    printf("\n***********************************************************\n")
    printf("***** [2/3] Please select and check specified order.  *****\n")
    printf("***********************************************************\n")

     printf(">>> Input the Order Number  what you want to chek. [1-%d] (0 for quit) :  ",nord)
     while( scan( ans_num) == 0 ){}

     while((ans_num >=1) && (ans_num<=nord)){
         for(j=1;j<ans_num;j=j+1){
           if(j==1){
             prow(outimg,row=j,wy1=imin,wy2=imax,app-,wcs="logical",pointmo-)
           }
           else{
             prow(outimg,row=j,wy1=imin,wy2=imax,app+,wcs="logical",pointmo-)
           }
         }
 
         if(ans_num==1){
            prow(outimg,row=ans_num,wy1=imin,wy2=imax,app-,wcs="logical",pointmo+)
         }
         else{
            prow(outimg,row=ans_num,wy1=imin,wy2=imax,app+,wcs="logical",pointmo+)
         }

         for(j=ans_num+1;j<=nord;j=j+1){
            prow(outimg,row=j,wy1=imin,wy2=imax,app+,wcs="logical",pointmo-)
         }

         if(ford[ans_num]){
            printf("### This order (%d) is now USE.\n",ans_num)
            printf(">>> Do you want to use this order? [y/n] : ")
            while(scan(ans)!=1) {}
            if (!ans) {
               ford[ans_num]=no
               imdelete(outimg)
               num=num-1
               goto REMAKEBLAZE
            }
        } 
        else{
           printf("### This order (%d) is now NOT USE.\n",ans_num)
           printf(">>> Do you want to use this order? [y/n] : ")
           while(scan(ans)!=1) {}
           if (ans) {
              ford[ans_num]=yes
              imdelete(outimg)
              num=num+1
              goto REMAKEBLAZE
            }
         }

         printf(">>> Input the Order Number  what you want to chek. [1-%d] (0 for quit) :  ",nord)
         while( scan( ans_num) == 0 ){}
    }
    
    for(i=1;i<=nord;i=i+1){
          if(i==1){
    	    prow(outimg,row=i,wy1=imin,wy2=imax,app-,wcs="logical",pointmo-)
          }
          else{
  	    prow(outimg,row=i,wy1=imin,wy2=imax,app+,wcs="logical",pointmo-)
          }
    }

    printf("\n********************************************\n")
    printf("***** [3/3] Scaling Factor Adjustment  *****\n")
    printf("********************************************\n")
    printf(">>> Do you want to adjust created orders by scaling factors? (y/n) : ")
    while(scan(ans)!=1) {}
    if(ans){
       for(i=1;i<=nord;i=i+1){
         if(!ford[i]){
           i_st=i-2
	   if(i_st<1) i_st=1
           i_ed=i+2
	   if(i_ed>nord) i_ed=nord

	   imstat(image=outimg//"[*,"//i_st//":"//i_ed//"]", field='max', format-) | scan(imax)
	   imstat(image=outimg//"[*,"//i_st//":"//i_ed//"]", field='min', format-) | scan(imin)

           prow(outimg,row=i_st,wy1=imin,wy2=imax,app-,wcs="logical",pointmo-)

           for(j=i_st+1;j<=i_ed;j=j+1){
   	       prow(outimg,row=j,wy1=imin,wy2=imax,app+,wcs="logical",pointmo-)
           }
           print( '>>>  hit return : show the original blaze' )
           =gcur

  	  prow(inimg,row=i,wy1=imin,wy2=imax,app+,wcs="logical",pointmo+)

           print( '>>>  hit return : calculate the ratio of new/original blaze' )
           =gcur

           tmp0 = mktemp('tmp0.mkblaze.')
           tmp1 = mktemp('tmp1.mkblaze.')
           printf(">>> Plotting Order %d  : new/original...\n",i)
           sarith(outimg//"[*,"//i//"]","/",inimg//"[*,"//i//"]",tmp0)
	   splot(tmp0,line=1,band=1)

           printf(">>> Input scaling factor for order %d:  ",i)
           while( scan(ans_real) == 0 ) {}
           print(ans_real)
           imarith(outimg//"[*,"//i//"]","/",real(ans_real),tmp1)
	   
           imcopy(tmp1,outimg//"[*,"//i//"]")

           imdelete(tmp0)
           imdelete(tmp1)
         }
       }
    }

    imstat(image=outimg, field='max', format-) | scan(imax)
    imstat(image=outimg, field='min', format-) | scan(imin)

    if(mask){
      if(mskimg==""){
        imgets(inimg,'H_MASK')
        mskimg=imgets.value

        if(mskimg=="0"){
          printf("### Cannot find MASK in the image header in \"%s\"\n",inimg)
          printf("### Processing without mask!\n")
          nomask=yes
        }
        else if(!access(mskimg//".fits")){
          printf("### Cannot access to the mask file \"%s\"\n",mskimg)
          printf("### Processing without mask!\n")
          nomask=yes
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
           if(msk_nord==npix){
             imcopy(mskimg,msk_temp)
           }
          else if (msk_npix>npix){
            printf("### Dimension mismatch between Mask and Blaze!!\n")
            printf("### Dimension of Blaze image X=%d.\n",npix)
            printf("### Dimension of Mask image X=%d.\n",msk_npix)

            printf(">>> Please input START X : ")
            while( scan( ans_num) == 0 ) {}
            print(ans_num)
            msk1=ans_num

            msk2=msk1+npix-1

            imcopy(mskimg//"["//msk1//":"//msk2//",*]",msk_temp)
          }
          else{
            printf("### X Dimension must be  X_Mask > X_Blaze!!\n")
            printf("### skipped!!!\n")
            goto endofp
          }

          msk_temp1=mktemp("tmp.blaze_msk")
          msk_temp2=mktemp("tmp.blaze_msk")
      
          imarith(outimg,"*",msk_temp,msk_temp1)
          imarith(outimg,"-",msk_temp1,msk_temp2)
          imdelete(outimg)
          imarith(msk_temp2,"+",msk_temp,outimg)
          imreplace(outimg, 1, imagina=0.,upper=1, lower=INDEF, radius=0.)

          imdelete(msk_temp)
          imdelete(msk_temp1)
          imdelete(msk_temp2)
        }
      }
    }

    for(i=1;i<=nord;i=i+1){
          if(i==1){
    	    prow(outimg,row=i,wy1=imin,wy2=imax,app-,wcs="logical",pointmo-)
          }
          else{
  	    prow(outimg,row=i,wy1=imin,wy2=imax,app+,wcs="logical",pointmo-)
          }
    }

    printf(">>> These are corrected blaze functions.\n")
#    printf(">>> Do you want to retry? (y/n) : ")
#    while(scan(ans)!=1) {}
#    if (ans) {
#       imdelete(outimg)
#       goto START
#    }

endofp:

    printf("\n*** Plotting the modified Blaze function ***\n")
    for(i=1;i<=nord;i=i+1){
          if(i==1){
    	    prow(outimg,row=i,wy1=imin,wy2=imax,app-,wcs="logical",pointmo-)
          }
          else{
  	    prow(outimg,row=i,wy1=imin,wy2=imax,app+,wcs="logical",pointmo-)
          }
    }
    printf("\n")

    printf("\n****************************************************\n")
    printf("****************************************************\n")
    printf("***** FINISH :  mkblaze.cl  by A.Tajitsu 2011  *****\n")
    printf("****************************************************\n")
    printf("****************************************************\n")

bye
end
