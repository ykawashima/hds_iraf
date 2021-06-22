##################################################################
# Subaru HDS : Heliocentric RV correction
#  developed by Akito Tajitsu <tajitsu@subaru.naoj.org>
#              2011.09.30 ver.1.00
###################################################################
procedure rvhds(inimage,outimage)
string inimage {prompt = "Input image"}
string outimage {prompt = "Output image\n"}
string observa {prompt="Observatory"}

begin

string	inimg,outimg
real	heliov
real epo
string obs

inimg  = inimage
outimg = outimage
obs=observa

imgets(inimg,"EQUINOX")
epo=real(imgets.value)
hedit(inimg,'EPOCH',epo,add+,del-,ver-,show-,update+)

# This line replace 'OBSERVAT' form  "NAOJ" to "subaru".
#   "naoj" might be too ambiguous for obsdb.
hedit(inimg,'OBSERVAT',obs,add-,del-,ver-,show-,update+)

rvcorrect(images=inimg,header+,input+,imupdate+,observa=observa)

imgets(inimg,"VHELIO")
heliov= real(imgets.value) * (-1.)

printf("vhelio = %fkm/s\n",-heliov)

dopcor(inimg, outimg, heliov, isveloc+, add-, disp+, flux-)

bye
end
