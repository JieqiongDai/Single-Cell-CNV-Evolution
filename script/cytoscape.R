#load libary for cytoscape and dependent packages
if(!"RCy3" %in% installed.packages()){
  install.packages("BiocManager")
  BiocManager::install("RCy3")
}
library(RCy3)
cytoscapePing ()
#create cytoscape network
edges <- read.table("CNV.tree2.txt",header=T, stringsAsFactors = F)
edges $ target <- as.character(edges $ target)
nodes <- edges[,2,drop=F]
nodes[nrow(nodes)+1,] <- c("root")
colnames(nodes)<-c("id")
nodes <- nodes[!duplicated(nodes),,drop=F]
createNetworkFromDataFrames(nodes,edges)
lockNodeDimensions(TRUE)
#switch styles
setVisualStyle('scCNV')
##select root node
selectNodes ('root','name')
# export pdf file
saveSession('medalt')
full.path=paste(getwd(),'medalt',sep='/')
exportImage(full.path, 'PDF')
