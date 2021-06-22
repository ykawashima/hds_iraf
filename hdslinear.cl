##################################################################
# Subaru HDS linearity conversion
#  developed by Akito Tajitsu <tajitsu@subaru.naoj.org>
#              2009.05.16 ver.2.10
#                   added 4x1B 2x4B parameters, 
#                   Bug fix in listed images management
#              2009.04.16 ver.2.00
#                   automatic parameters
#              2008.08.06 ver.1.00
#                   1st version using manual parameters
###################################################################
procedure hdslinear(inimage,outimage)
#
file	inimage		{prompt= "Input image "}
file	outimage	{prompt= "Output image \n"}

string  outtype="real"  {prompt= " Output image pixel datatype (real|auto)\n"}

bool  auto_b=yes  {prompt= " Use automatic B* parameters (yes|no)"}

real  b0=0.0		{prompt= " manual fit param B0 "}
real  b2=0.0		{prompt= " manual fit param B2 "}
real  b3=0.0		{prompt= " manual fit param B3 "}
real  b4=0.0		{prompt= " manual fit param B4 "}
real  b5=0.0		{prompt= " manual fit param B5 "}
real  b6=0.0		{prompt= " manual fit param B6 "}
real  b7=0.0		{prompt= " manual fit param B7 "}
real  b8=0.0		{prompt= " manual fit param B8 "}
real  b9=0.0		{prompt= " manual fit param B9 \n"}

struct *list0
struct *list1
#

begin
string 	inimg, outimg
string a
real  b, c, d, e, f, g, h, i, j
string expr

string tmp3, tmp4

real r11_2,r11_3,r11_4,r11_5,r11_6,r11_7,r11_8,r11_9
real r21_2,r21_3,r21_4,r21_5,r21_6,r21_7,r21_8,r21_9
real r22_2,r22_3,r22_4,r22_5,r22_6,r22_7,r22_8,r22_9
real r24_2,r24_3,r24_4,r24_5,r24_6,r24_7,r24_8,r24_9
real r41_2,r41_3,r41_4,r41_5,r41_6,r41_7,r41_8,r41_9
real r44_2,r44_3,r44_4,r44_5,r44_6,r44_7,r44_8,r44_9

real b11_2,b11_3,b11_4,b11_5,b11_6,b11_7,b11_8,b11_9
real b21_2,b21_3,b21_4,b21_5,b21_6,b21_7,b21_8,b21_9
real b22_2,b22_3,b22_4,b22_5,b22_6,b22_7,b22_8,b22_9
real b24_2,b24_3,b24_4,b24_5,b24_6,b24_7,b24_8,b24_9
real b41_2,b41_3,b41_4,b41_5,b41_6,b41_7,b41_8,b41_9
real b44_2,b44_3,b44_4,b44_5,b44_6,b44_7,b44_8,b44_9

string r11_c, r21_c, r22_c, r24_c, r41_c, r44_c
string b11_c, b21_c, b22_c, b24_c, b41_c, b44_c
string comtxt

int bin1, bin2, ccd


#################################
# Automatic Parameters
# Red CCD (CCD1)

### Red CCD 1x1 bin  
r11_c='Parameters for Red CCD 1x1bin : measured on 2009/02/03'
# <dy^2>=7.2119377e+01
# |r|=0.97045886
r11_2 = -9.6823939e-07
r11_3 =  2.3434520e-10
r11_4 = -1.4175356e-14
r11_5 =  4.4542967e-19
r11_6 = -8.1763008e-24
r11_7 =  8.7749327e-29 
r11_8 = -5.0860064e-34
r11_9 =  1.2273852e-39

### Red CCD 2x1 bin  
r21_c='Parameters for Red CCD 2x1bin : measured on 2009/02/03'
# <dy^2>=8.0225602e+01
# |r|=0.97179847
r21_2 = -2.7629947e-06
r21_3 =  5.1440847e-10
r21_4 = -2.9215381e-14
r21_5 =  8.4490112e-19
r21_6 = -1.4021438e-23
r21_7 =  1.3532646e-28
r21_8 = -7.0746507e-34
r21_9 =  1.5505315e-39

