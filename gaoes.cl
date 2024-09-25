##################################################################
# Seimei GAOES-RV Reduction Package (alpha version)
#  developed by A.Tajitsu                     2024.09.25
###################################################################
images
tv
noao
rv
plot
proto
twodspec
longslit
onedspec
utilities
imutil
imred
ccdred
noao
artdata
echelle

package gaoes

task	$sed	= $foreign

#set	hdshome		="/home/ira/iraf/local/osp/hds/"

task	wacosm11	        ="hdshome$wacosm11.cl"
task	wacosm1 	        ="hdshome$wacosm1.cl"
task	wacosm3 	        ="hdshome$wacosm3.cl"
task	mkblaze 	        ="hdshome$mkblaze.cl"
task	hdsmk1d 	        ="hdshome$hdsmk1d.cl"

#set	gaoeshome		="/home/ira/iraf/local/osp/hds/"

task	gaoes_overscan 	        ="gaoeshome$gaoes_overscan.cl"
task	gaoes_ecfw 	        ="gaoeshome$gaoes_ecfw.cl"
task	gaoes_flat 	        ="gaoeshome$gaoes_flat.cl"
task	gaoes_comp 	        ="gaoeshome$gaoes_comp.cl"
task	gaoes_linear 	        ="gaoeshome$gaoes_linear.cl"
task	grql 	        	="gaoeshome$grql.cl"
task	gaoes_linstab 	        ="gaoeshome$gaoes_linstab.cl"
task	gaoes_linstat 	        ="gaoeshome$gaoes_linstat.cl"
task	gaoes_mk1d 	        ="gaoeshome$gaoes_mk1d.cl"
task	gaoes_mkblaze 	        ="gaoeshome$gaoes_mkblaze.cl"
task	gaoes_mkmask 	        ="gaoeshome$gaoes_mkmask.cl"
task	getcount 	        ="gaoeshome$getcount.cl"
task	rvgaoes 	       	="gaoeshome$rvgaoes.cl"


beep
print ("  ***************************************************************")
print ("  ***************************************************************")
print ("  **          Seimei GAOES-RV IRAF Reduction Package           **")
print ("  ************************** CAUTION !!! ************************")
print ("  ** This package is always under development.                 **")
print ("  ** Check the latest package via                              **")
print ("  **       git clone https://github.com/chimari/hds_iraf       **")
print ("  **                                                           **")
print ("  **     This package is developed by Akito Tajitsu (NAOJ)     **")
print ("  **                               last update : 2024/09/25    **")
print ("  ***************************************************************")
print ("  ***************************************************************\n")

clbye()
