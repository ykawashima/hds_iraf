procedure wacosm(in_f,out_f)
#Input/Output 
 string in_f {prompt = 'Input frame name'}
 string out_f {prompt = 'Output frame name'}
 real base {prompt = 'Baseline'}
# real lower_imr {prompt = 'Lower limit  of replacement window'}
# real upper_imr {prompt = 'Upper limit  of replacement window'}

begin
string inf,outf
string base1,base2,base21,base22,base23,base3,base4,base_med
   inf = in_f
   outf = out_f

#temporary files
   base1 = mktemp("wacosm.tmp1")
   base2 = mktemp("wacosm.tmp2")
   base21 = mktemp("wacosm.tmp21")
   base22 = mktemp("wacosm.tmp22")
   base23 = mktemp("wacosm.tmp23")
   base3 = mktemp("wacosm.tmp3")
   base4 = mktemp("wacosm.tmp4")
   base_med = mktemp("wacosm.tmp_med")


print("imarith: ",inf, " + ", base, " => ",base1)
imarith(operand1=inf,op='+',operand2=base,result=base1)
print("median filtering =>",base_med)
median(input=base1,output=base_med,xwindow=1,ywindow=5) 
print("imarith: ",base1," / ",base_med," => ",base2)
imarith(operand1=base1,op='/',operand2=base_med,result=base2)
#imreplace(images=base2,value=1.,lower=lower_imr,upper=upper_imr)
print("lineclean")
lineclean(input=base2,output=base21,functio='spline3',order=1,low_rej=0,high_r=10,grow=0,interac=no)
print("imtranspose")
imtranspose(input=base21,output=base22,len_blk=2050)
print("lineclean")
lineclean(input=base22,output=base23,functio='spline3',order=1,low_rej=0,high_r=10,grow=0,interac=no)
print("imtranspose")
imtranspose(input=base23,output=base3,len_blk=2050)
print("imarith: ",base3," * ",base_med," => ",base4)
imarith(operand1=base3,op='*',operand2=base_med,result=base4)
print("imarith: ",base4, " - ", base, " => ",outf)
imarith(operand1=base4,op='-',operand2=base,result=outf)
#
imdel(images=base1)
imdel(images=base2)
imdel(images=base21)
imdel(images=base22)
imdel(images=base23)
imdel(images=base3)
imdel(images=base4)
imdel(images=base_med)
end
