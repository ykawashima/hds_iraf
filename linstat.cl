# version 1.0.5
# task overscan = path$overscan.cl

procedure linstat (inimage)

string inimage	{prompt="Input images"}

struct *list0
struct *list1
struct *list2

begin
	string listtmp, inimg
	string hst_st, hst_ed
	real nphoton, stddev
	real e_time

	listtmp=inimage

list=listtmp
while(fscan(list,inimg)==1)
{
	imstat(image=inimg, field='mean', format-) | scan(nphoton)
	imstat(image=inimg, field='stddev', format-) | scan(stddev)

	imgets(image=inimg, param="HST-STR")
	hst_st  = imgets.value

	imgets(image=inimg, param="HST-END")
	hst_ed  = imgets.value

	e_time = (real(hst_ed) - real(hst_st))*60*60

	printf("%s, %6.2f, %10.2f, %8.2f, %s, %s\n",
		inimg, e_time, nphoton, stddev, hst_st, hst_ed)
}
end
