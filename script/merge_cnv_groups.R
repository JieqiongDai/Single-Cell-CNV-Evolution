# merge groups in normal, primary tumor and metastasis tumor from the same patient

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


#read in group.txt file
group <- read.table(snakemake@input[[7]])
group

#read in raw cnv bed file from normal sample and select related grops
data_n <- read.table(snakemake@input[[1]])
group_n <- group[group$V3=="N",,drop=F]
data_n2 <- data_n[data_n$V4 %in% group_n$V1,,]
data_n2 <- data_n2[order(data_n2$V4,data_n2$V1,data_n2$V2,data_n2$V3),]

#read in raw cnv bed file from primary tumor sample and select related grops
data_t <- read.table(snakemake@input[[2]])
group_t <- group[group$V3=="T",,drop=F]
data_t2 <- data_t[data_t$V4 %in% group_t$V1,,]
data_t2 <- data_t2[order(data_t2$V4,data_t2$V1,data_t2$V2,data_t2$V3),]

#read in raw cnv bed file from metastasis tumor sample and select related grops
data_m <- read.table(snakemake@input[[3]])
group_m <- group[group$V3=="M",,drop=F]
data_m2 <- data_m[data_m$V4 %in% group_m$V1,,]
data_m2 <- data_m2[order(data_m2$V4,data_m2$V1,data_m2$V2,data_m2$V3),]

# combine N,T and M data
data <- rbind(data_n2,data_t2,data_m2)

#read in mappable regions bed file
region_n <- read.table(snakemake@input[[4]])
nrow(region_n)
region_t <- read.table(snakemake@input[[5]])
nrow(region_t)
region_m <- read.table(snakemake@input[[6]])
nrow(region_m)
region <- merge(region_n,region_t,by=c(1,2,3))
region <- merge(region,region_m,by=c(1,2,3))
nrow(region)

# get cnv in mapable regions
library(dplyr)
data2 <- semi_join(data,region,by=c("V1","V2"))
nrow(data2)
nrow(data2)/nrow(region)

#filter out evidence confident score =0 regions
data2 <- data2[data2 $V6 >0,]

#split cnv information for each group and ouput the table
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
write.table(data4,snakemake@output[[1]],quote=F,sep = "\t",row.names=F)
#generate group_filter.txt
group2 <- group[group$V1 %in% colnames(data4),]
group2
write.table(group2,snakemake@output[[2]],quote=F,sep = "\t",row.names=F,col.names=F)
