#------------------------------------------------------------
#	Subaru HDS wavelength calibration
#          developed from 
#              SNG data reduction softwares POWERUP KIT
#	        [1995/12/??	Y. Ohyama enhanced]
#
#                      A.Tajitsu          2002.05.30
#------------------------------------------------------------
procedure hdswave( inlist,outlist,complist )
#
file	inlist		{prompt= "Input image list  "}
file	outlist		{prompt= "Output image list "}
file	complist	{prompt= "Comparison list   "}
file	dist_list	{prompt= "list of distortion map used"}
#int     skycol=60       {prompt= "Sky Identify Column No."}
#

begin
real  	w1, w2
int	dy,ref
string 	linlist, lcomp, loutlist,distlist
string 	comp,comp1, comp2, tmpfile
string 	obj
bool	sw, clsw, ans, ans2
char	sel
string	out,comp_full,comp_full2,comp_full3,select_comp,objlist,objlist2
string	outlist_full,nearcomp,obj_comp,obj_com_out,rot_list

task	$sed	= $foreign
#task	$fcomps	= ("$"//osfn("mysnghome$")//"fcomps")
#task	$intcomp= ("$"//osfn("mysnghome$")//"intcomp")

#---- Initialize parameters.
linlist = inlist
loutlist = outlist
lcomp  = complist
clsw=no
distlist=dist_list

comp_full =mktemp('comp_full.tmp')
comp_full2=mktemp('comp_full2.tmp')
comp_full3=mktemp('comp_full3.tmp')
sections( lcomp,option='fullname',> comp_full )
sed( 's/.fits//g', comp_full, > comp_full2)
delete( comp_full,ver-,>& "dev$null" )

start:
objlist =mktemp('objlist.tmp')
objlist2=mktemp('objlist2.tmp')
outlist_full=mktemp('outlist_full.tmp.')
sections( linlist,option='fullname',> objlist )
sed( 's/.fits//g', objlist, > objlist2  )
delete( objlist, ver-, >& "dev$null" )
sections( loutlist,option='fullname',> outlist_full)

list = objlist2
while(fscan(list,obj)==1){
	if(access('database/id'//obj)) delete('database/id'//obj)
	if(access('database/fc'//obj)) delete('database/fc'//obj)
}

list = outlist_full
while(fscan(list,obj)==1) 
  if(access(obj)) imdelete(obj)
  

select_comp=mktemp('select_comp.tmp.')
list = comp_full2
while( fscan( list, comp ) == 1 )
        {
	comp = 'database/id'//comp
	if( access(comp) )
		{
		print( comp,' is existing in database.' )
		printf( '>>>>> Do you delete that file ? <y/n> : ' )
		while( scan( clsw ) == 0 ) {}
		if( clsw )
		      {
		      delete( comp,ver-, >& "dev$null" )
		      print(comp,>>comp_full3)
#		      print(comp,>>select_comp)
		      }
		}
		else
		{
		      print(comp,>>comp_full3)
		}
	}

#---- Identify comparison lines.
print( '\nIdentify comparison lines...' )

list = comp_full2
while( fscan( list, comp ) == 1 )
	{
	imtrans(comp,comp)
retryid:
	identify( comp,section='middle line',databas='database',\
		coordli='hdshome$ThAr.dat',nsum=20,match=20.,\
		maxfeat=25,fwidth=4.,cradius=4.,functio='chebyshev',\
		order=4,niterate=5,low_rej=3.,high_rej=3.,grow=0.,\
		ftype='emission',thresh=50,autowrite+,mode=mode )

#	ecidentify( comp,databas='database',\
#		coordli='hdshome$ThAr.dat',match=1.,\
#               maxfeat=100,fwidth=5.,cradius=10.,functio='chebyshev',\
#		xorder=2,yorder=2,niterate=0,lowreje=3.,highrej=3.,\
#		ftype='emission',thresh=10,autowrite-,mode=mode )

	printf( '>>>>> OK? <y/n/(skip this frame ==>)s> : ' )
	while( scan( sel ) == 0 ) {}
	if( sel == 'y' )
		{
		print( comp, >> select_comp)
		}
	else if( sel == 's' )
		;
	else
		goto retryid
	}	

printf( '\n>>>>> Identify ok?  Go to next step? <y/n> : ' )
while( scan( sw ) == 0 ) {}
if( !sw )
	goto start

delete( comp_full2, ver-, >& "dev$null" )
delete( comp_full3, ver-, >& "dev$null" )

if( !clsw )
	{
	printf( '\n>>>>> Re-identify ? <y/n> : ' )
	while( scan( sw ) == 0 ) {}
	if( !sw )
		goto notreid
	}

print( 'Re-identify comparison lines...' )
list = select_comp
while( fscan( list, comp) == 1 )
	{
	printf('\nNow Re-identifying %s\n',comp)
	reidentify(comp,comp,section='middle line',interac-,\
	        newaps-,overrid+,refit+,trace+,addfeat-,\
 		step=2,nsum=2,shift=0.,nlost=0,cradius=4.,\
 		thresho=0.,match=20.,maxfeat=25,\
 		minsep=2.,coordli='hdshome$ThAr.dat',\
 		databas='database',ver+,answer=no,\
 		logfile="", mode=mode )

	}

notreid:

#---- Identify comparison frames to be used.
print( 'Now finding the suitable pair of Comparisons...')
nearcomp=mktemp('nearcomp.tmp')
obj_com_out=mktemp('obj_com_out.tmp')
list = objlist2
while( fscan( list, obj ) == 1 ){
#	fcomps( obj,select_comp,nearcomp )
     print(comp//'  0.5  '//comp//'  0.5', >> nearcomp)
}

#delete( select_comp, ver-, >&"dev$null" )
obj_comp=mktemp('obj_comp.tmp.')

joinlines(objlist2,nearcomp,output=obj_comp,delim=' ')
joinlines(obj_comp,outlist_full,output=obj_com_out,delim=' ')


delete( obj_comp, ver-, >&"dev$null" )
     
list = obj_com_out
while( fscan( list, obj, comp1, w1, comp2, w2 ,out) == 6 )
        {
        if(access(out//'.fits'))
	        {
		print('Output file already exists.\nSkip? <y/n>')
		while(scan(ans)==0) {}
		if(ans) goto do_nothing
		else imdelete(out)
		}
#	print('Now Interpolating the Identified Database!')
#	intcomp( comp1, comp2, w1, w2, obj, 'database\/id' )
retry:
        if(access('sky.fits')) imdel('sky')
	if(access('database/idsky')) del('database/idsky')
	if(access('database/fcsky')) del('database/fcsky')
	if(access('database/idfit')) del('database/idfit')
	if(access('database/fcfit')) del('database/fcfit')
        imcopy(obj,'sky',ver-)

nosky:
	fitcoords(comp1//','//comp2,\
	        fitname='fit',databas='database',interac+,\
		functio='legendre',xorder=5,yorder=5,combine+,mode=mode )

trans:
	print('O.K.? <y/n>')
	while(scan(ans)==0) {}
	if(!ans)	goto retry

	transform(obj,out,'fit',databas='database',\
		interpt='linear',y1=INDEF,dy=INDEF,x1=INDEF,\
		y2=INDEF,ny=INDEF,\
		x2=INDEF,dx=INDEF,nx=INDEF,mode=mode )

	hedit( out,'HISTORY','wavelength calibration',add+,\
	        del-,ver-,show-,update+,mode=mode )

	display(out,1,zscale+)

do_nothing:
        }

finish:
	print( 'This procedure was ended...' )
bye
end
