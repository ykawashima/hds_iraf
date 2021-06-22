##################################################################
# Subaru HDS Adjust corrected (better) blaze function 
#  developed by Akito Tajitsu <tajitsu@subaru.naoj.org>
#              2013.07.11 ver.1.00
###################################################################
procedure adjblaze(in_1dfc,in_ecfc,in_blz, out_blz, out_adj)
#
file	in_1dfc	{prompt= "Input 1D Flux-Calibrated Spec."}
file	in_ecfc	{prompt= "Input Multi-Order Flux-Calibrated Spec.\n"}

file    in_blz  {prompt= "Input Blaze Function to be adjusted"}
file    out_blz {prompt= "Output adjusted Blaze Function"}
file    out_adj {prompt= "Output Sensitivity Adjustment Function\n"}

string  func1d="legendre"  {prompt= "Default Function to be fit the 1D Spec.",enum="legendre|chebyshev|spline1|spline3"}
int  ord1d=3   {prompt= "Default fitting order for the 1D Spec.\n"}

string  funcec="legendre"  {prompt= "Default Function to be fit each order",enum="legendre|chebyshev|spline1|spline3"}
int  ordec=5   {prompt= "Default fitting order for each order\n"}
#

begin
string 	in1d, inec, sens1d, tmp_bad,  tmp_ord,  tmp_sens[100],
 tmp_sens_nm[100],  sens_list, tmp_plot
bool ans, ans_ord[100], ans2
real x,y
int ans_num,i1,i2,npix,nord,i,j
real ymax,ymin
int num_plot
real pratio
real tmp_max, tmp_min

in1d=in_1dfc
inec=in_ecfc


START:

printf("#### Bad Pix & Emission Masking ####\n")
imgets(in1d,'i_naxis1')
npix=int(imgets.value)

tmp_bad=mktemp("tmp.adjblaze")
imcopy(in1d,tmp_bad,ver-)

printf(">>> Do you want to eliminate Bad pix and Emissions? (y/n) : ")
while(scan(ans)!=1) {}
while (ans){
prow(tmp_bad, row=1,wcs="logical")
  printf("\n>>> Move Cursor to the START point to be cut!\n")
  printf(">>> then, HIT ANY KEY!!\n")
  = fscan (gcur, x,y)

  ans_num=int(x)
  if(ans_num<1){
    i1=1
  }
  else{
    i1=ans_num
  }
    
  printf("\n>>> Move Cursor to the END point to be cut!\n")
  printf(">>> then, HIT ANY KEY!!\n")
  = fscan (gcur, x,y)

  ans_num=int(x)
  if(ans_num>npix){
    i2=npix
  }
  else{
    i2=ans_num
  }

  imreplace(tmp_bad//"["//i1//":"//i2//"]",
      value=0,lower=INDEF,upper=INDEF,radius=0)

  prow(tmp_bad, row=1,wcs="logical")
  printf("\n>>> Do you want to correct Spectrum MORE? (y/n) : ")
  while(scan(ans)!=1) {}
}


