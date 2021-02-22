# Check required packages
# function for installing needed packages
installpkg <- function(x){
  r = getOption("repos")
  r["CRAN"] = "http://cran.us.r-project.org"
  options(repos = r)
  if(x %in% rownames(installed.packages())==FALSE) {
    if(x %in% rownames(available.packages())==FALSE) {
      if (!requireNamespace("BiocManager", quietly = TRUE))
        install.packages("BiocManager")
      BiocManager::install(x,ask = FALSE)
    } else {
      install.packages(x)
    }
    paste(x, "package is installed...")
  } else {
    paste(x,"package already installed...")
  }
}

# install necessary packages
required_packages  <- c('RCy3','argparse')
lapply(required_packages,installpkg)

#load libary for cytoscape and dependent packages
library(RCy3)
cytoscapePing ()

library(argparse)
parser <- ArgumentParser()
parser$add_argument('-s',
                    '--style',
                    nargs='+',
                    required=TRUE,
                    help="cytoscape style file")
args <-parser$parse_args()

style <- c(args$style)

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
if ("scCNV" %in% getVisualStyleNames() == "FALSE")
importVisualStyles(style)
setVisualStyle('scCNV')
##select root node
selectNodes ('root','name')
# export pdf file
saveSession('medalt')
full.path=paste(getwd(),'medalt',sep='/')
exportImage(full.path, 'PDF')
