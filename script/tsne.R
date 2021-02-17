# Check required packages
# function for installing needed packages
installpkg <- function(x){
    if(x %in% rownames(installed.packages())==FALSE) {
        if(x %in% rownames(available.packages())==FALSE) {
            paste(x,"is not a valid package - please check again...")
        } else {
            install.packages(x, repos="https://mirror.las.iastate.edu/CRAN/")           
        }

    } else {
        paste(x,"package already installed...")
    }
}

# install necessary packages
required_packages  <- c('ggplot2','Rtsne','plotly')
lapply(required_packages,installpkg)

#tsne plots
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
#plot
library(ggplot2)
df <- as.data.frame(tn$Y)
pdf("tsne.pdf")
ggplot(df,aes(x=V1, y=V2))+ geom_point(size=1.25) +  guides(colour = guide_legend(override.aes = list(size=6))) +
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
htmlwidgets::saveWidget(plot_ly(df,x=~V1,y=~V2,text=rownames(df)),"plotly_tsne.html")
