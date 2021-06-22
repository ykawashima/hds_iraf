procedure hdslsmkbias(inlist,outfile)

string inlist {prompt="List of INPUT images"}
string outfile {prompt="OUTPUT bias image"}

begin

string list_in, biasfile, biastmp, fname, d_type, temp
bool	ans

list_in = inlist
biasfile = outfile

biastmp = mktemp('list.bias.tmp.')

if(access(biasfile))
        {
	printf("### The file %s already exsists. ###\n", biasfile)
	printf(">>> Do you want to use this file? <y/n> : ")
	while(scan(ans)!=1) {}
	if(ans) bye 
	else imdel(biasfile)
	}

list = list_in

while(fscan(list,temp)==1)
{
       fname=temp
       imgets(fname,'DATA-TYP')
       d_type=imgets.value

       if(d_type=='BIAS')
       {
       hedit(fname,'i_title','Bias',add-,del-,ver-,show-,update+)
       print(fname, >> biastmp)
       }
}

imcombine('@'//biastmp,biasfile,combine='median',reject='none')

bye
end
