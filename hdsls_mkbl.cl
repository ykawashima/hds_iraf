# Procedure for making blaze function 
#
# copyright : A.Tajitsu (2009/5/22)
#
procedure hdsls_mkbl(inflt, innflt, outimg)
 string inflt   {prompt= "input FLAT image"}
 string innflt  {prompt= "input Normalized FLAT image"}
 string outimg  {prompt= "output BLAZE function image\n"}

 string ref_ap  {prompt= "Aperture reference image"}
 string ref_ec  {prompt= "Extracted image of Aperture reference"}
 int lower  {prompt= "Lower aperture limit relative to center"}
 int upper  {prompt= "Upper aperture limit relative to center\n"}

 bool   wavecal  {prompt = 'Wavelength calibration? <y/n>'}
 string ref_wv  {prompt= "Reference ThAr (2D) header (before \"_adXX\")"}
 string ref_wv1  {prompt= "Ecidentified (1D) reference spectra\n"}

begin
#
# variables
#
string inflat, innflat, outimage, ref, refx, refw, refw1
bool wvflag
int low, upp
int i, i_ord, i_x, j
string tmp, blz1_tmp, blz2_tmp,  otmp, otmp2
string file_ext
real ave

inflat  = inflt
innflat  = innflt
outimage = outimg

ref      = ref_ap
refx     = ref_ec
low = lower
upp = upper

wvflag   = wavecal
refw     = ref_wv
refw1    = ref_wv1



#
# start
#

imgets(refx,'i_naxis2')
i_ord=int(imgets.value)

imgets(refx,'i_naxis1')
i_x=int(imgets.value)

blz1_tmp =mktemp('blz1.tmp')
imarith(inflat,'/', innflat, blz1_tmp,ver-,noact-)


for(i=1;i<=i_ord;i=i+1)
{
     file_ext="_a"

     blz2_tmp =mktemp('blz2.tmp')

     apall(input=blz1_tmp,output=blz2_tmp//file_ext//i,\
      apertur=i,\
      format='multispec',reference=ref,profile=ref,nfind=2,\
      interac-,recente-,resize-,\
      edit-,trace-,fittrac-,extract+,extras-,review-,\
      b_funct='chebyshev',b_order=1,b_niter=3,\
      b_low_r=3,b_high_=3,b_sample='*',\
      width=30,radius=30,thresho=0,\
      avglimi-,\
      t_niter=3,t_low_r=3,t_high_=3,t_order=4,t_funct='legendre',\
      t_nsum=10,t_step=3,\
      find=no,llimit=low,ulimit=upp,\
      lower=low,upper=upp,\
      nsubaps=upp-low, pfit='fit1d', clean-, weights='none')

     imgets(blz2_tmp//file_ext//i,'APNUM1')
     tmp=imgets.value

### Overwrite Aperture Info
     for(j=2;j<(upp-low+1);j=j+1)
     {
         hedit(blz2_tmp//file_ext//i,"APNUM"//j,tmp,del-,add-,\
		ver-,show-,update+)
     }

    if(wvflag){
      refspectra(input=blz2_tmp//file_ext//i, referen=refw1,\
		apertur='',refaps='',ignorea-,select='interp',\
		sort='',group='',time-,timewra=17.,\
		override+,confirm-,assign+,verbose-,answer+)

      dispcor(input=blz2_tmp//file_ext//i,\
		output=blz2_tmp//file_ext//'d'//i,\
      	 	lineari+,table='',w1=INDEF,w2=INDEF,dw=INDEF,nw=INDEF,\
		log-,flux-,blank=0.,samedis-,global-,ignorea-,confirm-,\
		listonl-,verbose+)
      imdelete(blz2_tmp//file_ext//i)
      file_ext=file_ext//'d'

     hedit(blz2_tmp//file_ext//i,"CRPIX1",1,del+,add-,ver-,show-,update+)
     hedit(blz2_tmp//file_ext//i,"APNUM*",0,del+,add-,ver-,show-,update+)
     hedit(blz2_tmp//file_ext//i,"WAT*",0,del+,add-,ver-,show-,update+)
     hedit(blz2_tmp//file_ext//i,"BAND*",0,del+,add-,ver-,show-,update+)
     hedit(blz2_tmp//file_ext//i,"DISPAXIS",1,del-,add+,ver-,show-,update+)

      transform(blz2_tmp//file_ext//i,blz2_tmp//file_ext//'w'//i,\
	 	fitname=refw//'_ad'//i,databas='database',\
		interpt='poly3',y1=INDEF,dy=INDEF,x1=INDEF,\
		y2=INDEF,ny=INDEF,\
		x2=INDEF,dx=INDEF,nx=INDEF,mode=mode )
      imdelete(blz2_tmp//file_ext//i)
      file_ext=file_ext//'w'
    }

    boxcar(blz2_tmp//file_ext//i, blz2_tmp//file_ext//i//'b1',
           xwindow=i_x/20, ywindow=1, boundar='nearest')
    boxcar(blz2_tmp//file_ext//i//'b1', blz2_tmp//file_ext//i//'b2',
           xwindow=i_x/20, ywindow=1, boundar='nearest')

    imstat(image=blz2_tmp//file_ext//i//'b2', field='mean',\
           format-) | scan(ave)
    imarith(blz2_tmp//file_ext//i//'b2','/', ave, outimage//file_ext//i,\
           ver-,noact-)

    imdelete(blz2_tmp//file_ext//i)
    imdelete(blz2_tmp//file_ext//i//'b1')
    imdelete(blz2_tmp//file_ext//i//'b2')
}

imdelete(blz1_tmp)

bye
end
