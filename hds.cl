##################################################################
# Subaru HDS long-slit mode Reduction Package (alpha version)
#           revised from OAO coude TICCD Reduction Package
#  developed by A.Tajitsu                     2001.05.07
###################################################################
images
tv
noao
rv
plot
proto
twodspec
apextract
longslit
onedspec
utilities
imutil
imred
ccdred
noao
artdata
echelle

package hds

task	$sed	= $foreign

#set	hdshome		="/home/ira/iraf/local/osp/hds/"

task	stis_mk1d			="hdshome$stis_mk1d.cl"

task	hdsred			="hdshome$hdsred.cl"
task	hdswave	        	="hdshome$hdswave.cl"
task	hdsderotate	        ="hdshome$hdsderotate.cl"
task	hdslsred	        ="hdshome$hdslsred.cl"
task	hdslswave	        ="hdshome$hdslswave.cl"
task	hdslsmkbias	        ="hdshome$hdslsmkbias.cl"
task	hdslsderotate	        ="hdshome$hdslsderotate.cl"
task	hdsls_apex	        ="hdshome$hdsls_apex.cl"
task	hdsls_apid	        ="hdshome$hdsls_apid.cl"
task	hdsls_mkbl	        ="hdshome$hdsls_mkbl.cl"
task	sm_cont 	        ="hdshome$sm_cont.cl"
task	vsm_cont 	        ="hdshome$vsm_cont.cl"
task	hdslstrans 	        ="hdshome$hdslstrans.cl"
task	overscan 	        ="hdshome$overscan.cl"
task	overscan2 	        ="hdshome$overscan2.cl"
task	myoverscan 	        ="hdshome$myoverscan.cl"
task	rvhds 	                ="hdshome$rvhds.cl"
task	hdsql 	                ="hdshome$hdsql.cl"
task	hdsql1 	                ="hdshome$hdsql1.cl"
task	hdsql2 	                ="hdshome$hdsql2.cl"
task	hdsql3 	                ="hdshome$hdsql3.cl"
task	hdsql4 	                ="hdshome$hdsql4.cl"
task	hdsql5 	                ="hdshome$hdsql5.cl"
task	hdsql6 	                ="hdshome$hdsql6.cl"
task	hdsql7 	                ="hdshome$hdsql7.cl"
task	hdsql8 	                ="hdshome$hdsql8.cl"
task	hdsql9 	                ="hdshome$hdsql9.cl"
task	wacosm11	        ="hdshome$wacosm11.cl"
task	wacosm1 	        ="hdshome$wacosm1.cl"
task	wacosm3 	        ="hdshome$wacosm3.cl"
task	vgwphoto 	        ="hdshome$vgwphoto.cl"
task	vgwpos 	                ="hdshome$vgwpos.cl"
task	vgwmake 	        ="hdshome$vgwmake.cl"
task	vgwadd 	                ="hdshome$vgwadd.cl"
task	sstac 	                ="hdshome$sstac.cl"
task	vtxtsstac 	        ="hdshome$vtxtsstac.cl"
task	vtxtgauss 	        ="hdshome$vtxtgauss.cl"
task	aplist 	        ="hdshome$aplist.cl"
task	linstat 	        ="hdshome$linstat.cl"
task	hdslinear 	        ="hdshome$hdslinear.cl"
task	linstability 	        ="hdshome$linstability.cl"
task	mkblaze 	        ="hdshome$mkblaze.cl"
task	adjblaze 	        ="hdshome$adjblaze.cl"
task	mkbadmask 	        ="hdshome$mkbadmask.cl"
task	hdsbadfix 	        ="hdshome$hdsbadfix.cl"
task	hdsbadfix2 	        ="hdshome$hdsbadfix2.cl"
task	hdsmkcombine 	        ="hdshome$hdsmkcombine.cl"
task	hdssubx 	        ="hdshome$hdssubx.cl"
task	hdsis_ecf 	        ="hdshome$hdsis_ecf.cl"
task	hdsmk1d 	        ="hdshome$hdsmk1d.cl"
task	rvhdsmk1d 	        ="hdshome$rvhdsmk1d.cl"
task	vcfitxy			="hdshome$vcfitxy.cl"

task	gaoes_overscan 	        ="hdshome$gaoes_overscan.cl"
task	gaoes_ecfw 	        ="hdshome$gaoes_ecfw.cl"

beep
print ("  ***************************************************************")
print ("  ***************************************************************")
print ("  **            Subaru HDS IRAF Reduction Package              **")
print ("  **                   1D + 2D + Long slit                     **")
print ("  ************************** CAUTION !!! ************************")
print ("  ** This package is always under development.                 **")
print ("  ** Check the latest package via                              **")
print ("  **       git clone https://github.com/chimari/hds_iraf       **")
print ("  **                                                           **")
print ("  **     This package is developed by Akito Tajitsu (NAOJ)     **")
print ("  **                               last update : 2021/06/18    **")
print ("  ***************************************************************")
print ("  ***************************************************************\n")

clbye()
