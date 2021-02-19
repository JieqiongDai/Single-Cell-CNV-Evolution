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
required_packages  <- c('dplyr','tidyr')
lapply(required_packages,installpkg)

#read in raw cnv bed file
data <- read.table("node_unmerged_cnv_calls.bed")
nrow(data)
#number of cells
nu <- (max(data $ V4))/2 +1
nu
# filter out group cnv informaion, only keep cell cnv information
data <- data[data$V4 < nu,]
data <- data[order(data$V4,data$V1,data$V2,data$V3),]
nrow(data)
#read in mappable regions bed file
region <- read.table("mappable_regions.bed")
nrow(region)
# get cnv in mapable regions
library(dplyr)
data2 <- semi_join(data,region,by=c("V1","V2"))
nrow(data2)
nrow(data2)/nrow(region)
#split cnv information for each cell and ouput the table
library(tidyr)
data3 <- data2[,c(1,2,4,5)]
data3 $ V2 <- as.character(data3 $ V2)
data4 <- pivot_wider(data3,names_from = V4,values_from = V5)
colnames(data4)[c(1,2)] <- c("chrom","chrompos")
data4 $ chrom <- sapply(data4$chrom,function(x) gsub("chr","",x))
data4 $ chrom <- as.character(data4 $ chrom)
write.table(data4,"scDNA.CNV.txt",quote=F,sep = "\t",row.names=F)
                      

