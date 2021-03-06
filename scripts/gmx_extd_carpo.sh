#!/bin/bash -l
#SBATCH --ntasks-per-node=24
#SBATCH -J gmx_ext
#SBATCH -o ogmx.%j
#SBATCH -e egmx.%j
#SBATCH --mem-per-cpu=150
#SBATCH --mail-type=ALL
#SBATCH --mail-user=pierre.leprovost@oulu.fi

set -e

if [ $# -ne 2 ]; then
    echo $0: usage: gmx_extd_taito topology.tpr extensiontime
    exit 1
fi

module load GROMACS/2016.4

export OMP_NUM_THREADS=1
export GMXLIB=forcefield_link

# Topology file
if [ ! -f $1 ]; then
    echo $1" file not found!"
    exit 1
fi

# Time to extend in ns
EXTEND=$(expr ${2} \* 1000)

# Input : Format md_PDBID_TIME.tpr
OLD=${1%.*}
if [[ $OLD = *_*ns ]]; then
    NEW=${OLD/_*ns/_${2}ns}
else
    NEW=${OLD}_${2}ns
fi
echo $NEW

# PRODUCTION

gmx convert-tpr -s $OLD.tpr -until ${EXTEND} -o $NEW.tpr

srun gmx_mpi mdrun -deffnm $NEW -cpi $OLD.cpt -dlb yes -maxh 71.99 -append no

# This script will print some usage statistics to the
# end of the standard out file
# Use that to improve your resource request estimate
# on later jobs.
seff $SLURM_JOBID
