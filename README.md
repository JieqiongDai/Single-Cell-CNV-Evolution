# Single Cell Copy Number Variation Evolutionary Analysis
## Description
This snakemake pipeline is for single cell copy number evolutionary analysis using 10 X single cell CNV data and the [MEDALT package](https://github.com/KChen-lab/MEDALT). The pipeline may be run on an HPC or in a local environment.

Major steps in the workflow include:
1) Primary copy number variation (CNV) analysis using cellranger-dna
2) QC filtering and CNV reanalysis
3) CNV evolotuionary analysis using MEDALT
4) Result visualization using Cytoscape

Expected results include:
* Cellular level copy number profiles: 
   * Accessible to CNVs in interested regions and genes 
* Intratumor heterogeneity analysis in single-cell resolution:
   * Tumor purity estimation
   * Major tumor cell clusters estimation 
   * Rare subclone detection
* Reconstructing tumor evolution lineages: 
   * Lineage tracing of single cell 
   * Lineage tracing of the major tumor cell clusters 
   * Lineage tracing of CNA (deep diving)
   * Analysis of CNA related genes and pathway (deep diving)

## Software Requirements
* [Snakemake](https://snakemake.readthedocs.io/en/stable/)
* [cellranger-dna](https://support.10xgenomics.com/single-cell-dna/software/pipelines/latest/using/cnv)
* [MEDALT](https://github.com/KChen-lab/MEDALT)
* [Xvfb](https://www.x.org/releases/X11R7.6/doc/man/man1/Xvfb.1.xhtml)
* [Cytoscape](https://cytoscape.org/)
* [R](https://www.r-project.org)

## Run modes
The pipeline has three run modes available; The first run mode is basic and the others are dependent on it; The detail of how-to-run is described in User's guider:
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
* Required for the run mode of cluster based analysis and can be generated using the result from the basic run mode:
  {output_directory}/reanalysis/{sampleID}/outs/group.txt
* Required for the run mode of cluster based analysis in merged patient samples and can be generated using the result from the basic run mode:
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
1016	1083	T
1024	953	T
1020	92	T
391	540	M
364	190	M
375	390	M
387	330	M
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
  snakemake -p --cores 14 --keep-going --rerun-incomplete --jobs 300 --latency-wait 120 all
  ```
* Look in log directory for logs for each rule
* To view the snakemkae rule graph:
```bash
snakemake --rulegraph | dot -T png > scDNA_whole.png
```
![dag](https://github.com/JieqiongDai/SingleCellCNV-Evolution/blob/master/scDNA_whole.png)


### V. Example output
```bash
. user/defined/output_dir/{}
├── link # main output files of cellranger-dna of all samples
│   ├── alarm # alarm files
│   │   ├── {sample_A}_alarms_summary.txt
│   │   ├── {sample_B}_summary.txt
│   │   └── {sample_C}_alarms_summary.txt 
│   ├── bam # indexed bam files
│   │   ├── {sample_A}_possorted_bam.bam
│   │   ├── {sample_A}_possorted_bam.bam.bai
│   │   ├── {sample_B}_possorted_bam.bam
│   │   ├── {sample_B}_possorted_bam.bam.bai
│   │   ├── {sample_C}_possorted_bam.bam
│   │   └── {sample_C}_possorted_bam.bam.bai
│   ├── loup # loup files
│   │   ├── {sample_A}_dloupe.dloupe 
│   │   ├── {sample_B}_dloupe.dloupe 
│   │   └── {sample_C}_dloupe.dloupe 
│   └── summary # summary files
│       ├── {sample_A}_web_summary.html 
│       ├── {sample_B}_web_summary.html 
│       └── {sample_C}_web_summary.html 
├── MEDALT # CNV evolutionary analysis results from the basic run mode
│   ├── {sample_A}
│   │   ├── gene.LSA.txt # list of genes associated with CNA 
│   │   ├── LSA.tree.pdf # lineage tracing of CNA
│   │   ├── medalt.cys # cytoscpe accessible file
│   │   ├── medalt.pdf # lineage tracing of single cell 
│   │   ├── segmental.LSA.txt # list of CNA
│   │   └── other output files
│   ├── {sample_B}
│   │   ├── medalt.cys
│   │   ├── medalt.pdf
│   │   └── other output files
│   ├── {sample_C}
│   │   ├── medalt.cys
│   │   ├── medalt.pdf
│   │   └── other output files
├── MEDALT_group # CNV evolutionary analysis results from the cluster based run mode
│   ├── {sample_A}
│   │   ├── gene.LSA.txt # list of genes associated with CNA 
│   │   ├── LSA.tree.pdf # lineage tracing of CNA
│   │   ├── medalt.group.cys # cytoscpe accessible file
│   │   ├── medalt.group.force.directed.cys # cytoscpe accessible file with force directed layout
│   │   ├── medalt.group.force.directed.pdf # lineage tracing of cluster with force directed layout
│   │   ├── medalt.group.pdf # lineage tracing of cluster
│   │   ├── segmental.LSA.txt # list of CNA
│   │   └── other output files
│   ├── {sample_B}
│   │   ├── medalt.group.cys
│   │   ├── medalt.group.force.directed.cys
│   │   ├── medalt.group.force.directed.pdf
│   │   ├── medalt.group.pdf
│   │   └── other output files
│   ├── {sample_C}
│   │   ├── medalt.group.cys
│   │   ├── medalt.group.force.directed.cys
│   │   ├── medalt.group.force.directed.pdf
│   │   ├── medalt.group.pdf
│   │   └── other output files
├── MEDALT_patient # CNV evolutionary analysis results from the cluster based and patient merged run mode
│   ├── {patient_A}
│   │   ├── gene.LSA.txt # list of genes associated with CNA 
│   │   ├── group_filter.txt
│   │   ├── LSA.tree.pdf # lineage tracing of CNA
│   │   ├── medalt.patient.cys # cytoscpe accessible file
│   │   ├── medalt.patient.force.directed.cys # cytoscpe accessible file with force directed layout
│   │   ├── medalt.patient.force.directed.pdf # lineage tracing of patient merged clusters with force directed layout
│   │   ├── medalt.patient.pdf # lineage tracing of patient merged clusters
│   │   ├── segmental.LSA.txt # list of CNA
│   │   └── other output files
├── {sample_A}
│   ├── cellranger-dan output files
├── {sample_B}
│   ├── cellranger-dan output files
├── {sample_C}
│   ├── cellranger-dan output files
└── reanalysis # cellranger-dna renalysis after noise filtering
    ├── link # main output files of cellranger-dna reanalysis of all samples
    │   ├── alarm # alarm files
    │   │   ├── {sample_A}_alarms_summary.txt 
    │   │   ├── {sample_B}_alarms_summary.txt 
    │   │   └── {sample_C}_alarms_summary.txt 
    │   ├── loup # loup files
    │   │   ├── {sample_A}_dloupe.dloupe 
    │   │   ├── {sample_B}_dloupe.dloupe 
    │   │   └── {sample_C}_dloupe.dloupe 
    ├── {sample_A}
    │   ├── cellranger-dan renalysis output files
    ├── {sample_B}
    │   ├── cellranger-dan renalysis output files
    ├── {sample_C}
    │   ├── cellranger-dan renalysis output files  
    └── tsne # tsne plots
        ├── {sample_A}_plotly_tsne_group.html # Rmarkdown file of tsne ploting with cluster information
        ├── {sample_A}_plotly_tsne.html # Rmarkdown file of tsne ploting
        ├── {sample_A}_tsne_group.pdf # tsne plot with cluster information
        ├── {sample_A}_tsne.pdf # tsne plot
        ├── {sample_B}_plotly_tsne_group.html 
        ├── {sample_B}_plotly_tsne.html 
        ├── {sample_B}_tsne_group.pdf 
        ├── {sample_B}_tsne.pdf
        ├── {sample_C}_plotly_tsne_group.html 
        ├── {sample_C}_plotly_tsne.html 
        ├── {sample_C}_tsne_group.pdf 
        └── {sample_C}_tsne.pdf 

```



