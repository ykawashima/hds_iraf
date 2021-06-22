procedure vtxtsstac(inimg,outfile, st, ed)
file inimg {prompt = "image file name"}
file outfile {prompt = "output text file"}
int st {prompt = "start column No."}
int ed {prompt = "end column No."}
bool save {prompt="Save result fits? (yes/no)"}
file outimg {prompt = "output image file"}
string side {prompt = "wavelength column? (X/Y)"}
string combine {prompt = "Type of combine operation (median/sum/average)"}
real w_c   {prompt="Central wavelength to be set for 0km/s"}
#
begin
#
string inimage,outtext,sd,tmpfile,tmpimg,outimage
int st_col,ed_col,i
string comb
real w0,w,c,tmp1,v
bool ans, fl_save
#
inimage= inimg
outtext = outfile
st_col= st
ed_col= ed
sd = side
comb=combine
w0=w_c
fl_save=save
outimage=outimg

c=300000.0

#
if(access(outtext)){
  printf(">>> Output Text File %s already exists!!\n",outtext)
  printf(">>> Do you want to delete this file? <y/n> : ")
  while(scan(ans)!=1) {}
  if(ans){
     delete(outtext)
  }
  else{
     bye
  }
}


tmpfile=mktemp("sstac.tmp.")
tmpimg=mktemp("sstac.tmp.")

if(access(tmpfile)) delete(tmpfile)
if(access(tmpimg)) delete(tmpimg)

if(sd=="X"){
for(i=st_col;i<=ed_col;i=i+1)
{
     printf(inimage//"[*,"//i//"]\n",>>tmpfile)
}
}
else{
for(i=st_col;i<=ed_col;i=i+1)
{
     printf(inimage//"["//i//",*]\n",>>tmpfile)
}
}

scombine("@"//tmpfile,tmpimg,combine=comb,group="all")
delete(tmpfile)

listpixels(tmpimg, wcs='world',formats='%g %g',ver-,mode=mode, >> tmpfile)

list=tmpfile
while(fscan(list,w, tmp1)>0)
{
v=c/w0*(w-w0)
printf("%g, %g, %g\n",w,tmp1,v, >> outtext)
}

delete(tmpfile)
if(fl_save){
  if(access(outimage//".fits")||access(outimage//".imh")){
    printf(">>> Output Image File %s already exists!!\n",outtext)
    printf(">>> Do you want to delete this file? <y/n> : ")
    while(scan(ans)!=1) {}
    if(ans){
       imdelete(outimage)
    }
    else{
       bye
    }
  }
  imrename(tmpimg,outimage)
}
else{
  imdelete(tmpimg)
}


bye
end





