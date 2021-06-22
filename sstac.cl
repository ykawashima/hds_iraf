procedure sstac(inimg,outimg, st, ed)
file inimg {prompt = "image file name"}
file outimg {prompt = "output image file"}
int st {prompt = "start column No."}
int ed {prompt = "end column No."}
string side {prompt = "wavelength column? (X/Y)"}
string combine {prompt = "Type of combine operation(median/sum/average)"}
string reject  {prompt = "Type of rejection(none/sigclip/avsigclip)"}
bool scomb {prompt= "Use Scombine instead of Imcombine? <y/n> "}
#
begin
#
string inimage,outimage,sd,tmpfile, rjt
int st_col,ed_col,i
string comb
bool scom
#
inimage= inimg
outimage = outimg
st_col= st
ed_col= ed
sd = side
comb=combine
scom=scomb
rjt=reject
#
tmpfile=mktemp("imstac.tmp.")

if(access(tmpfile)) delete(tmpfile)

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

if(scom){
  scombine("@"//tmpfile,outimage,combine=comb,group="all", reject=rjt)
}
else{
  imcombine("@"//tmpfile,outimage,combine=comb, reject=rjt)
}
delete(tmpfile)

bye
end





