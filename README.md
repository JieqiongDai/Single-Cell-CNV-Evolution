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
* Edited config/config.yaml
* 10 X single cell CNV raw data
* 10 X simple sample sheet csv file
* [cellramger-dna reference](https://support.10xgenomics.com/single-cell-dna/software/pipelines/latest/advanced/references)
### II. 10 X simple sample sheet csv format
Three columns with headers: Lane,Sample,Index

Example:
```bash
Lane,Sample,Index
1,A,SI-GA-A4
1,B,SI-GA-B4
2,A,SI-GA-A4
2,B,SI-GA-B4
```
### III. Editing the config.yaml
Basic parameters:
* medalt: Path to MEDALT  installed directory
* reference: Path to the reference genome file
* bam_directory: Path to the bam files
* bed_direcotry: Path to the bed files
* universal_bed: If using a universal bed file for all samples or groups, 'yes' or 'no'

Optional parameters:
* output_directory: Output directory. Default: output/ in workding directory
* ht: Height of the snapshots. Default: 100
* tile: Layout of snapshots in final pdf. Default: 1x4
* mem: Memory for running IGV-snapshot-automator. Default: 16g

### IV. Output

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

