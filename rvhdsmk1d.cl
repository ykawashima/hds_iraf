##################################################################
# Subaru HDS Make 1D Flux calibrated Spectrum
#       from 1st reduce Echelle spectrum and Blaze Function (mkblaze-ed)
#  developed by Akito Tajitsu <tajitsu@subaru.naoj.org>
#              2013.07.13 ver.1.00
###################################################################
procedure rvhdsmk1d(inlst,out1d,blaze)
#
file	inlst	{prompt= "Input List of Multi-Order Spectrum"}
file	out1d   {prompt= "Output Flux Calibrated 1D Spectrum"}
file    blaze   {prompt= "(Modefied) Blaze Function\n"}

string rv_obs="subaru"    {prompt = "Observatory\n"}

bool    trim=no    {prompt= "Trimming X-Pixel? (y/n)"}
int     st_x=1   {prompt= "Start X"}
int     ed_x=4096    {prompt= "End X\n"}

bool    scomb=yes    {prompt= "Scombine to Recalculate Dispersion? (y/n)"}
bool    adjexp=yes    {prompt= "Auto ExpTime Adjustment? (y/n)"}

struct *listin
#

begin
string 	inlist, rvlist, inid, inimg, outimg, blz, suf_b, suf_s, suf_t
string adjtmp, vrtmp, suf_r, suf_f, scomtmp
string rvobs, hmask
bool  trm, aexp, scom, ans
int x1, x2
int expt, bexpt
real efact,expt,ttlexp
int nfile


outimg=out1d
blz=blaze

rvobs=rv_obs

trm=trim
x1=st_x
x2=ed_x

scom=scomb
aexp=adjexp

suf_t="_t"
suf_b="_b"
suf_s="_sum"
suf_f="_F"
suf_r="r"

nfile=1
ttlexp=0.

if(access(outimg//".fits")){ 
  printf(">>> Output spectrum %s already exsists\n", outimg)
  printf(">>> Do you want to replace it? (y/n) : ")
  while(scan(ans)!=1) {}
  if(ans){
   imdelete(outimg)
  }
  else{
   bye
  }
}
if(access(outimg)){ 
  printf(">>> Output spectrum %s already exsists\n", outimg)
  printf(">>> Do you want to replace it? (y/n) : ")
  while(scan(ans)!=1) {}
  if(ans){
   delete(outimg)
  }
  else{
   bye
  }
}


rvlist=mktemp("tmp.rvlist")

listin=inlst

while(fscanf(listin,"%s", inid)!=EOF){
  if(access(inid//suf_t//".fits")){ 
    imdelete(inid//suf_t)
  }
  if(access(inid//suf_t)){ 
    delete(inid//suf_t)
  }
  if(access(blz//suf_t//".fits")){ 
    imdelete(blz//suf_t)
  }
  if(access(blz//suf_t)){ 
    delete(blz//suf_t)
  }
  if(trm){
    printf("##### X Trimming #####\n")
    if(scom){
       scomtmp=mktemp("tmp.scomb")
       scombine(inid, scomtmp,combine="ave",group="apertures",reject="none")
       scopy(scomtmp//"["//x1//":"//x2//",*]", inid//suf_t)
       imdelete(scomtmp)
    }
    else{
      scopy(inid//"["//x1//":"//x2//",*]", inid//suf_t)
    }
    scopy(blz//"["//x1//":"//x2//",*]", blz//suf_t)
  }
  else{
    if(scom){
       scomtmp=mktemp("tmp.scomb")
       scombine(inid, scomtmp,combine="ave",
               group="apertures",reject="none")
       scopy(scomtmp, inid//suf_t)
       imdelete(scomtmp)
    }
    else{
       scopy(inid, inid//suf_t)
    }
    scopy(blz, blz//suf_t)
  }

  imgets(inid,'EXPTIME')
  expt=real(imgets.value)
  ttlexp=ttlexp+expt

################ hdsbadfix
  printf("##### Removal Bad Pix #####\n")
  if(access(inid//suf_b//".fits")){ 
    imdelete(inid//suf_b)
  }
  if(access(inid//suf_b)){ 
    delete(inid//suf_b)
  }
  if(nfile==1){
    hdsbadfix2(inid//suf_t, inid//suf_b,manual+,mask+,cl_mask+,value=0, st_x=st_x)
    imgets(inid,'H_MASK')
    hmask=(imgets.value)
  }
  else{
    hdsbadfix2(inid//suf_t, inid//suf_b,manual-,mask+,maskima=hmask, \
             cl_mask+,value=0, st_x=st_x)
  }

  if(access(blz//suf_b//".fits")){ 
    imdelete(blz//suf_b)
  }
  if(access(blz//suf_b)){ 
    delete(blz//suf_b)
  }
  hdsbadfix2(blz//suf_t, blz//suf_b,manual-,mask+,cl_mask-,value=0, st_x=st_x)

  printf("##### Scombine All Orders #####\n")
  if(access(inid//suf_b//suf_s//".fits")){ 
    imdelete(inid//suf_b//suf_s)
  }
  if(access(inid//suf_b//suf_s)){ 
    delete(inid//suf_b//suf_s)
  }
  scombine(inid//suf_b, inid//suf_b//suf_s,combine="sum",group="images",reject="none")

  if(access(blz//suf_b//suf_s//".fits")){ 
    imdelete(blz//suf_b//suf_s)
  }
  if(access(blz//suf_b//suf_s)){ 
    delete(blz//suf_b//suf_s)
  }
  scombine(blz//suf_b,blz//suf_b//suf_s,combine="sum",group="images",reject="none")


  printf("##### Make Flux-Calibrated 1D Spectrum #####\n")
  if(access(inid//suf_f//".fits")){ 
    imdelete(inid//suf_f)
  }
  if(access(inid//suf_f)){ 
    delete(inid//suf_f)
  }

  if(scom){
    imarith(inid//suf_b//suf_s,"/",blz//suf_b//suf_s,inid//suf_f)
  }
  else{
    sarith(inid//suf_b//suf_s,"/",blz//suf_b//suf_s,inid//suf_f)
  }
  imgets(inid,'EXPTIME')
  expt=int(imgets.value)

  if(aexp){
    imgets(blz,'EXPTIME')
    bexpt=int(imgets.value)
    efact=real(expt)/real(bexpt)
    printf("##### Auto ExpTime Adjustment /(%d/%d)\n",expt,bexpt)
    adjtmp = mktemp('tmp.hdsmk1d.')
    imrename (inid//suf_f, adjtmp)
    sarith (adjtmp, '/', efact, inid//suf_f)
    imdelete (adjtmp)
  }

  hedit(inid//suf_f,"EXPTIME",expt,del-,add-,ver-,show+,update+)


############### rvhds
   if(access(inid//suf_f//suf_r//".fits")){ 
     imdelete(inid//suf_f//suf_r)
   }
   if(access(inid//suf_f//suf_r)){ 
     delete(inid//suf_f//suf_r)
   }
   rvhds(inimage=inid//suf_f,outimage=inid//suf_f//suf_r, observa=rvobs)
   print(inid//suf_f//suf_r, >> rvlist)

   nfile=nfile+1

}

printf("##### Final scombine\n")

scombine("@"//rvlist,outimg,group="apertures",combine="ave",reject="none")
delete(rvlist)

hedit(outimg,"EXPTIME",ttlexp,update+,ver-)

printf("## Created : %s   ... done\n",outimg)

bye
end
