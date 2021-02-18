# SingleCellCNV-Evolution
## Description
This snakemake pipeline is for single cell copy number evolutionary analysis using 10 X single cell CNV data and the MEDALT package. The pipeline may be run on an HPC or in a local environment.

## Software Requirements
* [Snakemake](https://snakemake.readthedocs.io/en/stable/)
* [cellranger-dna](https://support.10xgenomics.com/single-cell-dna/software/pipelines/latest/using/cnv)
* [MEDALT](https://github.com/KChen-lab/MEDALT)
* [Xvfb](https://www.x.org/releases/X11R7.6/doc/man/man1/Xvfb.1.xhtml)
* [Cytoscape](https://cytoscape.org/)
* [R](https://www.r-project.org)

## Run modes
The pipeline has three run modes available; the last two run modes are optional and the detail of how-to-run is described in User's guider - Editing the config.yaml:
* Basic single cell based analysis: CNV evolutionary analysis is performed at the single cell level 
* Cluster based analysis: CNV evolutionary analysis is performed at the cell cluster level
* Cluster based analysis in merged patient samples: CNV evolutionary analysis is performed at the cell cluster level and all samples in the same patient are merged

## User's guide
### I. Input requirements
Basic:
* Edited config/config.yaml
* 10 X single cell CNV raw data
* 10 X simple sample sheet csv file
* [cellramger-dna reference](https://support.10xgenomics.com/single-cell-dna/software/pipelines/latest/advanced/references)

Optional:
* Required for the run mode of cluster based analysis; can be generated using the result from the basic run mode:
  {output_directory}/reanalysis/{sampleID}/outs/group.txt
* Required for the run mode of cluster based analysis in merged patient samples; can be generated using the result from the basic run mode:
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
* group: Input 'ready' to initiate the run mode of cluster based analysis when the basic run mode is complete and the require group.txt files are ready
* patient: Input 'ready' to initiate the run mode of cluster based Canalysis in merged patient samples when the basic run mode is complete and the require group.txt files are ready

### V. To run
* Clone the repository to your working directory
```bash
git clone https://github.com/JieqiongDai/SingleCellCNV-Evolution.git
```
* Install required software; To run on NIH biowulf (an HPC using slurm job scheduler), you only need to download the MDEALT package and module load other required software.
* Edit and save config/config.yaml 
* To run on an HPC using slurm job scheduler: 
  Edit config/cluster_config.yaml according to your HPC information
  Run sbatch.sh to initiate running of the pipeline 
* To run in a local environment:
  ```bash
  snakemake -p --use-conda --cores 14 --keep-going --rerun-incomplete --jobs 300 --latency-wait 120 all
  ```
* Look in log directory for logs for each rule
* To view the snakemkae rule graph:
```bash
snakemake --rulegraph | dot -T png > scDNA_whole.png
```


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

