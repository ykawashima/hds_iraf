##################################################################
# getcount : Seimei GAOES-RV Spectrum Quick count measurement
#  developed by Akito Tajitsu <akito.tajitsu@nao.ac.jp>
#              2023.05.10 ver.0.10
###################################################################
procedure getcount(inimage, cnt_out)
### Input parameters
 string inimage {prompt = 'Input echelle spectrum'}
 string cnt_out {prompt = 'Output text file'}
 
 int ge_line=2    {prompt ='Order line to get count'}
 int ge_stx=2150  {prompt ="Start pixel to get count"}
 int ge_edx=2400  {prompt ="End pixel to get count"}
 real ge_low=1.0  {prompt ="Low rejection in sigma of fit"}
 real ge_high=0.0 {prompt ="High rejection in sigma of fit\n"}

 string ask="no"	  {prompt ="Answer for continuum"}

begin

string temp1, temp2
real max_cnt, mean_cnt, cont_cnt
real tmp1, w_c
int p1,p2

temp1=mktemp("tmp_getcnt")
temp2=mktemp("tmp_getcnt_c")

scopy(inimage//"["//ge_stx//":"//ge_edx//","//ge_line//"]",temp1)

continuum(temp1,temp2,bands=1,type="fit",functio="legendre",order=1,high_rej=ge_high,low_rej=ge_low,ask=ask)

imstat(image=temp2, field='mean', format-) |scan(mean_cnt)
imstat(image=temp2, field='max', format-) |scan(max_cnt)

cont_cnt=(max_cnt+mean_cnt)/2
if(access(cnt_out)){
     delete(cnt_out)
}
print(cont_cnt, > cnt_out)

p1=int((ge_edx-ge_stx)/2)
p2=p1+1

listpixels(temp1//'['//p1//":"//p2//']', wcs='world',formats='%g %g',ver-,mode=mode) | scan(w_c,tmp1)

imdelete(temp1)
imdelete(temp2)

printf("\n")
printf("*** Continuum Count is %de- at order %d (%d A). ***\n",cont_cnt,ge_line,int(w_c))
printf("\n")

bye
end
