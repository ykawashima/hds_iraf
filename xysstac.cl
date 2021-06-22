procedure xysstac(inimg,outimg, st_c_i, ed_c_i)
file inimg {prompt = "image file name"}
file outfile {prompt = "output text file"}
int st_c_i {prompt = "start column No."}
int ed_c_i {prompt = "end column No."}
string side {prompt = "wavelength column? (X/Y)"}
string combine {prompt = "Type of combine operation (median/sum/average)"}
real w_c   {prompt="Central wavelength to be set for 0km/s"}
#
begin
#
string inimage,outtext,sd,tmpfile,tmpimg
int st_col,ed_col,i,len
string comb
real w0,w,c,tmp1,tmp2,v
#
inimage= inimg
outimage = outimg
st_col= st_c_i
ed_col= ed_c_i
sd = side
comb=combine
w0=w_c

c=300000.0

#
tmpfile=mktemp("imstac.tmp.")
tmpimg=mktemp("imstac.tmp.")

if(access(tmpfile)) delete(tmpfile)
if(access(tmpimg)) delete(tmpimg)

if(sd=="X"){
for(i=st_col;i<=ed_col;i=i+1)
{
     printf(inimage//"[*,"//i//"]\n",>>tmpfile)
}
 imgets(temp//".os.fits",'i_naxis1')
 len=int(imgets.value)
}
else{
for(i=st_col;i<=ed_col;i=i+1)
{
     printf(inimage//"["//i//",*]\n",>>tmpfile)
}
 imgets(temp//".os.fits",'i_naxis2')
 len=int(imgets.value)
}

scombine("@"//tmpfile,tmpimg,combine=comb)
delete(tmpfile)

for(i=1;i<=len;i=i+1){
listpixels(tmpimg//'['//i']',\
           wcs='world',formats='%g %g',ver-,mode=mode) | scan(w,tmp1,tmp2)
v=c/w0*(w-w0)
printf("%g,  %g,   %g\n",v,tmp1,tmp2, >> outtext)
}

imdelete(tmpimg)


bye
end





