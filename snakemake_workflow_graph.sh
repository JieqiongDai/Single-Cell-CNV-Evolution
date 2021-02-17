#!/bash/bin
module load graphviz
snakemake --rulegraph | dot -T png > scDNA_whole.png

