#!/bin/bash

# $Id: function_3.2_curie.ksh 301 2011-08-26 10:03:13Z molines $
######################################################################################
#    KSH script functions used below:
######################################################################################
# copy()   
# rcopy() 
# copyfor() 
# rapatrie()     
# core_rapatrie()
# rapatrie_res() 
# expatrie()
# expatrie_res()
# clean_res()
# chkdir() 
# chkdirg()
# chkfile()
# mkordre()
# submit() 
# runcode()
# runcodescalasca()
# lsrestart()  
# mk_batch_hdr()
# mk_scal_mon() 
#-------------------------------------------------------
# Source machine independant functions (already done in the script)
# . ./function_3.2_all.ksh
# MACHINE DEPENDANT functions
# copy : a wrap up for scp or cp 
copy()    { cp $1 $2 ; }
rcopy()   { cp $1 $2 ; }
copyfor() { ln -sf $1 $2 ;}
# ---

# rapatrie is a shell function which tries to copy $1 on the local dir with the name $4
#         if the name is not defined or is none, it just skip
#         it then first tries to find the file on disk directory $2
#         if it fails it tries to mfget from $3 directory 
#         if it is not found anywhere, stop the script and issue a message
#         login_node is set in includefile.ksh
rapatrie() { 
      core_rapatrie $1 $2 $3 $4
      if [ $AGRIF = 1 ] ; then
         for idx in ${agrif_pref[@]} ; do
           core_rapatrie ${idx}_$1 $2 $3 ${idx}_$4
         done
      fi
           }
#---

# The core of the rapatrie function.: called by rapatrie which also deals with agrif
core_rapatrie() {
     echo ${1:-none} | grep -iv none && \
    { if [ -f $4 ] ; then      # file already there
        echo $4 found
      elif [ -f $2/$1 ] ; then #copy from local file system
        cp $2/$1 $4
      else                     # copy from remote file system
        rcopy $3/$1 $4  ||  { echo $1 not found anywhere &&  exit ; }
      fi  ; }
           }
# ---

# rapatrie_res is normaly used for restart. On curie it is just the same as rapatrie
#  
rapatrie_res() { 
      rapatrie  $1 $2 $3 $4
               }
# ---

# expatrie  file $1 on the directory $2, with filename $3
expatrie() {
      copy $1 $2/$3
           }
# --- 

# expatrie_res  file $3 on the directory $4, cp with filename $1 to $2
# weird, yes, but the way the arguments are arranged in the call ($1 and $3 are the same)
expatrie_res() {
      if [ ! -f $2/$1 ] ; then
         cp $4/$3 $2/$1
      else
         echo $1 already exists in $2
      fi
#     echo expatrie_res does nothing on occigen       # changed vh20161012
               }
# --- 

# remove old restart files from the working directory
# clean_res() { \rm  $P_R_DIR/*.$1.tar.* ; }
 clean_res() {
      echo no restart cleaning on occigen
             }
# --- 

# check existence and eventually create directory
chkdir() { if [ ! -d $1 ] ; then mkdir $1 ; fi ; }
# --- 

# chkdirg  : Usage: chkdirg DATA space_directory
#    check the existence of a directory on DATA space . Create it if not present
chkdirg() { if [ ! -d $SDIR/$1 ] ; then mkdir $SDIR/$1 ; fi  ; }
# --- 

# chkfile  : Usage: chkfile   dir_of_file/file  #CINES ajout 22-07-08
#    check the existence of a directory on dir_of_file on login_node .
chkfile() { if [ ! -f $1 ] ; then exit 1 ; fi  ; }
# --- 

# mkordre
mkordre() { cd $SDIR/${CONFIG}/${CONFIG_CASE}-S/ ; ~/bin/mkordre  ; }
# ---

# function for submitting jobs; modified for JADE

submit() { cd ${P_CTL_DIR} 
#           Relic from occigen
#           if [ -f ~/.bad_node ] ; then 
#           sbatch -x $(cat ~/.bad_node) $1 > $TMPDIR/logsubmit 
#           else
#           sbatch $1 > $TMPDIR/logsubmit 
           qsub $1 > $TMPDIR/logsubmit 
#           fi
           cd $TMPDIR 
         }
# ---

# function for running OPA : it takes the number of procs and name of program as argument
runcode() {
	  source /usr/share/Modules/init/bash
	  source /project/oh/drakkar/LIBRAIRIES/NETCDF/env_netcdf_gnu.sh
          module list
          time mpirun -n $*
          }

# function for running OPA : it takes the number of procs and name of program as argument
# unpopulated 
runcode_u() {
         mpirun --bynode -np $*
          }
