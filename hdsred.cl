#------------------------------------------------------------
#	Subaru HDS echelle spectrum reduction package
#                    HDSRED
#
#                      A.Tajitsu   finally revised 2002.05.30
#------------------------------------------------------------
procedure hdsred(inlist)

string inlist {prompt="List of INPUT images"}
#int fltmax=50000 {prompt="MAX count of Flat image"}
#string outlist {prompt="List of OUTPUT images"}

begin

string list_in, listtmp, list_out, temp, fname, d_type
string rawcmp, rawflt, rawobj
string bs_cmp, tr_flt, tr_obj, tr_cmp
string ff_obj, ff_cmp, dc_obj, wc_obj, dc_cmp
string stcol, edcol, strow, edrow
string biasfile, flatfile, flatlist
string list0tmp, list1tmp
int i, i_all, i_cmp, i_flt, i_obj
int flat_mean
bool ans,flg1,flg2

biasfile = 'std_bias.fits'

list_in = inlist
#flat_mean = fltmax

listtmp = mktemp('list.in.tmp.')
sed('s/.fits//g',list_in,>listtmp)

print('')
print('############################################')
print('#  Overscan                                #')
print('############################################')

list0tmp = mktemp('list.in.tmp.')
sed('s/\$/.fits\[0\]/g',listtmp,>list0tmp)
list1tmp = mktemp('list.out.tmp.')
sed('s/\$/.os.fits/g',listtmp,>list1tmp)

flg1=no
flg2=no

list = list1tmp
while(fscan(list,temp)==1)
{
    if(access(temp))
    {
       flg1=yes
    }
    else
    {
       flg2=yes
    }
}

if(flg1)
{
    if(flg2){
       list = list1tmp
       while(fscan(list,temp)==1)
       {
         if(access(temp)) imdelete(temp)
       }
       overscan('@'//list0tmp,'@'//list1tmp)
    } 
    else
    {
#     skip
       printf('### Overscanned files already exists.\n')
       printf('###Skipping Overscan...\n')    }
}
else
{        
    overscan('@'//list0tmp,'@'//list1tmp)
}

print('')
print('############################################')
print('#  Makeing BIAS Image                      #')
print('############################################')

#hdslsmkbias(inlist=list1tmp)
print('  Skipping...')

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
       imgets(fname,'i_title')
       temp=imgets.value
       display(fname,1,fill+,zscale+)
       printf( '>>>>> OBJECT Image --%s-- >>>>> %s\n',fname,temp )
#       while( scan( temp ) == 0 )
#        print( temp )
#       hedit(fname,'i_title',temp,add-,del-,ver-,show-,update+)
       hedit(fname,'DISPAXIS',2,add-,del-,ver-,show-,update+,mode=mode )
       print(fname,>> rawobj)
       i_obj=i_obj+1
       }
       
       i_all=i_cmp+i_flt+i_obj
}