### Red CCD 2x2 bin  
r22_c='Parameters for Red CCD 2x2bin : measured on 2009/02/03'
# <dy^2>=7.5022239e+01
# |r|=0.97641471
r22_2 = -3.1226151e-06
r22_3 =  5.8252838e-10
r22_4 = -3.4269779e-14
r22_5 =  1.0399943e-18
r22_6 = -1.8265468e-23
r22_7 =  1.8763189e-28
r22_8 = -1.0478168e-33
r22_9 =  2.4582068e-39

### Red CCD 2x4 bin  
r24_c='Parameters for Red CCD 2x4bin : measured on 2009/02/03'
# <dy^2>=7.6595253e+01
# |r|=0.97529335
r24_2 = -2.8528732e-06
r24_3 =  5.2087438e-10
r24_4 = -2.9445433e-14
r24_5 =  8.5280778e-19
r24_6 = -1.4240244e-23
r24_7 =  1.3884683e-28
r24_8 = -7.3595199e-34
r24_9 =  1.6407086e-39

### Red CCD 4x1 bin  
r41_c='Parameters for Red CCD 4x1bin : measured on 2009/02/03'
# <dy^2>=7.4624315e+01
# |r|=0.97772020
r41_2 = -2.8167430e-06
r41_3 =  4.9245638e-10
r41_4 = -2.4512440e-14
r41_5 =  5.7702891e-19
r41_6 = -6.9786360e-24
r41_7 =  3.9091775e-29
r41_8 = -4.2969340e-35
r41_9 = -2.8403124e-40

### Red CCD 4x4 bin  
r44_c='Parameters for Red CCD 4x4bin : measured on 2009/02/03'
# <dy^2>=7.9974977e+01
# |r|=0.97908163
r44_2 = -3.1641202e-06
r44_3 =  5.9223507e-10
r44_4 = -3.3274607e-14
r44_5 =  9.4739949e-19
r44_6 = -1.5449714e-23
r44_7 =  1.4629632e-28
r44_8 = -7.4897020e-34
r44_9 =  1.6039831e-39


#################################
# Automatic Parameters
# Blue CCD (CCD2)

### Blue CCD 1x1 bin  
b11_c='Parameters for Blue CCD 1x1bin : measured on 2009/02/03'
# <dy^2>=71.397778e+01
# |r|=0.98954012
b11_2 = -3.8367214e-07
b11_3 =  1.4620104e-10
b11_4 = -7.1203412e-15
b11_5 =  1.7216029e-19
b11_6 = -2.4041836e-24
b11_7 =  1.9623589e-29
b11_8 = -8.6702747e-35
b11_9 =  1.5957180e-40

### Blue CCD 2x1 bin  
b21_c='Parameters for Blue CCD 2x1bin : measured on 2009/02/03'
# <dy^2>=7.0217478e+01
# |r|=0.99070936
b21_2 = -8.3128848e-07
b21_3 =  1.6613441e-10
b21_4 = -4.7080893e-15
b21_5 = -3.3782728e-21
b21_6 =  2.1982253e-24
b21_7 = -3.9795147e-29
b21_8 =  2.9406962e-34
b21_9 = -8.1006694e-40

### Blue CCD 2x2 bin  
b22_c='Parameters for Blue CCD 2x2bin : measured on 2009/02/03'
# <dy^2>=7.0847602e+01
# |r|=0.99081607
b22_2 = -7.2850038e-07
b22_3 =  1.4636319e-10
b22_4 = -2.9742925e-15
b22_5 = -8.0584724e-20
b22_6 =  4.0469784e-24
b22_7 = -6.3861521e-29
b22_8 =  4.5426672e-34
b22_9 = -1.2367311e-39

