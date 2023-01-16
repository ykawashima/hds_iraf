##################################################################
# Subaru HDS : OverScan
# version 2.0.0
#  Originaly developped by S.Kawanomoto
#   Added scanning along Y-axis due to CCD trouble
#                           26-09-2019  by A.Tajitsu
#   Bug fix for IRAF v2.16  07-12-2012  by A.Tajitsu
#       IRAF v2.16 cannot recognize pixel values after [0]  (ex. IMAGE[0][1:512,1:1024])
#   Bug fix for pyraf  10-27-2011  by A.Tajitsu
# task overscan = path$overscan.cl
##################################################################

procedure overscan (inimage, outimage)

string inimage	{prompt="Input images"}
string outimage	{prompt="Output images\n"}
bool   yscan=no {prompt="Scan along Y-axis? [y/n]"}
int    ywin=3   {prompt="Pixels for Smoothing Y-axis pattern\n"}

struct *list0
struct *list1
struct *list2

begin
	int  imgmin2,imgmax2
	
	int  limgmin1,limgmax1,lovsmin1,lovsmax1
	real lgain
	int  rimgmin1,rimgmax1,rovsmin1,rovsmax1
	real rgain

	int  oimgmin1,oimgmax1, oimgmin
	int  olimgmax1,orimgmin1

	real lovslevel,rovslevel
	real lovssigma,rovssigma

	string inimg,outimg
	string inimg0
	string tmp0,tmp1,tmp2,tmp3,tmp4
        string  tmplos1, tmplosb, tmplos2, tmplost, tmplosl
        string  tmpros1, tmprosb, tmpros2, tmprost, tmprosl

	tmp3 = mktemp("tmp$tmp3")
	sections(inimage, option="fullname", > tmp3)
	list0 = tmp3
	tmp4 = mktemp("tmp$tmp4")
	sections(outimage, option="fullname", > tmp4)
	list1 = tmp4

	while( (fscan(list0,inimg) != EOF) && (fscan(list1,outimg) != EOF))
	{
	# image starts from 1
	imgmin2  = 1
	limgmin1 = 1
	oimgmin  = 1

        # Bug fix for IRAF v2.16
	inimg0=mktemp("tmp$tmp00")
	imcopy(inimg,inimg0,ver-)

	# get parameters from image header
	imgets(image=inimg0, param="N2XIS2")
	imgmax2  = int(imgets.value)

	imgets(image=inimg0, param="H_OSMIN1")
	lovsmin1 = int(imgets.value)
	imgets(image=inimg0, param="H_GAIN1")
	lgain    = real(imgets.valu)

	imgets(image=inimg0, param="N2XIS1")
	rimgmax1 = int(imgets.value)
	imgets(image=inimg0, param="H_OSMAX1")
	rovsmax1 = int(imgets.value)
	imgets(image=inimg0, param="H_GAIN2")
	rgain    = real(imgets.value)

	# calculate the rest parameters
	limgmax1 = lovsmin1 - 1 
	rimgmin1 = rovsmax1 + 1
	lovsmax1 = rimgmax1 / 2
	rovsmin1 = lovsmax1 + 1

	oimgmax1 = limgmax1 + rimgmax1 - rovsmax1
#	olimgmax1= limgmax
#	orimgmin1= olimgmax + 1

	# not to use the next line ... to avoid negative tail of strong pixel
	lovsmin1 = lovsmin1 + 1
	rovsmax1 = rovsmax1 - 1

if(yscan){	
##### for Bad Images
        printf("Creating Left Overscan Img ... \n")

	tmplosl = mktemp("tmp$tmplosl")
	for(i=lovsmin1;i<lovsmax1+1;i=i+1){
	    	printf("%s[%d,*]\n",inimg0,i,>>tmplosl)
        }

	tmplos1 = mktemp("tmp$tmplos1")
	imcombine("@"//tmplosl,tmplos1,combine="average",reject="minmax",mode="ql")
	tmplosb = mktemp("tmp$tmplosb")
	boxcar(tmplos1,tmplosb,xwindow=ywin,ywindow=ywin, boundar='nearest')

        printf(" stacking ... \n")
	del(tmplosl)
	tmplosl = mktemp("tmp$tmplosl")
	for(i=limgmin1;i<limgmax1+1;i=i+1){
	    	print(tmplosb,>>tmplosl)
        }

	tmplos2 = mktemp("tmp$tmplos2")
	imstac("@"//tmplosl, tmplos2)

        printf(" rotating ... \n")
	tmplost = mktemp("tmp$tmplost")
	imtranspose(tmplos2, tmplost)
	
	printf("done!\n")
        printf("Creating Right Overscan Img ... \n")

	tmprosl = mktemp("tmp$tmprosl")
	for(i=rovsmin1;i<rovsmax1+1;i=i+1){
	    	printf("%s[%d,*]\n",inimg0,i,>>tmprosl)
        }

	tmpros1 = mktemp("tmp$tmpros1")
	imcombine("@"//tmprosl,tmpros1,combine="average",reject="minmax",mode="ql")
	tmprosb = mktemp("tmp$tmprosb")
	boxcar(tmpros1,tmprosb,xwindow=ywin,ywindow=ywin, boundar='nearest')

        printf(" stacking ... \n")
	del(tmprosl)
	tmprosl = mktemp("tmp$tmprosl")
	for(i=limgmin1;i<limgmax1+1;i=i+1){
	    	print(tmprosb,>>tmprosl)
        }

	tmpros2 = mktemp("tmp$tmpros2")
	imstac("@"//tmprosl, tmpros2)

        printf(" rotating ... \n")
	tmprost = mktemp("tmp$tmprost")
	imtranspose(tmpros2, tmprost)

	printf("done!\n")

#####
}
else{
	# calculate average pixel value of overscan region
	tmp0 = mktemp("tmp$tmp0")
	imstat(images=inimg0//"["//lovsmin1//":"//lovsmax1//","//imgmin2//":"//imgmax2//"]",fields="mean,stddev",format-, > tmp0)
	list2=tmp0
	while(fscan(list2,lovslevel,lovssigma)!=EOF){}
	del(tmp0)

	tmp0 = mktemp("tmp$tmp0")
	imstat(images=inimg0//"["//rovsmin1//":"//rovsmax1//","//imgmin2//":"//imgmax2//"]",fields="mean,stddev",format-, > tmp0)
	list2 = tmp0
	while(fscan(list2,rovslevel,rovssigma)!=EOF){}
	del(tmp0)

	# print overscan level / stddev
	print("Overscan mean / stddev of ",inimg," = ",lovslevel,"/ ",lovssigma,rovslevel,"/ ",rovssigma)
}

	# copy the real image region
	tmp1 = mktemp("home$tmp1")
	tmp2 = mktemp("home$tmp2")

	imcopy(inimg0//"["//limgmin1//":"//limgmax1//","//imgmin2//":"//imgmax2//"]", tmp1, verbose-)
	imcopy(inimg0//"["//rimgmin1//":"//rimgmax1//","//imgmin2//":"//imgmax2//"]", tmp2, verbose-)

	# overscan subtraction	
if(yscan){
	imarith(operand1=tmp1,op="-",operand2=tmplost,result=tmp1,pixtype="r")
	imarith(operand1=tmp2,op="-",operand2=tmprost,result=tmp2,pixtype="r")
	imdelete(tmplos1)
	imdelete(tmplosb)
	imdelete(tmplos2)
	del(tmplosl)
	imdelete(tmplost)
	imdelete(tmpros1)
	imdelete(tmprosb)
	imdelete(tmpros2)
	del(tmprosl)
	imdelete(tmprost)
}
else{
	imarith(operand1=tmp1,op="-",operand2=lovslevel,result=tmp1,pixtype="r")
	imarith(operand1=tmp2,op="-",operand2=rovslevel,result=tmp2,pixtype="r")
}

	# gain correction
	imarith(operand1=tmp1,op="*",operand2=lgain,result=tmp1,pixtype="r")
	imarith(operand1=tmp2,op="*",operand2=rgain,result=tmp2,pixtype="r")

	# join images
	tmp0 = mktemp("tmp$tmp0")
	print(tmp1, >> tmp0)
	print(tmp2, >> tmp0)
	imjoin(input="@"//tmp0, output=outimg, join_dim=1, ver-)

	# correct header
	hedit(outimg, fields="N2XIS1", value=oimgmax1, ver-, show-)
	hedit(outimg, fields="PRD-RNG1", value=oimgmax1, ver-, show-)
	hedit(outimg, fields="GAIN", value="1.00", ver-, show-)
        hedit(outimg,'HQ_OS',"done",add+,del-, ver-,show-,update+)

	# clean up
	del(tmp0)
	imdel(inimg0, ver-, >& "dev$null")
	imdel(tmp1, ver-, >& "dev$null")
	imdel(tmp2, ver-, >& "dev$null")
	}
	# clean up
	del(tmp3)
	del(tmp4)
end