printf("#### Continuum Fit for 1D Flux-Calibrated Spectrum ####\n")
sens1d="Sens1D_"//in1d
if(access(sens1d//".fits")){
  imdelete(sens1d)
}
if(access(sens1d)){
  delete(sens1d)
}
continuum(tmp_bad,sens1d,functio=func1d, order=ord1d, type="fit",ask="YES",interac+,replace+)

printf("#### Plot Resultant Sensitivity Function : %s ####\n",sens1d)
splot(sens1d,1)

printf("#### Continuum Re-fit for Multi-Order Spectrum : %s ####\n",inec)
imgets(inec,'i_naxis2')
nord=int(imgets.value)
imgets(inec,'i_naxis1')
npix=int(imgets.value)

imstat(image=inec//"[*,2:"//nord-1//"]", field='max', format-) | scan(ymax)
imstat(image=inec//"[*,2:"//nord-1//"]", field='min', format-) | scan(ymin)

#printf("Min %g, Max %g\n",ymin,ymax)

pratio=1e4/ymax

ymin=0
imstat(sens1d, field='max', format-) | scan(tmp_max)
ymax=tmp_max*2*pratio
printf("Min %g, Max %g\n",ymin,ymax)

tmp_plot=mktemp("tmp.adjblaze")
imarith(inec,"*",pratio,tmp_plot)

for(i=2;i<nord;i=i+1){
   prow(tmp_plot,row=2,wy1=0,wy2=ymax,
                app-,wcs="logical",pointmo-)

   for(j=3;j<nord;j=j+1){
     prow(tmp_plot,row=j,wy1=0,wy2=ymax,
               app+,wcs="logical",pointmo-)
   }

   printf( '    return : show order %d/%d', i,nord )
   =gcur
   prow(tmp_plot,row=i,wy1=0,wy2=ymax,app-,wcs="world",pointmo+,
      marker="circle")

   printf(">>> Do you want to use this order to adjust blaze function? (y/n) : ")
   while(scan(ans)!=1) {}
   ans_ord[i]=ans
}

imdelete(tmp_plot)

sens_list=mktemp("tmp.adjblaze.list")
for(i=2;i<nord;i=i+1){
  if(ans_ord[i]){
    printf(">>> Continuum fit Order %d/%d\n",i,nord)
    tmp_ord=mktemp("tmp.adjblaze")
    tmp_sens[i]=mktemp("tmp.adjblaze")
    tmp_sens_nm[i]=mktemp("tmp.adjblaze")
    imcopy(inec//"[*,"//i//"]",tmp_ord,ver-)
    
    continuum(tmp_ord,tmp_sens[i],functio=funcec, order=ordec, 
          type="fit",ask="YES",interac+,replace+)
    imdelete(tmp_ord)
  
    sarith(tmp_sens[i],"/",sens1d,tmp_sens_nm[i])
    imdelete(tmp_sens[i])
  }
}

ymin=1
ymax=1
for(i=2;i<nord;i=i+1){
  if(ans_ord[i]){
    imstat(tmp_sens_nm[i], field='max', format-) | scan(tmp_max)
    imstat(tmp_sens_nm[i], field='min', format-) | scan(tmp_min)
  
    if(tmp_max>ymax){
      ymax=tmp_max
    }
    if(tmp_min<ymin){
      ymin=tmp_min
    }
  }
}


for(j=2;j<nord;j=j+1){
  if(ans_ord[j]){
    num_plot=0

    for(i=2;i<nord;i=i+1){
      if(ans_ord[i]){
         if(num_plot==0){
           prow(tmp_sens_nm[i],row=1,app-,wcs="logical",pointmo-,
                  wy1=ymin,wy2=ymax)
         }
         else{
           prow(tmp_sens_nm[i],row=1,app+,wcs="logical",pointmo-,
                  wy1=ymin,wy2=ymax)
         }
         num_plot=num_plot+1
      }  
    }

    if(num_plot==0){
       printf("!!! Error !!!\n")
       printf("Please Select at least one order!\n")
       bye
    }

    prow(tmp_sens_nm[j],row=1,app+,wcs="logical",pointmo+,
            marker="circle",wy1=ymin,wy2=ymax)

    printf(">>> Do you want to use this order [#%d]? (y/n) : ",j)
    while(scan(ans)!=1) {}
    if(!ans){
       ans_ord[j]=no
    }
  }
}

num_plot=0
printf("## Selected orders are...\n  ")
for(i=2;i<nord;i=i+1){
  if(ans_ord[i]){
    if(num_plot==0){
      prow(tmp_sens_nm[i],row=1,app-,wcs="logical",pointmo-,
             wy1=ymin,wy2=ymax)
    }
    else{
      prow(tmp_sens_nm[i],row=1,app+,wcs="logical",pointmo-,
             wy1=ymin,wy2=ymax)
    }
    num_plot=num_plot+1

    printf("%d, ",i)
    print(tmp_sens_nm[i], >> sens_list)
  }
}
printf("\n")


if(access(sens_list)){
  if(access(out_adj//".fits")){
    imdelete(out_adj)
  }
  if(access(out_adj)){
    delete(out_adj)
  }
  imcombine("@"//sens_list, out_adj, combine="ave", reject="none")

  if(access(out_blz//".fits")){
    imdelete(out_blz)
  }
  if(access(out_blz)){
    delete(out_blz)
  }
  imarith(in_blz, "*", out_adj, out_blz)
}

for(i=2;i<nord;i=i+1){
  if(ans_ord[i]){
     imdelete(tmp_sens_nm[i])
  }
}
delete(sens_list)


endofp:

    printf("\n****************************************************\n")
    printf("****************************************************\n")
    printf("***** FINISH : adjblaze.cl  by A.Tajitsu 2013  *****\n")
    printf("****************************************************\n")
    printf("****************************************************\n")

bye
end