### Blue CCD 2x4 bin  
b24_c='Parameters for Blue CCD 2x4bin : measured on 2009/05/14'
# <dy^2>=6.9410816e+01
# |r|=0.99086189
b24_2 = -1.0278111e-06
b24_3 =  2.0759443e-10
b24_4 = -7.6242810e-15
b24_5 =  9.2266191e-20
b24_6 =  5.2346784e-25
b24_7 = -2.3577454e-29
b24_8 =  2.1182827e-34
b24_9 = -6.3899159e-40

### Blue CCD 4x1 bin  
b41_c='Parameters for Blue CCD 4x1bin : measured on 2009/05/14'
# <dy^2>=6.9331226e+01
# |r|=0.99110285
b41_2 = -9.1789776e-07
b41_3 =  1.8148583e-10
b41_4 = -4.4087838e-15
b41_5 = -5.9936799e-20
b41_6 =  4.0361619e-24
b41_7 = -6.6444272e-29
b41_8 =  4.7850548e-34
b41_9 = -1.3063059e-39

### Blue CCD 4x4 bin  
b44_c='Parameters for Blue CCD 4x4bin : measured on 2009/02/03'
# <dy^2>=6.8880542e+01
# |r|=0.99188753
b44_2 = -9.2670609e-07
b44_3 =  1.7101338e-10
b44_4 = -3.5228211e-15
b44_5 = -8.6687757e-20
b44_6 =  4.4032595e-24
b44_7 = -6.8545547e-29
b44_8 =  4.7937480e-34
b44_9 = -1.2824365e-39


