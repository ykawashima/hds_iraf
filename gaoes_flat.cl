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

bool imcheck=yes {prompt ="Mean count check? (yes/no)"}
int ic_x1=88 {prompt ="x1 for average measuring are"}
int ic_x2=92 {prompt ="x2 for average measuring are"}
int ic_y1=1950 {prompt ="y1 for average measuring are"}
int ic_y2=2100 {prompt ="y2 for average measuring are"}
int ic_coff=30000 {prompt ="Minimum count to accept\n"}

bool scatter=yes {prompt ="apscatter? (yes/no)"}
bool normalize=yes {prompt ="apnormalize? (yes/no)\n"}

bool interactive=yes {prompt ="Run task interactively? (yes/no)\n"}

begin
#
# variables
#
string indir, flat, apref, temp1, temp_id, flag, output, scfile, nmfile
string apnew
int low, upp, imnum
bool d_ans
int m_val
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
       if(interactive){
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
       else{
         imdelete(flat)
       }
}

if(scatter){
  if((access(flat//".sc"))||access(flat//".sc.fits")){
       printf("*** Output file \"%s.sc\" already exsits!!\n",flat)
       if(interactive){
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
       else{
            imdelete(flat//".sc")
       }
  }
}


if(normalize){
  if((access(flat//".nm"))||access(flat//".nm.fits")){
       printf("*** Output file \"%s.nm\" already exsits!!\n",flat)
       if(interactive){
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
       else{
            imdelete(flat//".nm")
       }
  }
  if(scatter){
    if((access(flat//".sc.nm"))||access(flat//".sc.nm.fits")){
       printf("*** Output file \"%s.sc.nm\" already exsits!!\n",flat)
       if(interactive){
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
       else{
            imdelete(flat//".sc.nm")
       }
    }
  }
}


if(apflag){
  if((access(apnew))||access(apnew//".fits")){
       printf("*** Output file \"%s\" already exsits!!\n",apnew)
       if(interactive){
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
       else{
            imdelete(apnew)
            if((access(apnew//".ec"))||access(apnew//".ec.fits")){
               imdelete(apnew//".ec")
            }
            if(access("database/ap"//apnew)){
               delete("database/ap"//apnew)
            }
       }
  }
}


printf("\n")
printf("##################################\n")
printf("# [1/4] Overscan raw flat frames\n")
printf("##################################\n")

grql("00000000",indirec=indir,batch+,inlist=inlist,interactive-,ref_ap=apref,\
  flatimg=INDEF,thar1d=INDEF,thar2d=INDEF,\
  st_x=low,ed_x=upp,cosmicra-,scatter-,ecfw-)


temp1=mktemp("tmp_gaoes_flat")

list=inlist
imnum=0
while(fscan(list,temp_id)==1){
  imstat(image="G"//temp_id//"o"//"["//ic_x1//":"//ic_x2//","//ic_y1//":"//ic_y2//"]", field='mean', format-) | scan(m_val)
  if(m_val>ic_coff){
    printf("G%so  (%d)  OK\n",temp_id, m_val)
    printf("G%so\n",temp_id,>>temp1)
    imnum=imnum+1
  }
  else{
    printf("G%so  (%d)  rejected\n",temp_id,m_val)
  }
}

printf("### imcombine ovescanned flat images ###\n")
if(imnum>2){
  imcombine("@"//temp1,flat,combine="ave",reject="minmax")
}
else{
  imcombine("@"//temp1,flat,combine="ave",reject="none")
}

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
      find-,edit=interactive, extract+, review=interactive, mode="ql")

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
  apscatter(flat,scfile,interac=interactive,referen=apref,recente-,resize-,\
    edit=interactive,trace-,fitscat+,subtrac+,smooth+,fittrac+)

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

  print("# Normalization is now processing...")
  apnormalize(scfile,nmfile,interac=interactive,referen=apref,recente-,resize-,\
    edit=interactive,trace-,fittrac+,normalize+,fitspec+,order=15,niterate=5)

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
