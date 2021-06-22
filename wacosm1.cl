procedure wacosm(in_f,out_f)
#Input/Output 
 string in_f {prompt = 'Input frame name'}
 string out_f {prompt = 'Output frame name'}
 real base {prompt = 'Baseline'}
 real lower_imr {prompt = 'Lower limit  of replacement window'}
 real upper_imr {prompt = 'Upper limit  of replacement window'}

begin
string inf,outf
string base1,base2,base3,base_med
   inf = in_f
   outf = out_f

#temporary files
   base1 = "tmp1"
   base2 = "tmp2"
   base3 = "tmp3"
   base_med = "tmp_med"


print("imarith: ",inf, " + ", base, " => ",base1)
imarith(operand1=inf,op='+',operand2=base,result=base1)
median(input=base1,output=base_med,xwindow=3,ywindow=3) 
imarith(operand1=base1,op='/',operand2=base_med,result=base2)
imreplace(images=base2,value=1.,lower=lower_imr,upper=upper_imr)
imarith(operand1=base2,op='*',operand2=base_med,result=base3)
print("imarith: ",base3, " - ", base, " => ",outf)
imarith(operand1=base3,op='-',operand2=base,result=outf)
#
imdel(images=base1)
imdel(images=base2)
imdel(images=base3)
imdel(images=base_med)
end

