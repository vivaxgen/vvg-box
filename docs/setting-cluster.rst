
Setting Up for Cluster System
=============================

During installation, vvg-base (vivaxGEN Base utility) will try to automatically
detect whether a workload manager or job scheduler is available in the system.
The script that perform the detection is ``$VVGBIN/set-cluster-config.sh`` and
can be run manually (in case the installation step does not successfully run
the script).
The script checks whether the system has ``sbatch`` and ``sacct`` for SLURM or
``qsub`` and ``qstat`` for PBS-derived system.
When the script detects a workload manager, it would try to set up a cluster
profile for Snakemake version 8 by creating a symbolic link to a resource file
that exports the correct SNAKEMAKE_PROFILE environment variable.

The detection script can usually detect SLURM correctly and the default profile
is likely to be usable straight away.
Upon detecting SLURM, the script will generate a link named
``99-snakemake-profile`` in ``$VVG_BASEDIR/etc/bashrc.d`` directory to
``etc/snakemake-profiles/slurm/99-snakemake-profile`` in the vvg-base
repository directory ($VVG_BASEDIR/envs/vvg-base/).

However, because there are several variants of PBS-based system (eg. Torque,
OpenPBS, PBS Pro), some additional steps might need to be done since each
variant of PBS might have slightly different arguments or output format.


Testing the Cluster Setting
---------------------------

To test the cluster/workload manager setting, run the following command::

	ngs-pl run-snakefile --snakefile test_cluster.smk

The ``test_cluster.smk`` rule will submit 4 jobs to the cluster system.
Each job will wait for 5 seconds, and then write the hostname of the executing
nodes to files named test-cluster-[1234] in the current directory.


Adding Extra Argument to Submission Script
------------------------------------------

In some settings, the workload manager/job scheduler require extra arguments
or flags for its submission command.
For example, a PBSPro setting might require storage or extra settings so that
submitted jobs can be run successfully.

To add extra arguments to the submission command, create a resource file in
``$VVG_BASEDIR/etc/bashrc.d/`` directory named ``95-cluster-extra-flags`` with
the following content::

	SNAKEMAKE_CLUSTER_EXTRA_FLAGS="<ADDITIONAL-FLAGS>"

Please consult the manual of the respective submission command (``sbatch`` for
SLURM, ``qsub`` for PBS-based) for the additional flags above since the flags
have to match the corresponding submission command.


Manual Setup of Cluster Profile
-------------------------------

In case that the provided cluster profiles do not work properly or if the
installed workload manager does not have the proper profile in the provided
profiles, a manual setup needs to be performed.

The directory in ``$VVG_BASEDIR/etc/snakemake-profiles`` can be used to install
the cluster profile manually.
Create a new directory in the that ``snakemake-profiles``, copy the correct
profile (including the associated files) to the new directory and create
a resource file named ``99-snakemake-profile`` with the following content::

	export SNAKEMAKE_PROFILE=${VVG_BASEDIR}/etc/snakemake-profiles/<YOUR_PROFILE_DIR>

Activate the environment (or re-activate by exiting and activating the
environment), and check that the SNAKEMAKE_PROFILE environment variables points
to the correct profile directory using the following command::

	env | grep SNAKEMAKE

Test the setting by running the command in the Testing section.
