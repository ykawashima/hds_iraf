#------------------------------------------------------------
#   VGW AG vignetting mesuring tool
#           
#
#                      A.Tajitsu   finally revised 2003.01.08
#------------------------------------------------------------
procedure vgwphoto(inlist,outlist)

string inlist  {prompt="List of INPUT"}
string outlist {prompt="List of OUTPUT"}

begin

string list_in, list_out
string imgfile
string tmp1,tmp2,tmp3,tmp4,tmp5,tmp6,tmp7
string examlog[100], examimg[100]
real fx, ag_r, ag_th
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
       print(tmp7) | scan(fx);
     }
   }
   
   imgets(examimg[i_list],'AG-PRB1')
   ag_r=real(imgets.value)
   imgets(examimg[i_list],'AG-PRB2')
   ag_th=real(imgets.value)

   if(i_list!=1){
     if(examlog[i_list]==examlog[i_list-1]) fx=0
   }

   printf("%s, %6.2f, %6.2f, %10.2f\n",examimg[i_list],ag_r,ag_th,fx,>>list_out)
   # delete(examlog[i_list])
}


bye
end

