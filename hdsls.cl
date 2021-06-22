##################################################################
# Subaru HDS long-slit mode Reduction Package (alpha version)
#           revised from OAO coude TICCD Reduction Package
#  developed by A.Tajitsu                     2001.05.07
###################################################################
noao
artdata
#images
#tv
#rv
#plot
#proto
#twodspec
#apextract
#longslit
#onedspec
#utilities
#imred
#ccdred
#echelle

package hds

task	$sed	= $foreign

#set	hdshome		="/home/iraf/iraf/local/osp/hds/"

task	hdsred	        ="hdshome$hdsred.cl"
task	hdswave	        ="hdshome$hdswave.cl"
task	hdsderotate	        ="hdshome$hdsderotate.cl"
task	hdslsred	        ="hdshome$hdslsred.cl"
task	hdslswave	        ="hdshome$hdslswave.cl"
task	hdslsmkbias	        ="hdshome$hdslsmkbias.cl"
task	hdslsderotate	        ="hdshome$hdslsderotate.cl"
task	sm_cont 	        ="hdshome$sm_cont.cl"
task	hdslstrans 	        ="hdshome$hdslstrans.cl"
task	overscan 	        ="hdshome$overscan.cl"
task	rvhds 	                ="hdshome$rvhds.cl"

beep
print ("*****************************************************************\n")
print ("       Subaru HDS long-slit /Echelle Reduction Package           ")
print ("************************** CAUTION !!! **************************")
print ("               This package is under development.                ")
print ("   This package is developed by A. Tajitsu                       ")
print ("      and is not an official one (i.e., no official suport).     ")
print ("            So, please use the tasks ON YOUR OWN RISKS.          ")
print ("*****************************************************************\n")

clbye()
