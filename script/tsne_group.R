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
required_packages  <- c('ggplot2','Rtsne','plotly','rhdf5','dplyr')
lapply(required_packages,installpkg)

#tsne plots with cellranger group information
#read in CNV matrix
cnv <- read.table("scDNA.CNV.txt",header=T)
cnv <- cnv[,3:ncol(cnv)]
#tsne
library(Rtsne)
n <- ncol(cnv)
if (n/100>=30)
{k=n/100} else {k=30}
if (n/12>=200)
{l=n/12} else {l=200}
set.seed(66)
tn <- Rtsne(t(cnv),check_duplicates=F,perplexity=k,eta=l)
df <- as.data.frame(tn$Y)
df $ cell <- seq(0,nrow(df)-1)
#get cell in group information from hdf5vfile
library(rhdf5)
data <- as.data.frame(h5read("cnv_data.h5","/tree/is_cell_in_group"))
row <- seq(0,nrow(data)-1)
rownames(data) <- row
col <- seq(nrow(data),2*(nrow(data)-1))
colnames(data)<- col
group <- read.table("group.txt")
group
g <- data[,colnames(data)%in%group$V1]
for (i in 1:ncol(g))
{
a <- g[,i,drop=F]
a$cell <-seq(0,nrow(data)-1)
a<- a[a[,1]==1,]
a[,1]<-rep(colnames(a[1]),nrow(a))
library(dplyr)
df <-left_join(df,a,by=c("cell"))
}
library(tidyr)
b <- colnames(df)[4:ncol(df)]
df2 <- unite(df,"group",all_of(b),na.rm=T)
df2 $group <- as.character(df2$group)
#plot
library(ggplot2)
library(ggrepel)
pdf("tsne_group.pdf")
ggplot(df2,aes(x=V1, y=V2,colour=group))+ geom_point(size=1.25) +  guides(colour = guide_legend(override.aes = list(size=4)))  +
  xlab("tSNE dimension 1") + ylab("tSNE dimension 2") +
  ggtitle("tSNE 2D single cell CNV") +
  theme_light(base_size=20) +
  theme(strip.background = element_blank(),
        strip.text.x     = element_blank(),
        axis.text.x      = element_blank(),
        axis.text.y      = element_blank(),
        axis.ticks       = element_blank(),
        axis.line        = element_blank(),
        panel.border     = element_blank()) +
  theme(
        title = element_text(size = 12),
        axis.text.x = element_text(size = 10),
        axis.text.y = element_text(size = 10)
        )
dev.off()
library(plotly)
htmlwidgets::saveWidget(plot_ly(df2,x=~V1,y=~V2,color=~group,text=rownames(df)),"plotly_tsne_group.html")
