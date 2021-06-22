#------------------------------------------------------------
#   VGW AG vignetting mesuring tool
#           
#
#                      A.Tajitsu   finally revised 2003.01.08
#------------------------------------------------------------
procedure vgwpos(inlist,outlist)

string inlist  {prompt="List of INPUT"}
string outlist {prompt="List of OUTPUT"}

begin

string list_in, list_out
string imgfile
string tmp1,tmp2,tmp3,tmp4,tmp5,tmp6,tmp7
string examlog[1000], examimg[1000]
real x_pos, y_pos, az, el, mjd
int i_list,end_i

list_in = inlist
list_out = outlist

list=list_in
i_list=1
while(fscan(list,imgfile)==1)
{
  display(imgfile,1)
  printf(" Please examine the star to be initial position with r-key!!\n")
  examlog[i_list] = mktemp('log.imexam.tmp.')
  examimg[i_list] = imgfile
  imexamine(input="",frame=1,image="",logfile=examlog[i_list], keeplog+)
  i_list=i_list+1
}

end_i=i_list
for(i_list=1;i_list<end_i;i_list=i_list+1){
   list=examlog[i_list]
   while(fscan(list,tmp1,tmp2,tmp3,tmp4,tmp5,tmp6,tmp7)>0)
   {
     if(tmp1!='#'){
       print(tmp1) | scan(x_pos);
       print(tmp2) | scan(y_pos);
     }
   }
   
   imgets(examimg[i_list],'AZIMUTH')
   az=real(imgets.value)
   if(az>270){
       az=az-360
   }
   imgets(examimg[i_list],'ALTITUDE')
   el=real(imgets.value)
   imgets(examimg[i_list],'MJD')
   mjd=real(imgets.value)

   printf("%f %f %f %f %f\n",x_pos,y_pos,az,el,mjd,>>list_out)
   # delete(examlog[i_list])
}


bye
end

