##################################################################
# Seimei GAOES-RV : OverScan
# version 0.1
#  Only for 1x1 binning
#   Added scanning along Y-axis due to CCD trouble
#                           25-02-2022  by A.Tajitsu
# task overscan = path$gaoes_overscan.cl
##################################################################

procedure gaoes_overscan (inimage, outimage)

string inimage	{prompt="Input images"}
string outimage	{prompt="Output images\n"}
real   gain1=1.92    {prompt="Conversion Factor for Amp1"}
real   gain2=1.95    {prompt="Conversion Factor for Amp2"}

struct *list0
struct *list1
struct *list2

begin
	string inimg,outimg
	string inimg0
	string tmp0,tmp1,tmp2,tmp3,tmp4

	int w_o, h_o, w_i, h_i
	int x_o1l, x_o1r, x_i1l, x_i1r, x_o2l, x_o2r
	int x_o3l, x_o3r, x_i2l, x_i2r, x_o4l, x_o4r
	int y_ib, y_it, y_ob, y_ot
	real cf1, cf2
	real os1_level,os2_level,os3_level,os4_level
	real os1_sigma,os2_sigma,os3_sigma,os4_sigma
	real os1, os2
	
#====== IRAF version check =======	
	string tmpver1, tmpver2, tmpver3, tmpver4, vertxt1, vertxt2, vertxt3
	int majver, subver
	bool newiraf
	task $awk = $foreign

	tmpver1 = mktemp("tmpver1")
	tmpver2 = mktemp("tmpver2")
	tmpver3 = mktemp("tmpver3")
	tmpver4 = mktemp("tmpver4")
	vertxt1=envget("version")
	printf("  IRAF version = %s\n", vertxt1)
	print(vertxt1, >tmpver1)
	awk("-F' V'","'{print $2}'", tmpver1, > tmpver2)
	awk("-F'.'","'{print $1}'", tmpver2, > tmpver3)
	awk("-F'.'","'{print $2}'", tmpver2, > tmpver4)
	list=tmpver3
	while(fscan(list,vertxt2)==1){
	  majver=int(vertxt2)
	}
	list=tmpver4
	while(fscan(list,vertxt3)==1){
	  subver=int(vertxt3)
	}
	delete(tmpver1)
	delete(tmpver2)
	delete(tmpver3)
	delete(tmpver4)
	printf("    major = %d  /  sub = %d\n", majver, subver)

	if(majver>2){
	  newiraf = yes
	}
	else if (subver>=17){
	  newiraf = yes
	}
	else{
	  newiraf = no
	}
