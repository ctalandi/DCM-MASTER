#!/bin/bash

set -xv 



TARGET_DIR1=./NEMO4.0.1/src/WORK/
TARGET_DIR2=/home1/datahome/ctalandi/DEV/GITREP/DCM_4.0/DCMTOOLS/NEMOREF/NEMO4/src/WORK

OUTFILE=codediff_401-400.txt
LOCDIR=`pwd`
touch ${LOCDIR}/${OUTFILE}

cd $TARGET_DIR1
pwd
for file in `cat ../../../liste.txt ` ;  do
 
		echo $file
	        realfile=`basename $file`
	        realdir=`dirname $file`
	echo " #################################################################################### " >> ${LOCDIR}/${OUTFILE}
	echo " ###########################  $file  ################################################ " >> ${LOCDIR}/${OUTFILE}
	echo " #################################################################################### " >> ${LOCDIR}/${OUTFILE}
	echo  >> ${LOCDIR}/${OUTFILE}
	
		sdiff  -s $file ${TARGET_DIR2}/.  >> ${LOCDIR}/${OUTFILE}
	
	echo " #################################################################################### " >> ${LOCDIR}/${OUTFILE}
	echo " #################################################################################### " >> ${LOCDIR}/${OUTFILE}
	echo " #################################################################################### " >> ${LOCDIR}/${OUTFILE}
	echo  >> ${LOCDIR}/${OUTFILE}
	echo  >> ${LOCDIR}/${OUTFILE}
	echo  >> ${LOCDIR}/${OUTFILE}

done

cd ${LOCDIR}