# ---
# function for running OPA ans XIOS : it takes the number of procs and name of programs as argument
#    runcode_mpmd  nproc1 prog1    nproc2 prog2   ... nprocn progn
runcode_mpmd() {

               n1=$1
               n2=$3
               prog1=$2
               prog2=$4
               
               
               # get the path for mpirun
               source /usr/share/Modules/3.2.10/init/bash
               module purge
               module load   NETCDF/4.3.3.1-mpt-intel2016  # faster (9:03.32)  but result not exact  as caparmor 
               module load   nco/4.6.4_gcc-6.3.0
               module list
               export mpiproc=`cat $PBS_NODEFILE  |wc -l`
               
               echo "submit job with  $NETCDF_MODULE "
               echo "job running with  $mpiproc mpi process  here you should see 30 * 28"
               date
               
               date
               time $MPI_LAUNCH -n 28 ${prog1} : -n 1 ${prog2} :    \
                                -n 28 ${prog1} : -n 1 ${prog2} :    \
                                -n 28 ${prog1} : -n 1 ${prog2} :    \
                                -n 28 ${prog1} : -n 1 ${prog2} :    \
                                -n 28 ${prog1} : -n 1 ${prog2} :    \
                                -n 28 ${prog1} : -n 1 ${prog2} :    \
                                -n 28 ${prog1} : -n 1 ${prog2} >& output.mpi
               date
               }
# ---
         
# ---

# function for running OPA with scalasca : it takes the number of procs and name of program as argument
runcodescalasca() {
         scan -t mpiexec_mpt -n $1 $2
          }

# function that source the .bashrc file if necessary (depends on the batch scheduler)
srcbash() {  
      source $HOME/.bashrc
          }  
# ---

# function save_nc : dummy function on jade
save_nc () {
     echo nothing to do ! > /dev/null
           }
# ---

# save_arch_file   file  archive_dir  # used when XIOS in use
save_arch_file () {
      echo nothing to do on curie ! > /dev/null
                  }
# --

#--------------------------------------------------------------------------------------
# Restart file management
# function to perform a ls on the remote restart directory
lsrestart() { 
       ls $F_R_DIR/ | grep $1
            }
# ---

#-----------------------------------------------------------------------------------------
# Make batch header for submitted scripts
# mk_batch_hdr  --wallclock wallclock --nodes nodes --cores_per_node cores_per_node --queue queue 
mk_batch_hdr() {
   # initialization of variables on datarmor
   wallclock=01:00:00
   nodes=1
   cores_per_node=28
##   mk_batch_hdr_core $@     # pass all input argument to the core of the function (in function_all)

# on curie wall clock must be passed in seconds ( need to translate argument given as hh:mm:ss )
wallclock_second=$( echo $wallclock | awk -F: '{print $1*3600 +$2*60 +$3}')

#  Build header for datarmor

cat << eof 
#!/bin/bash
#SBATCH --partition=cpu
#SBATCH --nodes=$nodes
#SBATCH --ntasks-per-node=$cores_per_node
#SBATCH --mem=90G
#SBATCH --time=$wallclock
eof
               }

#-----------------------------------------------------------------------------------------
# Make batch header for submitted scripts and a simplest one
mk_batch_hdr_Zcmp() {
   # initialization of variables on datarmor
   wallclock=02:00:00
   nodes=1
   cores_per_node=28
##   mk_batch_hdr_core $@     # pass all input argument to the core of the function (in function_all)

# on curie wall clock must be passed in seconds ( need to translate argument given as hh:mm:ss )
wallclock_second=$( echo $wallclock | awk -F: '{print $1*3600 +$2*60 +$3}')

#  Build header for datarmor

cat << eof 
#!/bin/bash
#SBATCH --partition=cpu
#SBATCH --nodes=$nodes
#SBATCH --ntasks-per-node=$cores_per_node
#SBATCH --mem=90G
#SBATCH --time=$wallclock
eof
               }
#-----------------------------------------------------------------------------------------
# Gather monthly mean scalar files into a single one
mk_scal_mon() {
                if [ ! -d 1m_OUTPUT ] ;  then mkdir -p 1m_OUTPUT ; fi 
		zyear=$1
		for filet in `echo ICE OCE `  ; do 
			taglist=''  ; zm=1
			while [ ${zm} -le 12 ] ; do 
				zzm=$( printf "%02d" $zm ) 
				taglist="$taglist ${CONFIG}-${CASE}_1m_${filet}_scalar_${zyear}${zzm}-${zyear}${zzm}_0000.nc " 
				let zm=${zm}+1
			done
			ncrcat ${taglist}  ./1m_OUTPUT/${CONFIG}-${CASE}_1m_${filet}_scalar_${zyear}01-${zyear}12.nc
			mv ${taglist} ./1m_OUTPUT/
		done 

		}
######################################################################################
