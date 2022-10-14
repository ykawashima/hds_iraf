# Procedure for Extracting and Flatfielding IS spectra
#   Use only apnormalized flat
#
# copyright : A.Tajitsu (2013/7/9)
# !!!  It's important to use apall with                      !!!
# !!!          "llimit=(pix) ulimit=(pix+1) ylebel=INDEF"    !!!
# !!!    to extract 1-pixel along a reference aperture.      !!!
#
procedure gaoes_ecf(inimg,outimg)
file inimg   {prompt= "input image"}
file outimg  {prompt= "output image\n"}
string flatimg {prompt= "ApNormalized flat image"}
string thar2d  {prompt= "2D ThAr image"}
string thar1d  {prompt= "1D wavelength-calibrated ThAr image"}
int st_x=500  {prompt ="Start pixel to measure mean value"}
int ed_x=3500  {prompt ="End pixel to measure mean value\n"}

begin
#
# variables
#
string inimage, outimage, flat, thar, thar1
int i, ysize
real fmean[200]
string tmp_2df, tmp_1d, tmp_thar, tmp_list
#
#
#
inimage = inimg
outimage = outimg
flat = flatimg
thar2 = thar2d
thar1 = thar1d
#
# start
#

imgets(inimage,'i_naxis2')
ysize=int(imgets.value)

tmp_2df = mktemp('tmp.gaoes_ecf.2Dobj_f.')
imarith(inimage, "/", flat, tmp_2df)

tmp_1d = mktemp('tmp.gaoes_ecf.1Dobj_.')
tmp_thar = mktemp('tmp.gaoes_ecf.1Dthar_.')

tmp_list = mktemp('tmp.gaoes_ecf.list')

for(i=1;i<ysize+1;i=i+1)
{
   printf("### IMSTAT for Flat Image ###\n")
   imstat(image=flat//"["//st_x//":"//ed_x//","//i//"]", \
            field='mean', format-) | scan(fmean[i])

   imcopy(tmp_2df//"[*,"//i//"]", tmp_1d//i)
   imarith(tmp_1d//i, "*", fmean[i], tmp_1d//i//"_f")

   imcopy(thar2//"[*,"//i//"]", tmp_thar//i)

   printf("### ECreIdentify for ThAr Image ###\n")
   ecreidentify(tmp_thar//i, referen=thar1, shift=0, cradius=5.,\
   	        thresho=10., refit+)
   printf("### Refspectra ###\n")
   refspectra(input=tmp_1d//i//"_f",answer=yes,referen=tmp_thar//i,\
                sort=" ", group=" ")
   printf("### DispCor ###\n")
   dispcor(input=tmp_1d//i//"_f",output=tmp_1d//i//"_fw", log-)

   print(tmp_1d//i//"_fw", >> tmp_list)
}

scombine("@"//tmp_list,outimage,combine="sum",group="all", reject="none")

bye
end