#################################


 tmp3 = mktemp("tmp$tmp3")
 sections(inimage, option="fullname", > tmp3)
 list0 = tmp3
 tmp4 = mktemp("tmp$tmp4")
 sections(outimage, option="fullname", > tmp4)
 list1 = tmp4

  while( (fscan(list0,inimg) != EOF) && (fscan(list1,outimg) != EOF)){
    
## Get Header Information
    imgets(inimg,'BIN-FCT1')
    bin1=int(imgets.value)
    imgets(inimg,'BIN-FCT2')
    bin2=int(imgets.value)
    imgets(inimg,'DET-ID')
    ccd=int(imgets.value)

    if(auto_b){
## --- Set Automatic Parameters
	b=0

	if(ccd==2){
####  Blue CCD
	    if(bin1==4){
		if(bin2==4){
#  4x4 Blue
		    c=b44_2
		    d=b44_3
		    e=b44_4
		    f=b44_5
		    g=b44_6
		    h=b44_7
		    i=b44_8
		    j=b44_9
		    comtxt=b44_c
		}
		else{
#  4x1 Blue
		    c=b41_2
		    d=b41_3
		    e=b41_4
		    f=b41_5
		    g=b41_6
		    h=b41_7
		    i=b41_8
		    j=b41_9
		    comtxt=b41_c
		}
	    }
	    else if (bin1==2){
		if(bin2==4){
#  2x4 Blue
		    c=b24_2
		    d=b24_3
		    e=b24_4
		    f=b24_5
		    g=b24_6
		    h=b24_7
		    i=b24_8
		    j=b24_9
		    comtxt=b24_c
		}
		else if(bin2==2){
#  2x4 Blue
		    c=b22_2
		    d=b22_3
		    e=b22_4
		    f=b22_5
		    g=b22_6
		    h=b22_7
		    i=b22_8
		    j=b22_9
		    comtxt=b22_c
		}
		else{
#  2x1 Blue
		    c=b21_2
		    d=b21_3
		    e=b21_4
		    f=b21_5
		    g=b21_6
		    h=b21_7
		    i=b21_8
		    j=b21_9
		    comtxt=b21_c
		}
	    }
	    else{
#  1x1 Blue
		c=b11_2
		d=b11_3
		e=b11_4
		f=b11_5
		g=b11_6
		h=b11_7
		i=b11_8
		j=b11_9
		comtxt=b11_c
	    }
	}
	else{
####  Red CCD
	    if(bin1==4){
		if(bin2==4){
#  4x4 Red
		    c=r44_2
		    d=r44_3
		    e=r44_4
		    f=r44_5
		    g=r44_6
		    h=r44_7
		    i=r44_8
		    j=r44_9
		    comtxt=r44_c
		}
		else{
#  4x1 Red
		    c=r41_2
		    d=r41_3
		    e=r41_4
		    f=r41_5
		    g=r41_6
		    h=r41_7
		    i=r41_8
		    j=r41_9
		    comtxt=r41_c
		}
	    }
	    else if (bin1==2){
		if(bin2==4){
#  2x4 Red
		    c=r24_2
		    d=r24_3
		    e=r24_4
		    f=r24_5
		    g=r24_6
		    h=r24_7
		    i=r24_8
		    j=r24_9
		    comtxt=r24_c
		}
		else if(bin2==2){
#  2x4 Red
		    c=r22_2
		    d=r22_3
		    e=r22_4
		    f=r22_5
		    g=r22_6
		    h=r22_7
		    i=r22_8
		    j=r22_9
		    comtxt=r22_c
		}
		else{
#  2x1 Red
		    c=r21_2
		    d=r21_3
		    e=r21_4
		    f=r21_5
		    g=r21_6
		    h=r21_7
		    i=r21_8
		    j=r21_9
		    comtxt=r21_c
		}
	    }
	    else{
#  1x1 Red
		c=r11_2
		d=r11_3
		e=r11_4
		f=r11_5
		g=r11_6
		h=r11_7
		i=r11_8
		j=r11_9
	        comtxt=r11_c
	    }
	}
    }
    else{
## Use Manual Parameters
	b=b0
	c=b2
	d=b3
	e=b4
	f=b5
	g=b6
	h=b7
	i=b8
	j=b9
	comtxt='Using manual parameters for hdslinear.cl'
    }


    expr="a + b -c*2*a**2 -d*4/3*a**3 -e*8/7*a**4 "\
    //" -f*16/15*(a/1e4)**5*1e20 -g*32/31*(a/1e4)**6*1e24"\
    //" -h*64/63*(a/1e4)**7*1e28"\
    //" -i*128/127*(a/1e4)**8*1e32 -j*256/255*(a/1e4)**9*1e36"

   if(auto_b){
     printf("## %s -> %s   [Auto] CCD%d %dx%dbin\n", inimg, outimg,\
                           ccd, bin1,bin2);
   }
   else{
     printf("## %s -> %s   [Manual]\n", inimg, outimg);
   }
   imexpr (expr=expr,output=outimg,\
   a=inimg,b=b,c=c,d=d,e=e,f=f,g=g,h=h,i=i,j=j,\
   dims="auto",intype="auto",outtype=outtype,refim="auto")

   hedit(outimg,'H_LIN0','Linearity corrected by hdslinear.cl',add+,del-,\
           ver-,show-,update+)
   hedit(outimg,'H_LIN1',comtxt,add+,del-,\
           ver-,show-,update+)
   hedit(outimg,'H_LIN-B0',b,add+,del-,\
           ver-,show-,update+)
   hedit(outimg,'H_LIN-B2',c,add+,del-,\
           ver-,show-,update+)
   hedit(outimg,'H_LIN-B3',d,add+,del-,\
           ver-,show-,update+)
   hedit(outimg,'H_LIN-B4',e,add+,del-,\
           ver-,show-,update+)
   hedit(outimg,'H_LIN-B5',f,add+,del-,\
           ver-,show-,update+)
   hedit(outimg,'H_LIN-B6',g,add+,del-,\
           ver-,show-,update+)
   hedit(outimg,'H_LIN-B7',h,add+,del-,\
           ver-,show-,update+)
   hedit(outimg,'H_LIN-B8',i,add+,del-,\
           ver-,show-,update+)
   hedit(outimg,'H_LIN-B9',j,add+,del-,\
           ver-,show-,update+)
   hedit(outimg,'HQ_LN',"done",add+,del-, ver-,show-,update+)
 }

 delete(tmp3)
 delete(tmp4)

bye
end
