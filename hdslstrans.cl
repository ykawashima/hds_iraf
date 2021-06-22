# Procedure for correcting the misalignment between grating and ccd
#
# copyright : A. Tajitsu (2001/05/07)
#
procedure hdslstrans(inimage,outimage)
string inimage {prompt = "input image"}
string outimage {prompt = "output image"}
int len_blk {prompt = "Size in pixels of internal subraster"}

begin
#
# variables
#
string inim,outim
int len

inim = inimage
outim = outimage
len = len_blk

imtrans(inimage,outimage,len_blk=len,mode=q)

hedit(outimage,'DISPAXIS','2',add-,del-,ver-,show-,update+)

#
bye
end
