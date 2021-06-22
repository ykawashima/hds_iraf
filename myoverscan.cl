#------------------------------------------------------------
#                    MyOverScan
#
#                      A.Tajitsu   finally revised 2003.01.17
#------------------------------------------------------------
procedure myoverscan(inlist)
string inlist {prompt="List of INPUT images"}
                                   
begin

string list_in
string listtmp, temp

list_in=inlist

listtmp=mktemp('list.in.tmp.')
sed('s/.fits//g',list_in,>listtmp)

list=listtmp

while(fscan(list,temp)==1)
{
  if(!access(temp//".os.fits"))
  {
     overscan(temp//".fits[0]",temp//".os.fits")
  }
}

bye
end
