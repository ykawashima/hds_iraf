# version 1.0.5
# task overscan = path$overscan.cl

procedure gaoes_linstab (inlist)

string inlist	{prompt="Input image list"}
int exp1=30	{prompt="Short Exposure Time"}
int exp2=60	{prompt="Long Exposure Time"}
int d_p=10      {prompt="Pixel Size for Imstat"}
real b_p=0.5    {prompt="Border Percentage to Mark"}
int fwidth=30      {prompt="Pixel Width for Flat Detection"}
int d_x=10      {prompt="Pixel Sampling Along X"}
int d_y=10      {prompt="Pixel Sampling Along y"}
int lower=1e3      {prompt="Lower Count to be Plotted"}
int upper=1e5      {prompt="Upper Count to be Plotted"}
string suffix      {prompt="Suffix to be added to XY File Name"}

begin
	string listtmp, inimg
	int e_time
	int xbin, ybin
	string list1, list2 ,list1r, list2r
	int e_1, e_2
	int xsize, ysize
	int x, y, dp
	real ave_cnt, cnt[101], resi[101], diff_cnt
	string ave1, ave2
	int i1, i2, i
	string pix_list
	string img1[101], img2[101]
	real bp
	real    temp1,temp2,temp3,temp4,temp5,temp6,center[200]
	int j, jmax
	int fw
	bool ans
	string diff, tmpimg,  diff_txt
	int dx, dy, ix, iy
	int up, low
	string suf
	string obsdate,mjd,lampstab

	listtmp=inlist
	e_1=exp1
	e_2=exp2
	dp=d_p
	bp=b_p
	fw=fwidth
	dx=d_x
	dy=d_y
	low=lower
	up=upper
	suf=suffix

list1 = mktemp('list1.tmp.')
list2 = mktemp('list2.tmp.')

i1=1
i2=1

list=listtmp
while(fscan(list,inimg)==1){
	imgets(inimg,'BIN-FCT1')
	xbin=int(imgets.value)
	imgets(inimg,'BIN-FCT2')
	ybin=int(imgets.value)
	xbin=1
	ybin=1
	imgets(inimg,'EXPTIME')
	e_time=int(imgets.value)
	imgets(inimg,'i_naxis1')
	xsize=int(imgets.value)
	imgets(inimg,'i_naxis2')
	ysize=int(imgets.value)
	imgets(inimg,'DATE-OBS')
	obsdate=imgets.value
	
	if(e_time==e_1){
  	  print(inimg,>>list1)
	  img1[i1]=inimg
	  i1=i1+1
	}
 	else if(e_time==e_2){
  	  print(inimg,>>list2)
	  img2[i2]=inimg
	  i2=i2+1
	}
}

ave1='tmp_ave'//e_1//'_CCD'//'_'//xbin//'x'//ybin
ave2='tmp_ave'//e_2//'_CCD'//'_'//xbin//'x'//ybin


