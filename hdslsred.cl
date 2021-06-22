#------------------------------------------------------------
#	Subaru HDS long-slit reduction package
#                    HDSLSRED
#
#                      A.Tajitsu   finally revised 2003.01.17
#------------------------------------------------------------
procedure hdslsred(inlist,order)

string inlist {prompt="List of INPUT images"}
string order  {prompt="Order Initial"}
bool flag_b {prompt="Using bias frame? (y/n)"}
string bias {prompt="Filename of Creating Bias image"}
string flat {prompt="Filename of Creating Flat image"}
string comp {prompt="Filename of Creating Comparison image"}
bool disp_1 {prompt="Display Images in Data grouping? (y/n)"}
bool or_bs {prompt="Override existing BIAS Subtracted data? (y/n)"}
bool or_ff {prompt="Override existing Flat-Fielded data? (y/n)"}
bool d_trim {prompt="Trimming along the Dispersion Direction? (y/n)"}
bool bad_fix {prompt="Fixing Bad pixels using imreplace? (y/n)"}
int rplow {prompt="Imreplace lower ADU for bad pixels"}
int rphigh {prompt="Imreplace lower ADU for bad pixels"}
bool sub_cmp {prompt="Subtract BIAS frame from Th-Ar (y/n)"}
bool easy {prompt= "Easy mode for apall? <y/n> "}
string observa {prompt="Observatory"}
#int fltmax=50000 {prompt="MAX count of Flat image"}
#string outlist {prompt="List of OUTPUT images"}
				   
begin

string list_in, listtmp, list_out, temp, fname, d_type
bool ovr_bs, ovr_ff, dtrim, disp1
string obsv
string rawcmp, rawflt, rawobj
string bs_cmp, tr_flt, tr_obj, tr_cmp
string ff_obj, ff_cmp, dc_obj, wc_obj, dc_cmp
int stcol, edcol, strow, edrow
string biasfile, flatfile, flatlist
string list0tmp, list1tmp,  ftitle
string hist_rec
int i, i_all, i_cmp, i_flt, i_obj, i_tmp
int flat_mean
bool ans,flg1,flg2
bool b_bias
string pre_img[100], pre_typ, pre_sl, pre_obj
string slength
int ref_i
int xlen, ylen
string cmpfile
string ord
int r_low, r_high
bool f_fix,s_cmp
bool m_easy

list_in = inlist
ord = "."//order
b_bias= flag_b
flatfile = flat
cmpfile = comp
biasfile = bias
disp1 = disp_1
ovr_bs = or_bs
ovr_ff = or_ff
dtrim = d_trim
f_fix=bad_fix
r_low=rplow
r_high=rphigh
s_cmp=sub_cmp
m_easy=easy
obsv = observa
#flat_mean = fltmax

listtmp = mktemp('list.in.tmp.')
sed('s/.fits//g',list_in,>listtmp)

printf("##### Image List ######\n")
printf("No.  File Name         Data Type     Slit Length \n")

