#include<stdio.h>
#include<stdlib.h>
#include<math.h>

#define POINTS 200

/* vgauss output.xy refwave cwave center_intens fwhm vmin vmax */

int main(int argc, char **argv){
  FILE *fp;
  double refwave, cwave, cintens, fwhm, vmin, vmax;
  double v, x, y, lambda, dv;
  double c=3.0e+5;
  int i;

  refwave=(double)atof(argv[2]);
  cwave=(double)atof(argv[3]);
  cintens=(double)atof(argv[4]);
  fwhm=(double)atof(argv[5]);
  vmin=(double)atof(argv[6]);
  vmax=(double)atof(argv[7]);

  dv=(vmax-vmin)/(double)POINTS;

  if((fp=fopen(argv[1],"w"))==NULL){
    fprintf(stderr," File Open Error  \"%s\" \n", argv[1]);
    exit(1);
  }
  else{
    fprintf(stderr, "Opening %s\n", argv[1]);
  }

  v=vmin;

  for(i=0;i<=POINTS;i++){
    lambda=(1+v/c)*refwave;

    x=(lambda-cwave);
    y=cintens*exp( -4*log(2)*x*x/fwhm/fwhm);

   fprintf(fp,"%le  %le  %le\n", lambda, y, v);

    v+=dv;
  }

  fclose(fp);

}
