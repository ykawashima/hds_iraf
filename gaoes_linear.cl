##################################################################
# Seimei GAOES-RV linearity conversion
#  developed by Akito Tajitsu <tajitsu@subaru.naoj.org>
#              2022.11.15 ver.0.10
#                   imported from hdslinear.cl
###################################################################
procedure gaoes_linear(inimage,outimage)
#
file	inimage		{prompt= "Input image "}
file	outimage	{prompt= "Output image \n"}

string  outtype="real"  {prompt= " Output image pixel datatype (real|auto)\n"}

bool  auto_b=yes  {prompt= " Use automatic B* parameters (yes|no)"}

real  b0=0.0		{prompt= " manual fit param B0 "}
real  b2=0.0		{prompt= " manual fit param B2 "}
real  b3=0.0		{prompt= " manual fit param B3 "}
real  b4=0.0		{prompt= " manual fit param B4 \n"}

struct *list0
struct *list1
#

begin
string 	inimg, outimg
string a
real  b, c, d, e, f, g, h, i, j
string expr

string tmp3, tmp4

real p_2,p_3,p_4

string comtxt


#################################
# Automatic Parameters
# Red CCD (CCD1)

### GAOES-RV CCD 1x1 bin  
# <dy^2>=8.8736308e+01
# |r|=2.5966708e-01
p_2 =  4.9678825e-08
p_3 = -6.7649232e-13
p_4 =  2.4144018e-18


#################################


 tmp3 = mktemp("tmp$tmp3")
 sections(inimage, option="fullname", > tmp3)
 list0 = tmp3
 tmp4 = mktemp("tmp$tmp4")
 sections(outimage, option="fullname", > tmp4)
 list1 = tmp4

  while( (fscan(list0,inimg) != EOF) && (fscan(list1,outimg) != EOF)){
    
    if(auto_b){
## --- Set Automatic Parameters
	b=0
	c=p_2
	d=p_3
	e=p_4
        comtxt='Parameters for GAOES-RV 1x1bin : measured in 2022/11/11'
    }
    else{
## Use Manual Parameters
	b=b0
	c=b2
	d=b3
	e=b4
	comtxt='Using manual parameters for gaoes_linear.cl'
    }


    expr="a + b -c*2*a**2 -d*4/3*a**3 -e*8/7*a**4 "

   if(auto_b){
     printf("## %s -> %s   [Auto] \n", inimg, outimg);
   }
   else{
     printf("## %s -> %s   [Manual]\n", inimg, outimg);
   }
   imexpr (expr=expr,output=outimg,\
   a=inimg,b=b,c=c,d=d,e=e,\
   dims="auto",intype="auto",outtype=outtype,refim="auto")

   hedit(outimg,'G_LIN0','Linearity corrected by hdslinear.cl',add+,del-,\
           ver-,show-,update+)
   hedit(outimg,'G_LIN1',comtxt,add+,del-,\
           ver-,show-,update+)
   hedit(outimg,'G_LIN-B0',b,add+,del-,\
           ver-,show-,update+)
   hedit(outimg,'G_LIN-B2',c,add+,del-,\
           ver-,show-,update+)
   hedit(outimg,'G_LIN-B3',d,add+,del-,\
           ver-,show-,update+)
   hedit(outimg,'G_LIN-B4',e,add+,del-,\
           ver-,show-,update+)
   hedit(outimg,'GQ_LN',"done",add+,del-, ver-,show-,update+)
 }

 delete(tmp3)
 delete(tmp4)

bye
end
