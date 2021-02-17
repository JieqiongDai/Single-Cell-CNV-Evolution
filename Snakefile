# vim: ft=python
import sys
import os
import csv
import os.path
from os import path

shell.prefix("set -eo pipefail; ")
configfile:"config/config.yaml"
localrules: all

# Define directories
run = os.getcwd() + "/"
raw = config["raw"]
fastq = config["fastq"]
out = config["out"]

# Import other variables from the config file
flowcell=config["flowcells"]
table = config["table"]
ref = config["ref"]
medalt = config["medalt"]
genome = config["genome"]

# Define wildcards
with open(table,'r') as f:
     reader = csv.reader(f)
     sample = list(zip(*reader))[1]
     sample = sample[1:]

patient=os.listdir("patient/")

wildcard_constraints:
     sample= '|'.join([re.escape(x) for x in sample]),
     patien= '|'.join([re.escape(x) for x in patient])

if (config["group"]=="ready" and config["patient"]=="ready"):
   include: "modules/Snakefile_gen"
   include: "modules/Snakefile_group"
   include: "modules/Snakefile_patient"
   rule all:
       input:
             expand(out + "link/summary/{sample}_web_summary.html",sample=sample),
             expand(out + "reanalysis/link/loup/{sample}_dloupe.dloupe",sample=sample),
             "redundant_removed.txt",
             expand(out + "MEDALT/{sample}/medalt.pdf",sample=sample),
             expand(out + "reanalysis/link/tsne/{sample}_plotly_tsne.html",sample=sample),
             expand(out + "MEDALT_group/{sample}/singlecell.tree.pdf",sample=sample),
             expand(out + "MEDALT_group/{sample}/medalt.group.force.directed.pdf",sample=sample),
             expand(out + "reanalysis/link/tsne/{sample}_plotly_tsne_group.html",sample=sample),
             expand(out + "MEDALT_patient/{patient}/singlecell.tree.pdf",patient=patient),
             expand(out + "MEDALT_patient/{patient}/medalt.patient.force.directed.pdf",patient=patient)

elif config["group"]=="ready":
     include: "modules/Snakefile_gen"
     include: "modules/Snakefile_group"
     rule all:
         input:
               expand(out + "link/summary/{sample}_web_summary.html",sample=sample),
               expand(out + "reanalysis/link/loup/{sample}_dloupe.dloupe",sample=sample),
               "redundant_removed.txt",
               expand(out + "MEDALT/{sample}/medalt.pdf",sample=sample),
               expand(out + "reanalysis/link/tsne/{sample}_plotly_tsne.html",sample=sample), 
               expand(out + "MEDALT_group/{sample}/singlecell.tree.pdf",sample=sample),
               expand(out + "MEDALT_group/{sample}/medalt.group.force.directed.pdf",sample=sample),
               expand(out + "reanalysis/link/tsne/{sample}_plotly_tsne_group.html",sample=sample)

else:
     include: "modules/Snakefile_gen"
     rule all:
         input:
               expand(out + "link/summary/{sample}_web_summary.html",sample=sample),
               expand(out + "reanalysis/link/loup/{sample}_dloupe.dloupe",sample=sample), 
               "redundant_removed.txt",
               expand(out + "MEDALT/{sample}/medalt.pdf",sample=sample),
               expand(out + "reanalysis/link/tsne/{sample}_plotly_tsne.html",sample=sample)
