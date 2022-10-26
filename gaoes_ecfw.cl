# Procedure for Extracting / Flatfielding / Wavelength calibration
#   Use only apnormalized flat
#
# copyright : A.Tajitsu (2022/10/24)
# !!!  It's important to use apall with                      !!!
# !!!          "llimit=(pix) ulimit=(pix+1) ylebel=INDEF"    !!!
# !!!    to extract 1-pixel along a reference aperture.      !!!
#
procedure gaoes_ecfw(inimg,outimg)
file inimg   {prompt= "input image"}
file outimg  {prompt= "output image\n"}

string ref_ap {prompt= "Aperture reference image"}
string flatimg {prompt= "ApNormalized flat image"}
real   threshold=0.05 {prompt= "Threshold flat level to combine\n"}

string thar1d  {prompt= "1D wavelength-calibrated ThAr image"}
string thar2d  {prompt= "2D ThAr image\n"}

int st_x=-54  {prompt ="Start pixel to extract"}
int ed_x=53  {prompt ="End pixel to extract\n"}

bool ow_flat=no {prompt ="Overwrite existing sliced flat (yes/no)\n"}
bool ow_thar=no {prompt ="Overwrite existing sliced ThAr (yes/no)\n"}
bool clean=no {prompt ="Clean up intermediate images (yes/no)\n"}

begin
#
# variables
#
string inimage, outimage, flat, ref, thar, thar1
int i, ysize, low, upp, i_ord,  i_st
real fmean[200]
string file_ext, ex_flt, ex_thar, ref_c, thar_ec, ex_img
string tempspec1, templist, img_ec, flt_ec, img_ecf, img_ecfw
bool d_ans, flag_go
real th_f, exptime
#
#
#
inimage = inimg
outimage = outimg

flat = flatimg
ref  = ref_ap
th_f=threshold

thar2 = thar2d
thar1 = thar1d

low = st_x
upp = ed_x


#
# start
#

