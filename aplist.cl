procedure aplist(inimage)
string inimage {prompt = "Input image"}
#int order {prompt = "Order Number of image"}
#int ypix  {prompt = "Y Pixel Number of image"}
begin

string	inimg, temp1, temp2, aho
int ord,yp,i
real wave1, wave2

inimg  = inimage
#ord = order
#yp = ypix

imgets(inimg,'i_naxis2')
ord = int(imgets.value)

imgets(inimg,'i_naxis1')
yp = int(imgets.value)

for(i=1;i<=ord;i=i+1){
 temp1=mktemp("temp1.")
 temp2=mktemp("temp2.")

 listpix(inimg//"[1,"//i//"]", wcs="world", v-, > temp1)
 listpix(inimg//"["//yp//","//i//"]", wcs="world", v-, > temp2)

 list=temp1
 while(fscan(list,wave1)==1){
  printf("%2d  %10.4f", i, wave1)
 }
 delete(temp1)

 list=temp2
 while(fscan(list,wave2)==1){
  printf("  %10.4f\n", wave2)
 }
 delete(temp2)

}


bye
end
