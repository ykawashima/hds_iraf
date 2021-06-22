#------------------------------------------------------------
#   VGW co-adding image
#           
#
#                      A.Tajitsu   finally revised 2003.07.09
#------------------------------------------------------------
procedure vgwmake(inlist,output,outlist)

string inlist {prompt="List of INPUT"}
string output {prompt="Output image"}
string outlist {prompt="Output List"}

begin

string list_in, listtmp, imgflat, listout
string imgfile, imgsub, outimg, imgtmp
string tmp1,tmp2,tmp3,tmp4,tmp5,tmp6
string examlog[500], examimg[500]
bool ans
real sx, sy,  mjd,  mjd0,  sec
real all_sx, all_sy, ave_sx, ave_sy, err_x, err_y
int i_list,end_i

list_in = inlist
outimg=output
listout = outlist

listtmp = mktemp('list.vgwmake.tmp.')

list=list_in
i_list=1
while(fscan(list,imgfile)==1)
{
  display(imgfile,1)
#  printf(" Do you use this image? <y/n> : ")
#  while(scan(ans)!=1) {}
#  if(ans) {
    printf(" %s : Please examine the star to be initial position!!\n",
    imgfile)
    examlog[i_list] = mktemp('log.imexam.tmp.')
    examimg[i_list] = imgfile
    imexamine(input="",frame=1,image="",logfile=examlog[i_list], keeplog+)

    i_list=i_list+1
#  }
}

end_i=i_list

all_sx=0
all_sy=0
for(i_list=1;i_list<end_i;i_list=i_list+1){
   list=examlog[i_list]
   while(fscan(list,tmp1,tmp2,tmp3,tmp4,tmp5,tmp6)>0)
   {
     if(tmp1!='#'){
       print(tmp1) | scan(sx);
       print(tmp2) | scan(sy);
     }
   }

   all_sx=all_sx+sx
   all_sy=all_sy+sy
}

ave_sx=all_sx/(end_i-1)
ave_sy=all_sy/(end_i-1)

for(i_list=1;i_list<end_i;i_list=i_list+1){
   list=examlog[i_list]
   while(fscan(list,tmp1,tmp2,tmp3,tmp4,tmp5,tmp6)>0)
   {
     if(tmp1!='#'){
       print(tmp1) | scan(sx);
       print(tmp2) | scan(sy);
     }
   }

   err_x=sx-ave_sx   
   err_y=sy-ave_sy   

   imgets(examimg[i_list],'MJD')
   mjd=real(imgets.value)
   if(i_list==1)
   {
      sec=0.0
      mjd0=mjd
   }
   else
   {
      sec=(mjd-mjd0)*60*60*24
   }

   printf("%s %f %f %f %f %f\n",examimg[i_list],sx,sy,err_x,err_y,sec,>>listtmp)
   # delete(examlog[i_list])
}

vgwadd(listtmp,outimg)

display(outimg,1)

copy(listtmp,listout)

bye
end