i=1
list=listtmp
while(fscan(list,temp)==1)
{
  pre_img[i]=temp
  imgets(temp//"[0]",'DATA-TYP')
  pre_typ=imgets.value
  imgets(temp//"[0]",'OBJECT')
  pre_obj=imgets.value
  imgets(temp//"[0]",'SLT-LEN')
  pre_sl=imgets.value
  printf("%2d   %s    %s     %12s    %s\n",i,pre_img[i],pre_obj,pre_typ,pre_sl)
  i=i+1;
}
i_all=i
i_tmp=i_all-1


printf("\n")
printf(">>> Do you appoint a reference frame for order trace? (y/n) : ")
while(scan(ans)!=1) {}
if(ans){
  printf(">>> Please Input the number of the reference frame [1:%d] : ",i_tmp)
  while( scan( ref_i ) == 0 )
          print( ref_i )

  hedit(pre_img[ref_i]//"[0]",'DATA-TYP','OBJECT',add-,del-,ver-,show-,update+,mode=mode )
  listtmp = mktemp('list.in.tmp.')
  print(pre_img[ref_i],>>listtmp)
  for(i=1;i<i_all;i=i+1){
     if(i!=ref_i) print(pre_img[i],>>listtmp)
  }
  list_in=listtmp
  listtmp = mktemp('list.in.tmp.')
  sed('s/.fits//g',list_in,>listtmp)
}



print('')
print('############################################')
print('#  Overscan                                #')
print('############################################')

list0tmp = mktemp('list.in.tmp.')
sed('s/\$/.fits\[0\]/g',listtmp,>list0tmp)
list1tmp = mktemp('list.out.tmp.')
sed('s/\$/.os.fits/g',listtmp,>list1tmp)

list=listtmp

while(fscan(list,temp)==1)
{
   if(!access(temp//".os.fits")){
     overscan(temp//".fits[0]",temp//".os.fits")
   }
}

imgets(temp//".os.fits",'i_naxis1')
xlen=int(imgets.value)
imgets(temp//".os.fits",'i_naxis2')
ylen=int(imgets.value)


if(b_bias||s_cmp){
  print('')	
  print('############################################')
  print('#  Makeing BIAS Image                      #')
  print('############################################')

  hdslsmkbias(inlist=list1tmp,outfile=biasfile)
  
}

print('')
print('############################################')
print('#  First Scanning -- Data Grouping         #')
print('############################################')

rawcmp = mktemp('list.comp.tmp.')
rawflt = mktemp('list.flat.tmp.')
rawobj = mktemp('list.obj.tmp.')

i_cmp=0
i_flt=0
i_obj=0

listtmp = mktemp('list.in.tmp.')
sed('s/.fits//g',list1tmp,>listtmp)

list = listtmp

while(fscan(list,temp)==1)
{
       fname=temp
       imgets(fname,'DATA-TYP')
       d_type=imgets.value
       if(d_type=='FLAT')
       {
       hedit(fname,'i_title','Flat',add-,del-,ver-,show-,update+)
       hedit(fname,'DISPAXIS',2,add-,del-,ver-,show-,update+,mode=mode )
       print(fname,>> rawflt)
       i_flt=i_flt+1
       }
       else if(d_type=='COMPARISON')
       {	
       hedit(fname,'i_title','Comparison',add-,del-,ver-,show-,update+)
       hedit(fname,'DISPAXIS',2,add-,del-,ver-,show-,update+,mode=mode )
       print(fname,>> rawcmp)
       i_cmp=i_cmp+1
       }
       else if(d_type=='BIAS')
       {
       hedit(fname,'i_title','Bias',add-,del-,ver-,show-,update+)
       hedit(fname,'DISPAXIS',2,add-,del-,ver-,show-,update+,mode=mode )
       }
       else if(d_type=='OBJECT')
       {
       if(disp1) display(fname,1,fill+,zscale+)

       imgets(fname,'i_title')
       ftitle=imgets.value
       printf( '>>>>> OBJECT Name of  --%s-- >>>>> %s\n',fname,ftitle)
#       while( scan( temp ) == 0 )
#       print( temp )
#       hedit(fname,'i_title',temp,add-,del-,ver-,show-,update+)
       hedit(fname,'DISPAXIS',2,add-,del-,ver-,show-,update+,mode=mode )
       print(fname,>> rawobj)
       i_obj=i_obj+1
       }
       
       i_all=i_cmp+i_flt+i_obj
}

if(b_bias){
print('')
print('############################################')
print('#  Bias Subtructing                        #')
print('############################################')

i=0
while(i<i_all)
{
     printf("*")
     i=i+1
}
printf("\n")

list = rawflt
while(fscan(list,temp)==1)
{
  if(access(temp//'.bs.fits')){
    if(ovr_bs){
     imdelete(temp//'.bs.fits')
     imarith(temp,'-',biasfile,temp//'.bs.fits',ver-,noact-)
     hedit(temp//'.bs.fits','HISTORY','bias-subtruct',add+,del-,\
           ver-,show-,update+)
     printf(".")
    }
    else{
     printf("-")
    }
  }
  else{
    imarith(temp,'-',biasfile,temp//'.bs.fits',ver-,noact-)
    hedit(temp//'.bs.fits','HISTORY','bias-subtruct',add+,del-,\
           ver-,show-,update+)
    printf(".")
  }
}

list = rawcmp
while(fscan(list,temp)==1)
{
  if(access(temp//'.bs.fits')){
    if(ovr_bs){
      imdelete(temp//'.bs.fits')
      imarith(temp,'-',biasfile,temp//'.bs.fits',ver-,noact-)
      hedit(temp//'.bs.fits','HISTORY','bias-subtruct',\
            add+,del-,ver-,show-,update+)
      printf(".")
    }
    else{
      printf("-")
    }
  }
  else{
    imarith(temp,'-',biasfile,temp//'.bs.fits',ver-,noact-)
    hedit(temp//'.bs.fits','HISTORY','bias-subtruct',\
          add+,del-,ver-,show-,update+)
    printf(".")
  }
}

list = rawobj
while(fscan(list,temp)==1)
{
  if(access(temp//'.bs.fits')){
    if(ovr_bs){  
      imdelete(temp//'.bs.fits')
      imarith(temp,'-',biasfile,temp//'.bs.fits',ver-,noact-)
      hedit(temp//'.bs.fits','HISTORY','bias-subtruct',\
            add+,del-,ver-,show-,update+)
      printf(".")
    }
    else{
      printf("-")
    }
  }
  else{
    imarith(temp,'-',biasfile,temp//'.bs.fits',ver-,noact-)
    hedit(temp//'.bs.fits','HISTORY','bias-subtruct',\
          add+,del-,ver-,show-,update+)
    printf(".")
  }
}

printf('\n')
}
else{
print('')
print('############################################')
print('#  Skipping Bias Subtructing               #')
print('############################################')
i=0
while(i<i_all)
{
     printf("*")
     i=i+1
}
printf("\n")

list = rawflt
while(fscan(list,temp)==1)
{
  if(access(temp//'.bs.fits')){
    if(ovr_bs){
     imdelete(temp//'.bs.fits')
     imcopy(temp,temp//'.bs.fits',ver-)
     hedit(temp//'.bs.fits','HISTORY','bias-skipping',add+,del-,\
           ver-,show-,update+)
     printf(".")
    }
    else{
     printf("-")
    }
  }
  else{
    imcopy(temp,temp//'.bs.fits',ver-)
    hedit(temp//'.bs.fits','HISTORY','bias-skipping',add+,del-,\
          ver-,show-,update+)
    printf(".")
  }
}

list = rawcmp
while(fscan(list,temp)==1)
{
  if(access(temp//'.bs.fits')){
    if(ovr_bs){
      imdelete(temp//'.bs.fits')
      if(s_cmp){
        imarith(temp,'-',biasfile,temp//'.bs.fits',ver-,noact-)
        hedit(temp//'.bs.fits','HISTORY','bias-subtruct',\
              add+,del-,ver-,show-,update+)
        printf("s")
      }
      else{
        imcopy(temp,temp//'.bs.fits',ver-)
        hedit(temp//'.bs.fits','HISTORY','bias-skipping',add+,del-,\
              ver-,show-,update+)
        printf(".")
      }
    }
    else{
      printf("-")
    }
  }
  else{
      if(s_cmp){
        imarith(temp,'-',biasfile,temp//'.bs.fits',ver-,noact-)
        hedit(temp//'.bs.fits','HISTORY','bias-subtruct',\
              add+,del-,ver-,show-,update+)
        printf("s")
      }
      else{
      imcopy(temp,temp//'.bs.fits',ver-)
      hedit(temp//'.bs.fits','HISTORY','bias-skipping',add+,del-,\
          ver-,show-,update+)
      printf(".")
      }
  }
}

list = rawobj
while(fscan(list,temp)==1)
{
  if(access(temp//'.bs.fits')){
    if(ovr_bs){  
      imdelete(temp//'.bs.fits')
      imcopy(temp,temp//'.bs.fits',ver-)
      hedit(temp//'.bs.fits','HISTORY','bias-skipping',add+,del-,\
            ver-,show-,update+)
      printf(".")
    }
    else{
      printf("-")
    }
  }
  else{
    imcopy(temp,temp//'.bs.fits',ver-)
    hedit(temp//'.bs.fits','HISTORY','bias-skipping',add+,del-,\
          ver-,show-,update+)
    printf(".")
  }
}

printf('\n')
}



print('')
print('############################################')
print('#  Making Flatfield                        #')
print('############################################')

# flatfile = mktemp('flat.tmp.')
flatlist = mktemp('list.flat.tmp.')
sed('s/\$/.bs.fits/g',rawflt,>flatlist)

if(access(flatfile//'.fits')){
  printf(">>> Flat Image %s already exists!!\n",flatfile)
  printf(">>> Do you want to use this image? <y/n> : ")
  while(scan(ans)!=1) {}
  if(!ans){
    imdelete(flatfile)
    imcombine('@'//flatlist,flatfile//'.fits',combine='median',reject='none')

    imhist(flatfile,autosca+,dev='stdgraph',listout-,logy+,\
           hist_ty='normal',top_clo-,nbins=512)
    print( '>>>>> input MAX value of flat image ' )
    while( scan( flat_mean ) == 0 )
            print( flat_mean )
    imarith(flatfile,'/',flat_mean,flatfile,ver-,noact-)
    imreplace(flatfile,value=1,imagina=0,lower=INDEF,upper=0.05,radius=0)
  }
  else{
     printf(" ... Using existing Flat Image (%s)\n",flatfile)
  }
}
else{
  imcombine('@'//flatlist,flatfile//'.fits',combine='median',reject='none')

  imhist(flatfile,autosca+,dev='stdgraph',listout-,logy+,\
         hist_ty='normal',top_clo-,nbins=512)
  print( '>>>>> input MAX value of flat image ' )
  while( scan( flat_mean ) == 0 )
          print( flat_mean )
  imarith(flatfile,'/',flat_mean,flatfile,ver-,noact-)
  imreplace(flatfile,value=1,imagina=0,lower=INDEF,upper=0.05,radius=0)
}

#display(flatfile,2,fill+,zscale+, mode=mode, >&'dev$null')

print('')
print('############################################')
print('#  Data Trimming 1                         #')
print('############################################')


list = rawcmp
while(fscan(list,temp)==1){}

imgets(flatfile,'HISTORY')
hist_rec=imgets.value
if(hist_rec!='trimming'){
  prows(flatfile,int(ylen*0.05),int(ylen*0.95),wx1=0.,wx2=0.,\
         wy1=0.,wy2=0.,logx-,logy-,app-,mode=mode )
  print( '>>>>> Select tempolal trimming region for spatial. >>>>>' )
  print( '    shift-c: value of cursor position ' )
  print( '    return : exit to next step' )
  =gcur
  print( '>>>>> input start row to be cut ' )
  while( scan( strow ) == 0 )
          print( strow )
  print( '>>>>> input end row to be cut' )
  while( scan( edrow ) == 0 )
          print( edrow )


# Trimming along dispersion
  if(dtrim){
    pcols(flatfile//'['//strow//':'//edrow//',*]',\
		int((edrow-strow)*0.05), int((edrow-strow)*0.95),wx1=0.,wx2=0.,\
		wy1=0.,wy2=0.,logx-,logy-,app-,mode=mode )
    print( '' )
    print( '>>>>> Select trimming region for dispersion. >>>>>' )
    print( '    shift-c: value of cursor position ' )
    print( '    return : exit to next step' )
    =gcur
    print( '>>>>> input start col to be cut ' )
    while( scan( stcol ) == 0 )
          print( stcol )
    print( '>>>>> input end col to be cut' )
    while( scan( edcol ) == 0 )
          print( edcol )
    ylen=edcol-stcol+1
  }
  else{
    stcol=1
    edcol=ylen
  }


  list = rawobj
  while(fscan(list,temp)==1)
  {
    if(access(temp//ord//'.bt.fits')) imdelete(temp//ord//'.bt.fits')
    imcopy(temp//'.bs.fits['//strow//':'//edrow//','//stcol//':'//edcol//']',\
           temp//ord//'.bt.fits',verbose-,mode=mode)
    hedit(temp//ord//'.bt.fits','HISTORY','trimming',add-,del-,ver-,show-,update+)
    printf(".")
  }

  list = rawcmp
  while(fscan(list,temp)==1)
  {
    if(access(temp//ord//'.bt.fits')) imdelete(temp//ord//'.bt.fits')
    imcopy(temp//'.bs.fits['//strow//':'//edrow//','//stcol//':'//edcol//']',\
           temp//ord//'.bt.fits',verbose-,mode=mode)
    hedit(temp//ord//'.bt.fits','HISTORY','trimming',add-,del-,ver-,show-,update+)
    printf("C")
  }

  if(access(flatfile//ord//".bt.fits")) imdelete(flatfile//ord//".bt.fits")
  imcopy(flatfile//'['//strow//':'//edrow//','//stcol//':'//edcol//']',\
        flatfile//ord//".bt",verbose-,mode=mode)
  hedit(flatfile//ord//".bt",'HISTORY','trimming',add-,del-,ver-,show-,update+)
  printf("F")
 

}

print('')
print('############################################')
print('#  Flatfielding                            #')
print('############################################')


i=0
while(i<i_obj)
{
     printf("*")
     i=i+1
}
printf("\n")
	   		
list = rawobj
while(fscan(list,temp)==1)
{
    if(access(temp//ord//'.ff.fits')) imdelete(temp//ord//'.ff.fits')
    imarith(temp//ord//'.bt.fits','/',flatfile//ord//".bt",temp//ord//'.ff.fits',ver-,noact-)
    hedit(temp//ord//'.ff.fits','HISTORY','flatfield',add-,del-,ver-,show-,update+)
    if(f_fix)
    {
	imreplace(images=temp//ord//'.ff.fits', value=0.,imagina=0.,\
                  lower=INDEF,upper=r_low,radius=0.,mode=q)
	imreplace(images=temp//ord//'.ff.fits', value=0.,imagina=0.,\
                  lower=r_high,upper=INDEF,radius=0.,mode=q)
    }
    printf(".")
    display(temp//ord//'.ff.fits',1,fill+,zscale+, mode=mode, >&'dev$null')
}

list = rawcmp
while(fscan(list,temp)==1)
{
    if(access(temp//ord//'.ff.fits')) imdelete(temp//ord//'.ff.fits')
#    imarith(temp//ord//'.bt.fits','/',flatfile//ord//".bt",temp//ord//'.ff.fits',ver-,noact-)
    imcopy(temp//ord//'.bt.fits',temp//ord//'.ff.fits',ver-)
#    hedit(temp//ord//'.ff.fits','HISTORY','flatfield',add-,del-,ver-,show-,update+)
    display(temp//ord//'.ff.fits',2,fill+,zscale+, mode=mode, >&'dev$null')
}

printf("\n")


print('')
print('############################################')
print('#  Image Derotating                        #')
print('############################################')

ff_obj = mktemp('list.obj.tmp.')
dc_obj = mktemp('list.obj.tmp.')
ff_cmp = mktemp('list.comp.tmp.')

sed('s/\$/'//ord//'.ff/g',rawobj,>ff_obj)
sed('s/\$/'//ord//'.dc/g',rawobj,>dc_obj)
sed('s/\$/'//ord//'.ff.fits/g',rawcmp,>ff_cmp)

# printf(">>> Do you want to correct ROTATION of spectrum? <y/n> : ")
#while(scan(ans)!=1) {}
#if(ans)
  if(m_easy)
  {
     hdslsderotate('@'//ff_obj, '@'//dc_obj, '@'//ff_cmp, easy+)
  }
  else {
     hdslsderotate('@'//ff_obj, '@'//dc_obj, '@'//ff_cmp, easy-)
  }
#else {
#    list = rawobj
#    while(fscan(list,temp)==1)
#    {
#        if(access(temp//ord//'.dc.fits')) imdelete(temp//ord//'.dc.fits')
#         imcopy(temp//ord//'.ff',temp//ord//'.dc')
#    }
#}          

list = dc_obj
while(fscan(list,temp)==1)
{
    hedit(temp,'HISTORY','derotate',add-,del-,ver-,show-,update+)
}


print('')
print('############################################')
print('#  Data Trimming 2                         #')
print('############################################')


list = rawcmp
while(fscan(list,temp)==1){}
pcols(temp//ord//".dc",int(ylen*0.05),int(ylen*0.95),wx1=0.,wx2=0.,\
        wy1=0.,wy2=0.,logx-,logy-,app-,mode=mode )
print( '>>>>> Select trimming region for spatial. >>>>>' )
print( '    shift-c: value of cursor position ' )
print( '    return : exit to next step' )
=gcur
print( '>>>>> input start row to be cut ' )
while( scan( strow ) == 0 )
        print( strow )
print( '>>>>> input end row to be cut' )
while( scan( edrow ) == 0 )
        print( edrow )

list = rawobj
while(fscan(list,temp)==1)
{
    if(access(temp//ord//'.tr.fits')) imdelete(temp//ord//'.tr.fits')

    imcopy(temp//ord//'.dc[*,'//strow//':'//edrow//']',\
           temp//ord//'.tr',verbose-,mode=mode)
    hedit(temp//ord//'.tr','HISTORY','trimming',add-,del-,ver-,show-,update+)
    printf(".")
}

list = rawcmp
while(fscan(list,temp)==1)
{
    if(access(temp//ord//'.tr.fits')) imdelete(temp//ord//'.tr.fits')

    imcopy(temp//ord//'.dc[*,'//strow//':'//edrow//']',\
           temp//ord//'.tr',verbose-,mode=mode)
    hedit(temp//ord//'.tr','HISTORY','trimming',add-,del-,ver-,show-,update+)
    printf(".")
}


print('')
print('############################################')
print('#  Wavelength Calibration                  #')
print('############################################')

wc_obj = mktemp('list.obj.tmp.')
tr_obj = mktemp('list.obj.tmp.')
tr_cmp = mktemp('list.comp.tmp.')

sed('s/\$/'//ord//'.wc.fits/g',rawobj,>wc_obj)
sed('s/\$/'//ord//'.tr/g',rawobj,>tr_obj)
sed('s/\$/'//ord//'.tr/g',rawcmp,>tr_cmp)

if(access(cmpfile//ord//".fits")){
  printf(">>> Comparison Image %s%s already exists!!\n",cmpfile,ord)
  printf(">>> Do you want to use this image? <y/n> : ")
  while(scan(ans)!=1) {}
  if(!ans){
    imdelete(cmpfile//ord)
    imcombine('@'//tr_cmp,cmpfile//ord,combine='median',reject='none')
  }
  else{
     printf(" ... Using existing Comparison Image (%s%s)\n",cmpfile,ord)
  }
}
else{
    imcombine('@'//tr_cmp,cmpfile//ord,combine='median',reject='none')
}
tr_cmp = mktemp('list.comp.tmp.')
print(cmpfile//ord,>>tr_cmp)
hdslswave(inlist='@'//tr_obj,outlist='@'//wc_obj,complist='@'//tr_cmp)


print('')
print('################################################')
print('#  Radial Velocity Collection to Heliocentric  #')
print('################################################')

list = rawobj
while(fscan(list,temp)==1)
{
    if(access(temp//ord//'.rv.fits')) imdelete(temp//ord//'.rv.fits')

    rvhds(temp//ord//'.wc.fits', temp//ord//'.rv.fits', observa=obsv)
}


print('')
print('############################################')
print('#  All Procedure Has Done                  #')
print('#       HDSLSRED ver0.4                    #')
print('#      developed by A.Tajitsu  since2001   #')
print('############################################')


bye
end

