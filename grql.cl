##################################################################
# grql : Seimei GAOES-RV Quick Look Script 
#  developed by Akito Tajitsu <tajitsu@subaru.naoj.org>
#              2022.10.25 ver.0.01
###################################################################
procedure grql(inid)
### Input parameters
 string inid {prompt = 'Input frame ID'}
 string indirec {prompt = 'directory of RAW data\n'}

 bool  batch=no {prompt = 'Batch Mode?'}
 file  inlist {prompt = 'Input file list for batch-mode\n'}

 string ref_ap {prompt= "Aperture reference image"}
 string flatimg {prompt= "ApNormalized flat image"}
 string thar1d  {prompt= "1D wavelength-calibrated ThAr image"}
 string thar2d  {prompt= "2D ThAr image\n"}

 int st_x=-54  {prompt ="Start pixel to extract"}
 int ed_x=53  {prompt ="End pixel to extract\n"}

 bool   scatter=no {prompt = 'Scattered Light Subtraction?'}
 bool   ecfw=no {prompt = 'Extract / Flat-fielding / Wavelength calib.?\n\n### Scattered Light Subtraction. ###'}

# Parameters for overscan

# scattered light subtraction
 bool   sc_inter=yes {prompt = 'Run apscatter interactively?\n'}

# Extract / Flat fielding / Wavecalib

begin
string version="0.01 (10-25-2022)"
string input_id, tmp_inid
string apref, flt, thar1, thar2

int batch_n
string temp_id
bool d_ans

string input, input0, output

string flag
string osfile, scfile, ecfile,nextin

apref=ref_ap
flt=flatimg
thar1=thar1d
thar2=thar2d

if(batch){
  list=inlist
  batch_n=0

  printf("\n############################################\n")
  printf("###   Starting grql in Batch Mode\n")
  printf("############################################\n")
  printf("  Input files are...\n")
  while(fscan(list,temp_id)==1){
    printf("   %s/GRA%s\n",indirec,temp_id)
    batch_n=batch_n+1
  }

  printf(" Total frame number=%d.\n",batch_n)
  printf(">>> Do you want to start Batch mode? (y/n) : ")
  while(scan(d_ans)!=1) {}
  if(!d_ans){
    printf("!!! ABORT !!!\n")
    bye
  }

  list=inlist
}

BATCH_START:

if(batch){
  if(fscan(list,temp_id)==1){
    input_id=temp_id
    printf("\n##########################\n")
    printf("###   Batch Mode\n")
    printf("###     Input ID = %s\n", input_id)
    printf("##########################\n\n")
  }
  else{
     goto BATCH_END
  }
}
else{
  input_id=inid
}

output  = "G"//input_id
printf("output ID : %s\n", output)

input=indirec//"/GRA"//input_id//".fits"
printf("input data= %s\n", input)

nextin=input


# overscan
  printf("\n")
  printf("##################################\n")
  printf("# [1/3] Overscan\n")
  printf("##################################\n")

  flag="o"
  osfile=(output+flag)

  if((access(osfile))||access(osfile//".fits")){
     printf("*** OverScanned file \"%s\" already exsits!!\n",osfile)
     printf("*** Automatcally Rmoving \"%s\" ...\n",osfile)
     imdelete(osfile)
  }

  printf(" output overscaned data= %s\n", osfile)
  print("# Overscan is now processing...")
  gaoes_overscan(inimage=nextin,outimage=osfile)
  hedit(osfile,'GRQL_OS',"done",add+,del-, ver-,show-,update+)
  nextin=osfile



# scattered light subtraction
if (scatter){
  printf("\n")
  printf("##################################\n")
  printf("# [2/3] Scattered Light Subtraction\n")
  printf("##################################\n")

  flag=flag+"s"	
  scfile=(output+flag)

  if((access(scfile))||access(scfile//".fits")){
     printf("*** Scattered Light Subtracted file \"%s\" already exsits!!\n",scfile)
     printf("*** Automatcally Rmoving \"%s\" ...\n",scfile)
     imdelete(scfile)
  }
#

  printf("# Resizing aperture size of \"%s\"......\n", apref)
  apresize(apref,refer=" ",llimit=st_x, ulimit=ed_x, ylevel=INDEF,\
    resize+, interac-)

  print("# Scattered light subtracting is now processing...")
  apscatter(nextin,scfile,interac=sc_inter,referen=apref,recente-,resize-,\
    edit-,trace-,fittrac=sc_inter)
  hedit(scfile,'GRQL_SC',"done",add+,del-, ver-,show-,update+)
  nextin=scfile
}

# extract / flat fielding / wavelength calibration
if(ecfw){
  printf("\n")
  printf("######################################################\n")
  printf("# [3/3] Flat Fielding / Extraction / Wavelength Calib.\n")
  printf("######################################################\n")

  flag=flag+"_ecfw"	
  ecfile=(output+flag)
  printf(" output extracted, flatted, wavelength calibrated data= %s\n", ecfile)

  if((access(ecfile))||access(ecfile//".fits")){
     printf("*** Extracted / Flat Fielded / Wavelength calibrated file \"%s\" already exsits!!\n",ecfile)
     printf("*** Automatcally Rmoving \"%s\" ...\n",ecfile)
     imdelete(ecfile)
  }

  printf("# Extraction / Flat fielding / Wavelength calibration is now processing...")
  gaoes_ecfw(nextin,ecfile,ref_ap=apref, flatimg=flt,thar1d=thar1, \
   thar2d=thar2, st_x=st_x,ed_x=ed_x)
  hedit(ecfile,'GRQL_EC',"done",add+,del-, ver-,show-,update+)
  nextin=ecfile
}

printf("\n")
printf("##############################################################\n")
printf("# grql : FINISH\n")
printf("#   ver %s developped by A.Tajitsu\n",version)
printf("#\n")
printf("#  Resultant File :   %s%s.fits\n",output,flag)
printf("##############################################################\n")

#endofp:

if(batch){
  goto BATCH_START
}

BATCH_END:

bye
end
