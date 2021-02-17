#load libary for cytoscape and dependent packages
if(!"RCy3" %in% installed.packages()){
  install.packages("BiocManager")
  BiocManager::install("RCy3")
}
library(RCy3)
cytoscapePing ()

#create cytoscape network
nodes <- data.frame(read.table("node_cyto.txt",sep="\t",header=T,row.names=NULL))
nodes <- nodes[,1:3]
colnames(nodes)<- c("id","cell.number","infor")
nodes[nrow(nodes)+1,] <- c("root",1,"root")
nodes $ cell.number <- as.numeric(nodes $ cell.number)
edges <- read.table("CNV.tree2.txt",header=T, stringsAsFactors = F)
edges $ target <- as.character(edges $ target)
edges $ dist <- as.numeric(edges $ dist)
createNetworkFromDataFrames(nodes,edges)
lockNodeDimensions(TRUE)
#switch styles
setVisualStyle('scCNV_group')
#set node size mapping
setNodeSizeMapping('cell.number', c(min(nodes$cell.number),max(nodes$cell.number)), c(10,60),style.name = "scCNV_group")
##select root node
selectNodes ('root','name')
# export pdf file
saveSession('medalt.group')
full.path=paste(getwd(),'medalt.group',sep='/')
exportImage(full.path, 'PDF')
#change to force directed layout
layoutNetwork('force-directed edgeAttribute=dist')
# export pdf file
saveSession('medalt.group.force.directed')
full.path=paste(getwd(),'medalt.group.force.directed',sep='/')
exportImage(full.path, 'PDF')