# SingleCellCNV-Evolution
## Description
This snakemake pipeline is for single cell copy number evolutionary analysis starting with 10 X single cell CNV data.

## Software Requirements
* [Snakemake](https://snakemake.readthedocs.io/en/stable/)
* [cellranger-dna](https://support.10xgenomics.com/single-cell-dna/software/pipelines/latest/using/cnv)
* [MEDALT](https://github.com/KChen-lab/MEDALT)
* [Xvfb](https://www.x.org/releases/X11R7.6/doc/man/man1/Xvfb.1.xhtml)
* [Cytoscape](https://cytoscape.org/)
* [R](https://www.r-project.org)

## User's guide
### I. Input requirements
Basic:
* Edited config/config.yaml
* 10 X single cell CNV raw data
* 10 X simple sample sheet csv file
* [cellramger-dna reference](https://support.10xgenomics.com/single-cell-dna/software/pipelines/latest/advanced/references)

Optional:
* To run cluster based CNV evolutionary analysis when the general pipeline is complete:
  {output_directory}/reanalysis/{sampleID}/outs/group.txt
* To run Cluster based CNV evolutionary analysis in merged patient samples when the general pipeline is complete:
  {working_directory}/patient/{patientID}/group.txt

### II. 10 X simple sample sheet csv file format
Three columns with headers: Lane,Sample,Index

Example:
```bash
Lane,Sample,Index
1,A,SI-GA-A4
1,B,SI-GA-B4
2,A,SI-GA-A4
2,B,SI-GA-B4
```

### III. group.txt file format
* {output_directory}/reanalysis/{sampleID}/outs/group.txt
Two tab-delimited, headerless columns: 10 X group ID, cell number

Example:
```bash
391	54
364	19
375	39
387	33
```
* {working_directory}/patient/{patientID}/group.txt
Three tab-delimited, headerless columns: 10 X group ID, cell number, tissue type

Example:
```bash
6518  2718	N
1141	35 T
1016	183	T
1024	153	T
1020	92	T
391	54	M
364	19	M
375	39	M
387	33	M
```

### IV. Editing the config.yaml
Basic parameters:
* medalt: Path to MEDALT package installed directory
* flowcells: Flowcell ID
* raw: Path to the raw 10 X data stored directory
* table: Path to 10 X sample sheet
* fastq: Path to desired directory to store fastq files
* out: Path to desired directory to store output files
* genome: hg38, hg19, mm10, etc
* ref: Path to cellranger-dna reference stored directory

Optional parameters:
* group: Input 'ready' to run cluster based CNV evolutionary analysis when the general pipeline is complete and the require group.txt files are ready
* patient: Input 'ready' to run cluster based CNV evolutionary analysis in merged patient samples when the general pipeline is complete and the require group.txt files are ready

### V. Output

[Example](https://github.com/NCI-CGR/IGV_snapshot_automation/tree/main/example/output)
```bash
|--- user/defined/output_dir/
   |--- IGV_Snapshots/
      |--- pdf/               # Final pdf file
      |--- merge/             # Intermediate files
      |--- merge_true/        # The merged snapshot of each sample or group
      |--- {sampleID}/          # All snapshots of each sample or group
```

### V. To run on an HPC
* Check with system administrator to make sure the xvfb-run command is available universally across the cluster.
* Edit config/config.yaml and save
* To run on an HPC using Slurm job scheduler like NIH Biowulf: run sbatch.sh; look in log directory for logs for each rule.
* To run on an HPC using SGE job scheduler like Cgems: run qsub.sh; look in log directory for logs for each rule.

