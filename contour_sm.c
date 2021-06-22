/*********************************************************************/
/*      IRAF pix file -> lipstpix file -> Super Mongo contour        */
/*                                     ~~ここの支援をするソフト      */
/*                                             1995.10.02 A.Tajitsu  */
/*********************************************************************/

#include<stdio.h>
#include<stdlib.h>
#include<math.h>

int main(int argc,char *argv[]){
  FILE *fp;
  int dummy1,dummy2,contour[1000][1000],tei;
  int n,o,end_n,end_o,ans;

  if(argc!=7){
    printf("[usage] % contour_sm filename end_x end_y outfile logflag[1/2] tei\n");
    exit(1);
  }

  /*  printf("linear plot(1) or log plot(2) ? [1/2] : "); 
      scanf("%d",&ans);

  if(ans==2){
    printf("please imput log no tei : ");
    scanf("%f",&tei);
  }*/
  
  end_n = atoi(argv[2]);
  end_o = atoi(argv[3]);
  
  fp = fopen(argv[1],"r");


  for(n=0;n<end_n;n++){
    for(o=0;o<end_o;o++){
      fscanf(fp,"%f %f %f",&dummy1,&dummy2,&contour[n][o]);
/*      printf("%f\n",contour[n][o]); */
    }
  }


  ans = atoi(argv[5]);
  if(ans==2){
    tei = atof(argv[6]);
  }

  fclose(fp);

  if(ans==2){
    for(n=0;n<end_n;n++){
      for(o=0;o<end_o;o++){
	if(contour[n][o]<=0){
	  contour[n][o]=1e-20;
	}
	contour[n][o]=log(contour[n][o])/log(tei);
      }
    }
  }
  
  fp=fopen(argv[4],"wb");
  fwrite(&end_n,sizeof(int),1,fp);
  fwrite(&end_o,sizeof(int),1,fp);

  for(n=0;n<end_n;n++){
    for(o=0;o<end_o;o++){
      fwrite(&contour[n][o],sizeof(float),1,fp);
    }
  }

  fclose(fp);
}
