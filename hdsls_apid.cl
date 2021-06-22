# Procedure for correcting the misalignment between grating and ccd
#
# copyright : A.Tajitsu (2001/5/7)
#
procedure hdsls_apid(inimg, outimg)
 string inimg   {prompt= "input ThAr image"}
 string outimg  {prompt= "output 2D ThAr image\n"}
 bool   overw=yes  {prompt = 'Overwrite exsiting images? <y/n>\n'}

 string ref_wv1  {prompt= "Ecidentified (1D) reference spectra\n"}
 string ref_ap {prompt= "Aperture reference image"}
 string ref_ec  {prompt= "Extracted image of Aperture reference\n"}

 int lower  {prompt= "Lower aperture limit relative to center"}
 int upper  {prompt= "Upper aperture limit relative to center"}
 int xorder=2 {prompt= "X (dispersion) order for fitcoords"}
 int yorder=2 {prompt= "Y (along slit) order for fitcoords"}
 int step=2 {prompt= "Step in lines/columns/bands for tracing an image\n"}

begin
#
# variables
#
string inimage, outimage, wref, ref, refx
int low, upp, stp
int i, i_ord,j, xo, yo
string tmp
bool ow

inimage  = inimg
outimage = outimg
wref     = ref_wv1
ref      = ref_ap
refx     = ref_ec

ow=overw

low = lower
upp = upper
stp = step
xo = xorder
yo = yorder

imgets(refx,'i_naxis2')
i_ord=int(imgets.value)

for(i=1;i<=i_ord;i=i+1)
{
    if(access(outimage//'_a'//i//'.fits')){
       if(ow){
          imdelete(outimage//'_a'//i)
       }
       else{
          printf("!!! Cannot overwrite %s\n",outimage//'_a'//i//'.fits')
          printf("!!! ABORT !!!\n")
          bye
       }
    }
     

     apall(input=inimage,output=outimage//'_a'//i,\
      apertur=i,\
      format='multispec',reference=ref,profile=ref,nfind=2,\
      interac-,recente-,resize+,\
      edit+,trace-,fittrac-,extract+,extras-,review-,\
      b_funct='chebyshev',b_order=1,b_niter=3,\
      b_low_r=3,b_high_=3,b_sample='*',\
      width=30,radius=30,thresho=0,\
      ylevel=INDEF,avglimi+,\
      t_niter=3,t_low_r=3,t_high_=3,t_order=4,t_funct='legendre',\
      t_nsum=10,t_step=3,\
      find=no,llimit=low,ulimit=upp,\
      lower=low,upper=upp,\
      nsubaps=upp-low)

#      hedit(outimage//'_a'//i,"CRPIX1",1,del+,add-,ver-,show-,update+)
#      hedit(outimage//'_a'//i,"APNUM*",0,del+,add-,ver-,show-,update+)
#      hedit(outimage//'_a'//i,"WAT*",0,del+,add-,ver-,show-,update+)
#      hedit(outimage//'_a'//i,"BAND*",0,del+,add-,ver-,show-,update+)
#      hedit(outimage//'_a'//i,"DISPAXIS",1,del-,add+,ver-,show-,update+)

     imgets(outimage//'_a'//i,'APNUM1')
     tmp=imgets.value

### Overwrite Aperture Info
     for(j=2;j<(upp-low+1);j=j+1)
     {
         hedit(outimage//'_a'//i,"APNUM"//j,tmp,del-,add-,ver-,show-,update+)
     }

}

          
for(i=1;i<=i_ord;i=i+1)
{
   refspectra(input=outimage//'_a'//i, referen=wref,\
	apertur='',refaps='',ignorea-,select='interp',\
	sort='',group='',time-,timewra=17.,\
	override+,confirm-,assign+,verbose-,answer+)

    if(access(outimage//'_ad'//i//'.fits')){
       if(ow){
          imdelete(outimage//'_ad'//i)
       }
       else{
          printf("!!! Cannot overwrite %s\n",outimage//'_ad'//i//'.fits')
          printf("!!! ABORT !!!\n")
          bye
       }
    }

    dispcor(input=outimage//'_a'//i,output=outimage//'_ad'//i,\
       	lineari+,table='',w1=INDEF,w2=INDEF,dw=INDEF,nw=INDEF,\
	log-,flux-,blank=0.,samedis-,global-,ignorea-,confirm-,listonl-,\
	verbose+)

      hedit(outimage//'_ad'//i,"CRPIX1",1,del+,add-,ver-,show-,update+)
      hedit(outimage//'_ad'//i,"APNUM*",0,del+,add-,ver-,show-,update+)
      hedit(outimage//'_ad'//i,"WAT*",0,del+,add-,ver-,show-,update+)
      hedit(outimage//'_ad'//i,"BAND*",0,del+,add-,ver-,show-,update+)
      hedit(outimage//'_ad'//i,"DISPAXIS",1,del-,add+,ver-,show-,update+)

   identify(images=outimage//'_ad'//i,\
 	section='middle line',databas='database',\
	coordli='linelists$thar.dat',nsum=10,match=1.,\
	maxfeat=1000,fwidth=4.,cradius=5.,functio='chebyshev',\
	order=4,niterate=5,low_rej=3.,high_rej=3.,grow=0.,\
	ftype='emission',thresh=10,autowrite+,mode=mode )

   reidentify(referenc=outimage//'_ad'//i,\
	images=outimage//'_ad'//i,\
	section='middle line',interac-,\
        newaps-,overrid+,refit+,trace+,addfeat-,\
	step=stp,nsum=stp,shift=0.,nlost=5,cradius=4.,\
	thresho=0.,match=20.,maxfeat=1000,\
	minsep=2.,coordli='linelists$thar.dat',\
	databas='database',ver+,answer=no,\
	logfile="", mode=mode )

    if(access('database/fc'//outimage//'_ad'//i))
    {
	 del('database/fc'//outimage//'_ad'//i)
    }
    fitcoords(outimage//'_ad'//i,\
	fitname=outimage//'_ad'//i,databas='database',interac+,\
	functio='legendre',xorder=xo,yorder=yo,combine+,mode=mode )

}

bye
end
