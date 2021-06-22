procedure wacosm3(in_f1,out_f1,in_f2,out_f2,in_f3,out_f3)
#Input/Output 
 string in_f1 {prompt = 'Input frame name (1)'}
 string out_f1 {prompt = 'Output frame name (1)'}
 string in_f2 {prompt = 'Input frame name (2)'}
 string out_f2 {prompt = 'Output frame name (2)'}
 string in_f3 {prompt = 'Input frame name (3)'}
 string out_f3 {prompt = 'Output frame name (3)'}
 real base {prompt = 'Baseline'}
 real lower_imr {prompt = 'Lower limit  of replacement window'}
 real upper_imr {prompt = 'Upper limit  of replacement window'}

begin
string inf1,outf1,inf2,outf2,inf3,outf3
string a1,a2,a3,b1,b2,b3,c1,c2,c3,amed
   inf1 = in_f1
   outf1 = out_f1
   inf2 = in_f2
   outf2 = out_f2
   inf3 = in_f3
   outf3 = out_f3

#temporary files
   a1 = "a1.imh"
   b1 = "b1.imh"
   c1 = "c1.imh"
   a2 = "a2.imh"
   b2 = "b2.imh"
   c2 = "c2.imh"
   a3 = "a3.imh"
   b3 = "b3.imh"
   c3 = "c3.imh"
   amed = "tmp_med.imh"
#a?: OBJ+base
#b?: a?/median -> imreplace
#c?: b?*median

print("imarith: ",inf1," ",inf2," ",inf3," + ", base, " => ",a1," ",a2," ",a3)
imarith(operand1=inf1,op='+',operand2=base,result=a1)
imarith(operand1=inf2,op='+',operand2=base,result=a2)
imarith(operand1=inf3,op='+',operand2=base,result=a3)
#
imcomb(input=a1//","//a2//","//a3,output=amed,combine='median')
#
print("imarith: ",a1," ",a2," ",a3," / ", amed, " => ",b1," ",b2," ",b3)
imarith(operand1=a1,op='/',operand2=amed,result=b1)
imarith(operand1=a2,op='/',operand2=amed,result=b2)
imarith(operand1=a3,op='/',operand2=amed,result=b3)
#
print("imreplasing ... ")
imreplace(images=b1,value=1.,lower=lower_imr,upper=upper_imr)
imreplace(images=b2,value=1.,lower=lower_imr,upper=upper_imr)
imreplace(images=b3,value=1.,lower=lower_imr,upper=upper_imr)
#
print("imarith: ",b1," ",b2," ",b3," * ", amed, " => ",c1," ",c2," ",c3)
imarith(operand1=b1,op='*',operand2=amed,result=c1)
imarith(operand1=b2,op='*',operand2=amed,result=c2)
imarith(operand1=b3,op='*',operand2=amed,result=c3)
#
print("imarith: ",c1," ", c2," ", c3," - ", base, " => ",outf1," ", outf2," ", outf3)
imarith(operand1=c1,op='-',operand2=base,result=outf1)
imarith(operand1=c2,op='-',operand2=base,result=outf2)
imarith(operand1=c3,op='-',operand2=base,result=outf3)
#
imdel(images=a1)
imdel(images=a2)
imdel(images=a3)
imdel(images=amed)
imdel(images=b1)
imdel(images=b2)
imdel(images=b3)
imdel(images=c1)
imdel(images=c2)
imdel(images=c3)
end