### makeing temporal average
    printf("\n#### Making Temporal Averaged Flat w/%ds exposure\n",e_1)
    imcombine('@'//list1, ave1,combine='average',reject='avsigclip')
    printf("\n#### Making Temporal Averaged Flat w/%ds exposure\n",e_2)
    imcombine('@'//list2, ave2,combine='average',reject='avsigclip')


### stability check
printf("\n#### Difference of Intensity\n")

y=ysize/2

list='database/id'//ave2
if(access('database/id'//ave2)){
        printf('>>> Database file '//'database/id'//ave2//'\
	already exists!\n\
        Do you want to delete it? <y/n> : ')
        while(scan(ans)==0) {}
        if(ans) {delete('database/id'//ave2)}
}

identify(ave2,section='middle line',databas='database',\   
         coordli='',nsum=1,match=-3.,\
         maxfeat=50,zwidth=100,fwidth=fw,cradius=20.,functio='legendre',\
         order=3,niterate=5,low_rej=3.,high_rej=3.,\
         grow=0.,ftype='emission', mode='ql',thresho=0,autowr+)


while(fscan(list,temp1,temp2,temp3,temp4,temp5,temp6)!=6) {}
center[1]=temp2
j=2
while(fscan(list,temp1,temp2,temp3,temp4,temp5,temp6)==6 ){
	center[j]=temp2
	j =j+1
}
jmax=j

printf("  # IMAGES\n")
for(i=1;i<i2;i=i+1){
  printf("      #%02d  %s\n",i,img2[i])
}
printf("\n")


printf("    X     MEAN   ")
for(i=1;i<i2;i=i+1){
  printf("  #%02d ",i)
}
printf("\n")



lampstab='lampstab_'//obsdate//'.xy'
if(access(lampstab)){
        printf('>>> File %s already exists!\n\
        Do you want to delete it? <y/n> : ', lampstab)
        while(scan(ans)==0) {}
        if(ans) {delete(lampstab)}
}

for(j=1;j<jmax;j=j+1){
	x=center[j]
	imstat(ave2//'['//x-dp/2//':'//x+dp/2//','//y-dp//':'//y+dp//']',\
	    field='mean', format-) |scan(ave_cnt)

        printf(" %4d  %9.2f ",x,ave_cnt)

        for(i=1;i<i2;i=i+1){
	   imstat(img2[i]//'['//x-dp/2//':'//x+dp/2//','//y-dp//':'//y+dp//']',\
	   field='mean', format-) |scan(cnt[i])
	   resi[i]=(cnt[i]-ave_cnt)/ave_cnt*100
           if((resi[i]<-bp) || (resi[i]>bp)){
 	     printf("%5.2f*",resi[i])
           }
           else{
	     printf("%5.2f ",resi[i])
	   }
	   if(j==7){
	   	imgets(img2[i],'MJD')
		mjd=imgets.value
		printf("%s  %5.2f\n",mjd,resi[i],>>lampstab)
	   }
	 }
	 printf("\n")

}

imdelete(ave1)
imdelete(ave2)

list1r = mktemp('list1r.tmp.')
list2r = mktemp('list2r.tmp.')

print('### Please Reply Which Set Should be Used for Your Caliblation.')

for(i=1;i<i2;i=i+1){
	printf('>>> Do you want to use #%02d? <y/n> : ',i)
	while(scan(ans)==0) {}
	if(ans){
	  print(img1[i],>>list1r)
	  print(img2[i],>>list2r)
        }
}

printf("\n")

ave1='ave'//e_1//'_CCD'//'_'//xbin//'x'//ybin//'-'//obsdate
if(access(ave1//'.fits')){
        printf('>>> Averaged Flat %s already exists.\n', ave1
        printf('Do you want to delete it? <y/n> : ')
        while(scan(ans)==0) {}
        if(ans) {imdelete(ave1)}
}
ave2='ave'//e_2//'_CCD'//'_'//xbin//'x'//ybin//'-'//obsdate
if(access(ave2//'.fits')){
        printf('>>> Averaged Flat %s already exists.\n', ave2
        printf('Do you want to delete it? <y/n> : ')
        while(scan(ans)==0) {}
        if(ans) {imdelete(ave2)}
}
diff='diff'//e_2//'-'//e_1//'_CCD'//'_'//xbin//'x'//ybin//'-'//obsdate
if(access(diff//'.fits')){
        printf('>>> Difference Image %s already exists.\n', diff
        printf('Do you want to delete it? <y/n> : ')
        while(scan(ans)==0) {}
        if(ans) {imdelete(diff)}
}

tmpimg = mktemp('linear.tmp.')

### makeing average
    printf("\n#### Making Averaged Flat w/%ds exposure\n",e_1)
    imcombine('@'//list1r, ave1,combine='average',reject='avsigclip')
    printf("\n#### Making Averaged Flat w/%ds exposure\n",e_2)
    imcombine('@'//list2r, ave2,combine='average',reject='avsigclip')

    printf("\n#### Making Difference [F_%d  - F_%d * (%d/%d)] \n",\
	e_2,e_1,e_2,e_1)
    imarith(ave1, "*",real(e_2)/real(e_1),tmpimg)
    imarith(ave2, "-",tmpimg,diff)
    printf(" --- Resultant Image = %s \n",diff)
    imdelete(tmpimg)

diff_txt=diff//suf//'.xy'
if(access(diff_txt)){
        printf('>>> Resultant Txt file %s is already exists!\n', diff_txt)
        printf('Do you want to delete it? <y/n> : ')
        while(scan(ans)==0) {}
        if(ans) {delete(diff_txt)}
}

for(ix=dx;ix<xsize;ix=ix+dx){
    if((ix<1100/xbin)||(ix>1120/xbin)){
      for(iy=dy;iy<ysize;iy=iy+dy){
        listpix(ave2//'['//ix//':'//ix//','//iy//':'//iy//']',wcs='physical') \
	  | scan(temp1, ave_cnt)
        if((ave_cnt>low) && (ave_cnt<up)){
          listpix(diff//'['//ix//':'//ix//','//iy//':'//iy//']',wcs='physical') \
	    | scan(temp1, diff_cnt)
	  if(ix!=440){
            printf("%.2f %.2f\n",ave_cnt,diff_cnt,>>diff_txt)
	  }
	  else{
            printf("[%d, %d]  %.2f %.2f\n",ix, iy, ave_cnt,diff_cnt)
	  }
	  if(diff_cnt<-5e3) printf("%d  %d  %f\n",ix,iy,diff_cnt)
      	}
      }
    }
}

progend:

delete(list1)
delete(list2)
delete(list1r)
delete(list2r)

bye
end
