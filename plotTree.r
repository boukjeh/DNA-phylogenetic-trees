setwd('/home/boukje/Documents/Project/Step1/Results1')

#Make sure packages are installed
#Install devtool package in order to install packages for APE
#install.packages('devtools')

#Install packages that provide the basis for manipulating sequence data in R: ape and phangorn.
#install.packages("ape")
#install.packages("phangorn")
#install.packages("seqinr")

#Call packages
library(ape)
library(phangorn)
library(seqinr)

#create a tree after aligning with clustal and estimating tree with phyml
MyTree <- read.tree("out_allseq.phy_phyml_tree")
pdf("Tree.pdf")
plot(MyTree)
dev.off()


