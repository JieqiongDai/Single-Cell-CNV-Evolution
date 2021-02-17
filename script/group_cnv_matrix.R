# Check required packages
# function for installing needed packages
installpkg <- function(x){
    if(x %in% rownames(installed.packages())==FALSE) {
        if(x %in% rownames(available.packages())==FALSE) {
            paste(x,"is not a valid package - please check again...")
        } else {
            install.packages(x)           
        }

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
#read in group ids
group <- read.table("group.txt")
group
# get cnv information in selected groups
data <- data[data$V4 %in% group$V1,]
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
#filter out evidence confident score =0 regions
data2 <- data2[data2 $V6 >0,]
#split cnv information for each cell and ouput the table
library(tidyr)
data3 <- data2[,c(1,2,4,5)]
data3 $ V2 <- as.character(data3 $ V2)
data4 <- pivot_wider(data3,names_from = V4,values_from = V5)
#filter out groups with more than 50% na values (score =0)
data4 <- data4[,which(colMeans(!is.na(data4)) > 0.5)]
data4 <- data4[complete.cases(data4),]
colnames(data4)[c(1,2)] <- c("chrom","chrompos")
data4 $ chrom <- sapply(data4$chrom,function(x) gsub("chr","",x))
data4 $ chrom <- as.character(data4 $ chrom)
write.table(data4,"./group/scDNA.CNV.txt",quote=F,sep = "\t",row.names=F)
#generate group_filter.txt
group2 <- group[group$V1 %in% colnames(data4),]
group2
write.table(group2,"group_filter.txt",quote=F,sep = "\t",row.names=F,col.names=F)

