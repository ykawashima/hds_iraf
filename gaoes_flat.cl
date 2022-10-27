# Procedure for making flat frame for GAOES-RV
#
# copyright : A.Tajitsu (2022/10/27)
# !!!  It's important to use apall with                      !!!
# !!!          "llimit=(pix) ulimit=(pix+1) ylebel=INDEF"    !!!
# !!!    to extract 1-pixel along a reference aperture.      !!!
#
procedure gaoes_flat(inlist,indirec,outimg)
file inlist   {prompt= "input flat image list"}
string indirec {prompt = 'directory of RAW data'}
file outimg  {prompt= "output flat image\n"}

string ref_ap {prompt= "Aperture reference image"}
bool apflag=yes {prompt ="Create new aperture reference? (yes/no)"}
file   new_ap  {prompt= "New aperture image\n"}

int st_x=-54  {prompt ="Start pixel to extract"}
int ed_x=53  {prompt ="End pixel to extract\n"}

bool scatter=yes {prompt ="apscatter? (yes/no)"}
bool normalize=yes {prompt ="apnormalize? (yes/no)\n"}

begin
#
# variables
#
string indir, flat, apref, temp1, temp_id, flag, output, scfile, nmfile
string apnew
int low, upp
bool d_ans
#
#
#
indir = indirec
flat  = outimg
apref = ref_ap
apnew = new_ap

low = st_x
upp = ed_x


#
# start
#

if((access(flat))||access(flat//".fits")){
       printf("*** Output file \"%s\" already exsits!!\n",flat)
       printf(">>> Do you want to overwrite this file? (y/n) : ")
       while(scan(d_ans)!=1) {}
       if(d_ans){
          imdelete(flat)
       }
       else{
          printf("!!! Please remove exsiting file !!! ABORT !!!\n")
          bye
       }
}

if(scatter){
  if((access(flat//".sc"))||access(flat//".sc.fits")){
       printf("*** Output file \"%s.sc\" already exsits!!\n",flat)
       printf(">>> Do you want to overwrite this file? (y/n) : ")
       while(scan(d_ans)!=1) {}
       if(d_ans){
          imdelete(flat//".sc")
       }
       else{
          printf("!!! Please remove exsiting file !!! ABORT !!!\n")
          bye
       }
  }
}


if(normalize){
  if((access(flat//".nm"))||access(flat//".nm.fits")){
       printf("*** Output file \"%s.nm\" already exsits!!\n",flat)
       printf(">>> Do you want to overwrite this file? (y/n) : ")
       while(scan(d_ans)!=1) {}
       if(d_ans){
          imdelete(flat//".nm")
       }
       else{
          printf("!!! Please remove exsiting file !!! ABORT !!!\n")
          bye
       }
  }

  if(scatter){
    if((access(flat//".sc.nm"))||access(flat//".sc.nm.fits")){
       printf("*** Output file \"%s.sc.nm\" already exsits!!\n",flat)
       printf(">>> Do you want to overwrite this file? (y/n) : ")
       while(scan(d_ans)!=1) {}
       if(d_ans){
          imdelete(flat//".sc.nm")
       }
       else{
          printf("!!! Please remove exsiting file !!! ABORT !!!\n")
          bye
       }
    }
  }
}


if(apflag){
  if((access(apnew))||access(apnew//".fits")){
       printf("*** Output file \"%s\" already exsits!!\n",apnew)
       printf(">>> Do you want to overwrite this file? (y/n) : ")
       while(scan(d_ans)!=1) {}
       if(d_ans){
          imdelete(apnew)
          if((access(apnew//".ec"))||access(apnew//".ec.fits")){
             imdelete(apnew//".ec")
          }
          if(access("database/ap"//apnew)){
             delete("database/ap"//apnew)
          }
       }
       else{
          printf("!!! Please remove exsiting file !!! ABORT !!!\n")
          bye
       }
  }
}


printf("\n")
printf("##################################\n")
printf("# [1/4] Overscan raw flat frames\n")
printf("##################################\n")

grql("00000000",indirec=indir,batch+,inlist=inlist,ref_ap=apref,\
  st_x=low,ed_x=upp,scatter-,ecfw-)


temp1=mktemp("tmp_gaoes_flat")

list=inlist
while(fscan(list,temp_id)==1){
  printf("G%so\n",temp_id,>>temp1)
}

printf("### imcombine ovescanned flat images ###\n")
imcombine("@"//temp1,flat,combine="ave",reject="minmax")

output=flat


if(apflag){
  printf("\n")
  printf("##################################\n")
  printf("# [2/4] Creating new aperture file\n")
  printf("##################################\n")
  
  imcopy(flat,apnew)

  printf("# Resizing aperture size of \"%s\"......\n", apref)
  apresize(apref,refer=" ",llimit=0, ulimit=1, ylevel=INDEF,\
    resize+, interac-)

  apall(apnew,ref=apref,output=apnew//".ec",resize-,recenter-,trace-,\
      find-,edit+)

  apref=apnew
}

if(scatter){
  printf("\n")
  printf("##################################\n")
  printf("# [3/4] Apscatter\n")
  printf("##################################\n")

  flag=".sc"
  scfile=(output+flag)

  printf("# Resizing aperture size of \"%s\"......\n", apref)
  apresize(apref,refer=" ",llimit=low, ulimit=upp, ylevel=INDEF,\
    resize+, interac-)

  print("# Scattered light subtracting is now processing...")
  apscatter(flat,scfile,interac+,referen=apref,recente-,resize-,\
    edit+,trace-,fitscat+,subtrac+,smooth+,fittrac+)

 output=scfile
}

if(normalize){
  printf("\n")
  printf("##################################\n")
  printf("# [4/4] Apnormalize\n")
  printf("##################################\n")
  
  flag=".nm"
  nmfile=(output+flag)

  printf("# Resizing aperture size of \"%s\"......\n", apref)
  apresize(apref,refer=" ",llimit=low, ulimit=upp, ylevel=INDEF,\
    resize+, interac-)

  print("# Scattered light subtracting is now processing...")
  apnormalize(scfile,nmfile,interac+,referen=apref,recente-,resize-,\
    edit+,trace-,fittrac+,normalize+,fitspec+,order=15,niterate=5)

 output=nmfile
}

delete(temp1)


printf("\n")
printf("##############################################################\n")
printf("# gaoes_flat : FINISH\n")
printf("#                         developped by A.Tajitsu\n")
printf("#\n")
printf("#  Resultant File :   %s.fits\n",output)
printf("##############################################################\n")

bye
end
