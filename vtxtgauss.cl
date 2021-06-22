procedure vtxtgauss(xyfile,w0,wc_g,i_g,fwhm_g,vmin,vmax)

string xyfile {prompt="OUTPUT Super Mongo File Name to be contoured"}
real w0    {prompt="Wavelength Center for velocity [A]"}
real wc_g  {prompt="Gaussian Central wavelength [A]"}
real i_g   {prompt="Gaussian Amplitude"}
real fwhm_g{prompt="Gaussian FWHM [A]"}
real vmin  {prompt="Minimum Velocity for output [km/s]"}
real vmax  {prompt="Minimum Velocity for output [km/s]"}

begin

string fname
real refw, wg, ig, fwhm, v0, v1
bool ans

fname = xyfile
refw=w0
wg=wc_g
ig=i_g
fwhm=fwhm_g
v0=vmin
v1=vmax


task	$vgauss = ("$"//osfn("hdshome$")//"vgauss")

if(access(fname//'.xy'))
{
    printf('!!! file %s already exsists !!!\n',fname//'.xy')
    printf('>>> Delete this file? <y/n> >>> ',)
    while( scan( ans ) == 0 )
       print( ans )
    print( '' )
    if(ans) delete(fname//'.xy')
    else bye
}


vgauss(fname//'.xy',refw,wg,ig,fwhm,v0,v1)


bye
end
	   