print('')
print('############################################')
print('#  Linearity Correction                        #')
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
    if(access(temp//'.bs.fits')) imdelete(temp//'.bs.fits')
#    imarith(temp,'-',biasfile,temp//'.bs.fits',ver-,noact-)
    hdslinear(temp,temp//'.bs.fits')
    hedit(temp//'.bs.fits','HISTORY','linearity-corrected',add+,del-,ver-,show-,update+)
    printf(".")
}

list = rawcmp
while(fscan(list,temp)==1)
{
    if(access(temp//'.bs.fits')) imdelete(temp//'.bs.fits')
#    imarith(temp,'-',biasfile,temp//'.bs.fits',ver-,noact-)
    imcopy(temp,temp//'.bs.fits',ver-)
    hedit(temp//'.bs.fits','HISTORY','linearity-skipped',add+,del-,ver-,show-,update+)
    printf(".")
}

list = rawobj
while(fscan(list,temp)==1)
{
    if(access(temp//'.bs.fits')) imdelete(temp//'.bs.fits')
#    imarith(temp,'-',biasfile,temp//'.bs.fits',ver-,noact-)
    hdslinear(temp,temp//'.bs.fits')
    hedit(temp//'.bs.fits','HISTORY','linearity-corrected',add+,del-,ver-,show-,update+)
    printf(".")
}

printf('\n')



print('')
print('############################################')
print('#  Making Flatfield                        #')
print('############################################')

flatfile = mktemp('flat.tmp.')
flatlist = mktemp('list.flat.tmp.')
sed('s/\$/.bs.fits/g',rawflt,>flatlist)

imcombine('@'//flatlist,flatfile//'.fits',combine='median',reject='none')

imhist(flatfile,autosca+,dev='stdgraph',listout-,logy+,\
       hist_ty='normal',top_clo-,nbins=512)
print( '>>>>> input MAX value of flat image ' )
while( scan( flat_mean ) == 0 )
        print( flat_mean )
imarith(flatfile,'/',flat_mean,flatfile,ver-,noact-)
imreplace(flatfile,value=1,imagina=0,lower=INDEF,upper=0.05,radius=0)


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
    if(access(temp//'.ff.fits')) imdelete(temp//'.ff.fits')
    imarith(temp//'.bs.fits','/',flatfile,temp//'.ff.fits',ver-,noact-)
    hedit(temp//'.ff.fits','HISTORY','flatfield',add-,del-,ver-,show-,update+)
    printf(".")
    display(temp//'.ff.fits',1,fill+,zscale+, mode=mode, >&'dev$null')
}

list = rawcmp
while(fscan(list,temp)==1)
{
    if(access(temp//'.ff.fits')) imdelete(temp//'.ff.fits')
#    imarith(temp//'.bs.fits','/',flatfile,temp//'.ff.fits',ver-,noact-)
    imcopy(temp//'.bs.fits',temp//'.ff.fits',ver-)
#    hedit(temp//'.ff.fits','HISTORY','flatfield',add-,del-,ver-,show-,update+)
    display(temp//'.ff.fits',1,fill+,zscale+, mode=mode, >&'dev$null')
}

printf("\n")


print('')
print('############################################')
print('#  Image Derotating                        #')
print('############################################')

ff_obj = mktemp('list.obj.tmp.')
dc_obj = mktemp('list.obj.tmp.')
ff_cmp = mktemp('list.comp.tmp.')

sed('s/\$/.ff/g',rawobj,>ff_obj)
sed('s/\$/.dc/g',rawobj,>dc_obj)
sed('s/\$/.ff.fits/g',rawcmp,>ff_cmp)

printf(">>> Do you want to correct ROTATION of spectrum? <y/n> : ")
while(scan(ans)!=1) {}
if(ans) hdsderotate('@'//ff_obj, '@'//dc_obj, '@'//ff_cmp)
else {
    list = rawobj
    while(fscan(list,temp)==1)
    {
        if(access(temp//'.dc.fits')) imdelete(temp//'.dc.fits')
        imtrans(temp//'.ff',temp//'.dc',len_blk=4096)
    }
}          

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
prows(temp//".dc",100,4000,wx1=0.,wx2=0.,\
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
    imcopy(temp//'.dc[*,'//strow//':'//edrow//']',\
           temp//'.tr',verbose-,mode=mode)
    hedit(temp//'.tr','HISTORY','trimming',add-,del-,ver-,show-,update+)
    printf(".")
}

list = rawcmp
while(fscan(list,temp)==1)
{
    imcopy(temp//'.dc['//strow//':'//edrow//',*]',\
           temp//'.tr',verbose-,mode=mode)
    hedit(temp//'.tr','HISTORY','trimming',add-,del-,ver-,show-,update+)
    printf(".")
}


print('')
print('############################################')
print('#  Wavelength Calibration                  #')
print('############################################')

wc_obj = mktemp('list.obj.tmp.')
tr_obj = mktemp('list.obj.tmp.')
tr_cmp = mktemp('list.comp.tmp.')

sed('s/\$/.wc.fits/g',rawobj,>wc_obj)
sed('s/\$/.tr/g',rawobj,>tr_obj)
sed('s/\$/.tr/g',rawcmp,>tr_cmp)

hdswave('@'//tr_obj,'@'//wc_obj,'@'//tr_cmp)


print('')
print('############################################')
print('#  All Procedure Has Done                  #')
print('#       HDSRED ver0.2                      #')
print('#      developed by A.Tajitsu  since2001   #')
print('############################################')


bye
end

