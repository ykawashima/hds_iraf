#------------------------------------------------------------
#   Quick Combine Imaging Data
#
#                      A.Tajitsu   finally revised 2003.01.03
#------------------------------------------------------------
procedure vgwadd(inlist,output)

string inlist {prompt="List of INPUT images and XY"}
string output {prompt="Output Image"}
#int fltmax=50000 {prompt="MAX count of Flat image"}
#string outlist {prompt="List of OUTPUT images"}

begin

string list_in, listtmp, outimg, imgtmp
string imgfile
real  sx0, sy0, sx, sy
int i


list_in = inlist
outimg=output

listtmp = mktemp('list.vgwadd.tmp.')

i=0
list=list_in
while(fscan(list,imgfile,sx,sy)==3)
{
  if(i==0){
    sx0=sx
    sy0=sy
  }
  imgtmp  = mktemp('tmp.vgwadd')
  imshift(imgfile,imgtmp,xshift=sx0-sx,yshift=sy0-sy)
  print(imgtmp,>>listtmp)
  i=i+1
}

imcombine('@'//listtmp,outimg,combine='median')

bye
end

