# Procedure for making comparison frame for GAOES-RV
#
# copyright : A.Tajitsu (2022/10/27)
# !!!  It's important to use apall with                      !!!
# !!!          "llimit=(pix) ulimit=(pix+1) ylebel=INDEF"    !!!
# !!!    to extract 1-pixel along a reference aperture.      !!!
#
procedure gaoes_comp(inid,indirec,outimg)
string inid   {prompt= "input ID of ThAr frame"}
string indirec {prompt = 'directory of RAW data'}
file outimg  {prompt= "output comparison image\n"}

string ref_ap {prompt= "Aperture reference image"}
string ref_comp {prompt= "Wavelength reference (1D comparison) image\n"}

begin
#
# variables
#
string indir, apref, compref, thar,  output
bool d_ans
#
#
#
indir = indirec
thar  = outimg
apref = ref_ap
compref = ref_comp


#
# start
#

if((access(thar))||access(thar//".fits")){
       printf("*** Output file \"%s\" already exsits!!\n",thar)
       printf(">>> Do you want to overwrite this file? (y/n) : ")
       while(scan(d_ans)!=1) {}
       if(d_ans){
          imdelete(thar)
       }
       else{
          printf("!!! Please remove exsiting file !!! ABORT !!!\n")
          bye
       }
}

if((access(thar//".center"))||access(thar//".center.fits")){
       printf("*** Output file \"%s.center\" already exsits!!\n",thar)
       printf(">>> Do you want to overwrite this file? (y/n) : ")
       while(scan(d_ans)!=1) {}
       if(d_ans){
          imdelete(thar)
          if(access("database/ec"//thar//".center")){
             delete("database/ec"//thar//".center")
          }
       }
       else{
          printf("!!! Please remove exsiting file !!! ABORT !!!\n")
          bye
       }
}


printf("\n")
printf("##################################\n")
printf("# [1/4] Overscan a raw ThAr frame\n")
printf("##################################\n")

grql(inid,indirec=indir,batch-,scatter-,ecfw-)
output="G"//inid//"o"
imcopy(output,thar)


printf("\n")
printf("###########################################\n")
printf("# [2/4] Extracting aperture center of ThAr\n")
printf("###########################################\n")
  
printf("# Resizing aperture size of \"%s\"......\n", apref)
apresize(apref,refer=" ",llimit=0, ulimit=1, ylevel=INDEF,\
    resize+, interac-)

apall(thar,refer=apref,output=thar//".center",interac-, resize-,recenter-,\
      trace-,find-,edit-)

printf("\n")
printf("##################################\n")
printf("# [3/4] EcReIdentify\n")
printf("##################################\n")

ecreidentify(images=thar//".center", reference=compref, shift=0.,\
     cradius=5.,threshold=10.,refit+,database="database")

printf("\n")
printf("##################################\n")
printf("# [4/4] EcIdentify\n")
printf("##################################\n")

ecidentify(images=thar//".center")

printf("\n")
printf("##############################################################\n")
printf("# gaoes_comp : FINISH\n")
printf("#                         developped by A.Tajitsu\n")
printf("#\n")
printf("#  Resultant File : 2-D  %s.fits\n",thar)
printf("#                   1-D  %s.center.fits\n",thar)
printf("##############################################################\n")

bye
end