if((access(outimage))||access(outimage//".fits")){
       printf("*** Output file \"%s\" already exsits!!\n",outimage)
       printf(">>> Do you want to overwrite this file? (y/n) : ")
       while(scan(d_ans)!=1) {}
       if(d_ans){
          imdelete(outimage)
       }
       else{
          printf("!!! Please remove exsiting file !!! ABORT !!!\n")
          bye
       }
}


imgets(inimage,'i_naxis2')
ysize=int(imgets.value)

printf("########## Slicing Flat : %s %d -> %d ##########\n",flat, low, upp)

ex_flt=flat

for(i=low;i<upp;i=i+1)
{
     file_ext="_ec"

     if(access(ex_flt//file_ext//i//".fits"))
     {
        if(ow_flat){
	  flag_go=yes
          imdelete(ex_flt//file_ext//i)
	}
	else{
	  flag_go=no
	}
     }
     else{
       flag_go=yes
     }

     if(flag_go){
       apall(input=ex_flt,output=ex_flt//file_ext//i,\
        apertur="",\
        format='echelle',reference=ref,profile="",\
        interac-,find-,recente-,resize+,\
        edit-,trace-,fittrac-,extract+,extras-,review-,\
        llimit=i,ulimit=i+1,\
        nsubaps=1, pfit='fit1d', clean-, weights='none',ylevel=INDEF)
     }
     
     imgets(ex_flt//file_ext//i,'i_naxis2')
     i_ord=int(imgets.value)

     imstat(image=ex_flt//file_ext//i//"[*,:"//i_ord-1//"]", \
        field='mean', format-,\
        lsigma=3.,usigma=3.,nclip=5,binwidt=0.1) | scan(fmean[i-low+1])

     if(fmean[i-low+1]<th_f){
       printf(" Pixel = %2d, Mean = %f  -->  Skip this aperture!!\n", i, fmean[i-low+1])
       fmean[i-low+1]=0.
     }
     else{
       printf(" Pixel = %2d, Mean = %f\n", i, fmean[i-low+1])
     }

}


ex_thar=thar2d

printf("\n\n########## Slicing ThAr : %s %d -> %d ##########\n",thar2d, low, upp)
for(i=low;i<upp;i=i+1){
  printf("*")
}
printf("\n")

for(i=low;i<upp;i=i+1)
{
     file_ext="_ec"

     thar_ec=ex_thar//file_ext//i
     if(access(thar_ec//".fits"))
     {
        if(ow_thar){
	  flag_go=yes
          imdelete(thar_ec)
	}
	else{
	  flag_go=no
	}
     }
     else{
       flag_go=yes
     }

     if(flag_go){
       apall(input=ex_thar,output=thar_ec,\
        apertur="",\
        format='echelle',reference=ref,profile="",\
        interac-,find-,recente-,resize+,\
        edit-,trace-,fittrac-,extract+,extras-,review-,\
        llimit=i,ulimit=i+1,\
        nsubaps=1, pfit='fit1d', clean-, weights='none',ylevel=INDEF)
        printf("o")
     }
     else{
        printf("s")
     }
}
printf("\n\n")


ref_c=thar1

if(upp<0){
  i_st=upp-1
}
else{
  i_st=-1
}

if(low<0){
  printf("\n\n########## EcReidetifying ThAr : -1 -> %d ##########\n",low)
  for(i=i_st;i>low-1;i=i-1)
  {
     file_ext="_ec"

     thar_ec=ex_thar//file_ext//i
     if(access("database/ec"//thar_ec))
     {
        if(ow_thar){
	  flag_go=yes
          delete("database/ec"//thar_ec)
	}
	else{
	  flag_go=no
	}
     }
     else{
       flag_go=yes
     }

     if(flag_go){
       ecreidentify(images=thar_ec, reference=ref_c, shift=0.,\
        cradius=5.,threshold=10.,refit+,database="database")
     }

     ref_c=thar_ec
  }
}


ref_c=thar1

if(low>0){
  i_st=low
}
else{
  i_st=0
}

if(upp>0){
  printf("\n\n########## EcReidetifying ThAr : 0 -> %d ##########\n",upp)
  for(i=i_st;i<upp;i=i+1)
  {
     file_ext="_ec"

     thar_ec=ex_thar//file_ext//i
     if(access("database/ec"//thar_ec))
     {
        if(ow_thar){
	  flag_go=yes
          delete("database/ec"//thar_ec)
	}
	else{
	  flag_go=no
	}
     }
     else{
       flag_go=yes
     }

     if(flag_go){
       ecreidentify(images=thar_ec, reference=ref_c, shift=0.,\
        cradius=5.,threshold=10.,refit+,database="database")
     }

     ref_c=thar_ec
  }
}


ex_img=inimage

templist = mktemp('tmp.gaoes_ecf.list.')
printf("\n\n########## Slicing Object : %s %d -> %d ##########\n",ex_img, low, upp)
for(i=low;i<upp;i=i+1)
{
     file_ext="_ec"

     printf(" Pixel = %2d\n", i)
     img_ec=ex_img//file_ext//i
     if(access(img_ec//".fits"))
     {
          imdelete(img_ec)
     }
     apall(input=ex_img,output=img_ec,\
      apertur="",\
      format='echelle',reference=ref,profile="",\
      interac-,find-,recente-,resize+,\
      edit-,trace-,fittrac-,extract+,extras-,review-,\
      llimit=i,ulimit=i+1,\
      nsubaps=1, pfit='fit1d', clean-, weights='none',ylevel=INDEF)

     tempspec1 = mktemp('tmp.gaoes_ecf.')
     flt_ec=ex_flt//file_ext//i
     sarith(img_ec,"/",flt_ec,tempspec1)

     img_ecf=ex_img//file_ext//"f"//i
     if(access(img_ecf//".fits"))
     {
          imdelete(img_ecf)
     }
     sarith(tempspec1,"*",fmean[i-low+1],img_ecf)
     imdelete(tempspec1)

     thar_ec=ex_thar//file_ext//i
     refspectra(input=img_ecf,answer=yes,\
      referen=thar_ec,sort=" ", group=" ", answer=yes)
     img_ecfw=ex_img//file_ext//"fw"//i
     if(access(img_ecfw//".fits"))
     {
          imdelete(img_ecfw)
     }
     dispcor(input=img_ecf,output=img_ecfw, log-)
     printf("%s\n",img_ecfw,>>templist)
}

printf("########## Combining SubApertures ##########\n")
scombine("@"//templist, outimage, combine="sum", reject="none",\
 group="apertures")
delete(templist)

imgets(inimage,'EXPTIME')
exptime=real(imgets.value)
hedit(outimage,'EXPTIME',exptime,add-,del-, ver-,show-,update+)

if(clean){
  for(i=low;i<upp;i=i+1)
  {
     file_ext="_ec"

     img_ec=ex_img//file_ext//i
     if(access(img_ec//".fits"))
     {
        imdelete(img_ec)
     }

     thar_ec=ex_thar//file_ext//i
     if(access(thar_ec//".fits"))
     {
        imdelete(thar_ec)
     }

     flt_ec=ex_flt//file_ext//i
     if(access(flt_ec//".fits"))
     {
        imdelete(flt_ec)
     }


     file_ext="_ecf"

     img_ecf=ex_img//file_ext//i
     if(access(img_ecf//".fits"))
     {
        imdelete(img_ecf)
     }

     file_ext="_ecfw"

     img_ecfw=ex_img//file_ext//i
     if(access(img_ecfw//".fits"))
     {
        imdelete(img_ecfw)
     }
  }
}

bye
end