#====== end of IRAF version check ========
	
	################### CCD Format ##################
	w_o = 50
	h_o = 49

	w_i = 1024
	h_i = 4102

	x_o1l = 1
	x_o1r = w_o
	x_i1l = x_o1r+1
	x_i1r = x_o1r+w_i
	x_o2l = x_i1r+1
	x_o2r = x_i1r+w_o

	x_o3l = x_o2r+1
	x_o3r = x_o2r+w_o
	x_i2l = x_o3r+1
	x_i2r = x_o3r+w_i
	x_o4l = x_i2r+1
	x_o4r = x_i2r+w_o

	y_ib = 2
	y_it = y_ib-1+h_i
	y_ob = y_it+1
	y_ot = y_it+h_o

	cf1=gain1
	cf2=gain2
	

	tmp3 = mktemp("tmp$tmp3")
	sections(inimage, option="fullname", > tmp3)
	list0 = tmp3
	tmp4 = mktemp("tmp$tmp4")
	sections(outimage, option="fullname", > tmp4)
	list1 = tmp4

	while( (fscan(list0,inimg) != EOF) && (fscan(list1,outimg) != EOF))
	{
	if((access(outimg))||(access(outimg//'.fits'))){
		imdelete(outimg)
	}
	
        # Bug fix for IRAF v2.16
	inimg0=mktemp("tmp$tmp00")
	imcopy(inimg,inimg0,ver-)


	# calculate average pixel value of overscan region
	tmp0 = mktemp("tmp$tmp0")
	imstat(images=inimg0//"["//x_o1l//":"//x_o1r//","//y_ib//":"//y_ot//"]",fields="mean,stddev",format-, > tmp0)
	list2=tmp0
	while(fscan(list2,os1_level,os1_sigma)!=EOF){}
	del(tmp0)

	tmp0 = mktemp("tmp$tmp0")
	imstat(images=inimg0//"["//x_o2l//":"//x_o2r//","//y_ib//":"//y_ot//"]",fields="mean,stddev",format-, > tmp0)
	list2=tmp0
	while(fscan(list2,os2_level,os2_sigma)!=EOF){}
	del(tmp0)

	os1=(os1_level+os2_level)/2.

	tmp0 = mktemp("tmp$tmp0")
	imstat(images=inimg0//"["//x_o3l//":"//x_o3r//","//y_ib//":"//y_ot//"]",fields="mean,stddev",format-, > tmp0)
	list2=tmp0
	while(fscan(list2,os3_level,os3_sigma)!=EOF){}
	del(tmp0)

	tmp0 = mktemp("tmp$tmp0")
	imstat(images=inimg0//"["//x_o4l//":"//x_o4r//","//y_ib//":"//y_ot//"]",fields="mean,stddev",format-, > tmp0)
	list2=tmp0
	while(fscan(list2,os4_level,os4_sigma)!=EOF){}
	del(tmp0)

	os2=(os3_level+os4_level)/2.

	# print overscan level / stddev
	print("Overscan [1] mean / stddev of ",inimg," = ",os1_level,"/ ",os1_sigma)
	print("Overscan [2] mean / stddev of ",inimg," = ",os2_level,"/ ",os2_sigma)
	print("   Average Level for Amp1 = ",os1, " ADU = ", os1*cf1, "e-" )
	print("   Readout Noise for Amp1 = ",(os1_sigma+os2_sigma)/2., " ADU = ", (os1_sigma+os2_sigma)/2.*cf1, "e-" )
	print("Overscan [3] mean / stddev of ",inimg," = ",os3_level,"/ ",os3_sigma)
	print("Overscan [4] mean / stddev of ",inimg," = ",os4_level,"/ ",os4_sigma)
	print("   Average Level for Amp2 = ",os2, " ADU = ", os2*cf2, "e-" )
	print("   Readout Noise for Amp2 = ",(os3_sigma+os4_sigma)/2., " ADU = ", (os3_sigma+os4_sigma)/2.*cf2, "e-" )

	# copy the real image region
	tmp1 = mktemp("home$tmp1")
	tmp2 = mktemp("home$tmp2")

	imcopy(inimg0//"["//x_i1l//":"//x_i1r//","//y_ib//":"//y_it//"]", tmp1, verbose-)
	imcopy(inimg0//"["//x_i2l//":"//x_i2r//","//y_ib//":"//y_it//"]", tmp2, verbose-)

	# overscan subtraction	
	imarith(operand1=tmp1,op="-",operand2=os1,result=tmp1,pixtype="r")
	imarith(operand1=tmp2,op="-",operand2=os2,result=tmp2,pixtype="r")

	# gain correction
	imarith(operand1=tmp1,op="*",operand2=cf1,result=tmp1,pixtype="r")
	imarith(operand1=tmp2,op="*",operand2=cf2,result=tmp2,pixtype="r")

	# join images
	tmp0 = mktemp("tmp$tmp0")
	print(tmp1, >> tmp0)
	print(tmp2, >> tmp0)
	if(newiraf){	
	  imjoin(input="@"//tmp0, output=outimg, joindim=1, outtype="double")
	}
	else{
	  imjoin(input="@"//tmp0, output=outimg, join_dim=1, ver-)
	}

	# correct header
#	hedit(outimg, fields="N2XIS1", value=oimgmax1, ver-, show-)
#	hedit(outimg, fields="PRD-RNG1", value=oimgmax1, ver-, show-)
#	hedit(outimg, fields="GAIN", value="1.00", ver-, show-)
#        hedit(outimg,'HQ_OS',"done",add+,del-, ver-,show-,update+)

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
