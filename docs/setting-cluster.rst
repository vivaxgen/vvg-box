
Setting Up for Cluster System
=============================



Adding Extra Argument to Submission Script
------------------------------------------

In some settings, the workload manager/job scheduler require extra arguments
or flags for its submission command.


Create a resource file in $VVG_BASEDIR/etc/bashrc.d/ directory named
``95-cluster-extra-flags`` with the below content::

	SNAKEMAKE_CLUSTER_EXTRA_FLAGS="<YOUR-FLAGS>"

