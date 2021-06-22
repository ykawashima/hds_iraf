procedure vsm_cont(imfile,smfile,w_c,st_x,ed_x,st_y,ed_y)

string imfile {prompt="INPUT IRAF images to be contoured"}
string smfile {prompt="OUTPUT Super Mongo File Name to be contoured"}
real w_c   {prompt="Central wavelength to be set for 0km/s"}
int st_x   {prompt="Start X pixel No. to be cutted"}
int ed_x   {prompt="End   X pixel No. to be cutted"}
int st_y   {prompt="Start Y pixel No. to be cutted"}
int ed_y   {prompt="End   Y pixel No. to be cutted"}
string floor='MIN' {prompt="minimum value to be contoured (MIN for min)"}
string ceiling='MAX' {prompt="maximum value to be contoured (MAX for max)"}
real skypix=0.138  {prompt="Spatial resolution of 1 pixel [arcsec]"}
int ncont=30  {prompt="Number of contour"}

begin

string iname,pixfile,sm_file,imdir,tmp1,tmp2,c_min,c_max,tr_tmp
int x_st,x_ed,y_st,y_ed,i_log,sm_x,sm_y,sm_lev
real t_log,w_st,w_ed,s_pix
bool ans
real w0, v_st, v_ed, c

iname=imfile
sm_file=smfile
w0=w_c
x_st=st_x
x_ed=ed_x
y_st=st_y
y_ed=ed_y
c_min=floor
c_max=ceiling
s_pix=skypix
sm_lev=ncont

c=300000.0

task	$pix2sm = ("$"//osfn("hdshome$")//"contour_sm")

if(access(sm_file//'.sm'))
{
    printf('!!! file %s already exsists !!!\n',sm_file//'.sm')
    printf('>>> Delete this file? <y/n> >>> ',)
    while( scan( ans ) == 0 )
       print( ans )
    print( '' )
    if(ans) delete(sm_file//'.sm')
    else bye
}

printf('>>>> log plot? <y/n> >>> ')
while( scan( ans ) == 0 )
   print( ans )
print( '' )

if (ans){
   i_log=2
   printf('>>>> Please Input Logarithmic Base >>> ')
   while( scan( t_log ) == 0 )
      print( t_log )
   print( '' )
}
else{
   i_log=1
   t_log=1
}   


pixfile=mktemp('tmp.sm_cont.')

listpixels(iname//'['//x_st//':'//x_ed//','//y_st//':'//y_ed//']',\
           wcs='world',formats='%g %d %g',ver-,mode=mode, > pixfile)

if(c_min=='MIN')
{
   c_min='$min'
}
if(c_max=='MAX')
{
   c_max='$max'
}

sm_x=x_ed-x_st+1
sm_y=y_ed-y_st+1
	   
pwd |scan(imdir)
#imdir='/ulgyu'//imdir

listpixels(iname//'['//x_st//','//y_st//']', wcs='world',formats='%g %g',ver-,mode=mode) | scan(w_st,tmp1,tmp2)
v_st=c/w0*(w_st-w0)

sleep(1)

listpixels(iname//'['//x_ed//','//y_st//']', wcs='world',formats='%g %g',ver-,mode=mode) | scan(w_ed,tmp1,tmp2)
v_ed=c/w0*(w_ed-w0)

pix2sm(imdir//'/'//pixfile,sm_x,sm_y,imdir//'/'//sm_file//'.dat',i_log,t_log)

printf('define file_type (\'c\')\n', > sm_file//'.sm')
printf('expand 1\n',>> sm_file//'.sm')
printf('angle 0\n',>> sm_file//'.sm')
printf('lweight 0\n',>> sm_file//'.sm')
printf('image %s %10.4f %10.4f %7.2f %7.2f\n',sm_file//'.dat',\
       v_st,v_ed,real(sm_y)*(-s_pix/2),\
       real(sm_y)*(s_pix/2), >> sm_file//'.sm')
printf('limits %10.4f %10.4f %7.2f %7.2f\n',v_st,v_ed,real(sm_y)*(-s_pix/2),\
       real(sm_y)*(s_pix/2), >> sm_file//'.sm')
printf('minmax min max\n',>> sm_file//'.sm')
printf('set lev = %s, %s, (%s-%s)/%d\n',c_min,c_max,c_max,\
                     c_min,sm_lev, >> sm_file//'.sm')
#printf('location 5000 29000 %d 25500\n', 25500-(y_ed-y_st)*150, >> sm_file//'.sm')
printf('location 5000 29000 15000 25500\n', >> sm_file//'.sm')
printf('box 1 2\n', >> sm_file//'.sm')
printf('levels lev\n', >> sm_file//'.sm')
printf('contour\n', >> sm_file//'.sm')
printf('image delete\n', >> sm_file//'.sm')
printf('expand 0.8\n', >> sm_file//'.sm')
printf('ylabel {\\bf Slit Position[arcsec]}\n', >> sm_file//'.sm')
printf('xlabel {\\bf Radial Velocity (helilocentric) [km/s]}\n', >> sm_file//'.sm')
#printf('expand 0.9\n', >> sm_file//'.sm')
#printf('relocate %f %f\n',v_st,real(sm_y)*(s_pix/1.5), >> sm_file//'.sm')
#imgets(iname,'i_title')
#tmp1=imgets.value
#imgets(iname,'DATE-OBS')
#tmp2=imgets.value
#printf('putlabel 3 {\\bf %s : %s}\n',tmp1,tmp2, >> sm_file//'.sm')

imstatistics(iname//'['//x_st//':'//x_ed//','//y_st//':'//y_ed//']',\
           fields='min,   max')

bye
end
	   
