# Using the Command Line to build a phylogenetic tree with NCBI Data
*Written by Tamara Gademann & Boukje Heidstra*
#01.02.2018, University of Groningen

Read this whole file before useing the script!

##Description:
This is a LINUX-Script. It was created to download requested sequences from the database NCBI/GenBank, to align these and in addition to plot a phylogenetic tree from the data. The script downloads the sequences from one or several species and combines them all into a masterfile, called allseq.fasta. This file is going to be aligned and estimated, before the script changes to R, where a second script will run (plotTree.r) to plot the phylogenetic tree. This tree will be saved as a PDF.

#Before you start you have to install edirect in your command line, therefore copy the following terms in your Command Line:
#Further information on: https://www.ncbi.nlm.nih.gov/books/NBK179288/
'''
cd ~
  /bin/bash
  perl -MNet::FTP -e \
    '$ftp = new Net::FTP("ftp.ncbi.nlm.nih.gov", Passive => 1);
     $ftp->login; $ftp->binary;
     $ftp->get("/entrez/entrezdirect/edirect.tar.gz");'
  gunzip -c edirect.tar.gz | tar xf -
  rm edirect.tar.gz
  builtin exit
  export PATH=$PATH:$HOME/edirect >& /dev/null || setenv PATH "${PATH}:$HOME/edirect"
  ./edirect/setup.sh
  
   echo "export PATH=\$PATH:\$HOME/edirect" >> $HOME/.bash_profile
'''
   
#Also install the programs you need in order to run the script. Just tipe following and follow the instructions in the Command Line:
clustalw
phyml
   
#In order to run the R script, make sure the following packages are installed in R:
install.packages('devtools')
install.packages('ape')
install.packages('phangorn')
   
#If you run the following script your main directory is the Documents folder, so be sure that you have downloaded all necessary files in this Documents folder!
   
##Description of the Steps:
   
#Step1: Downloading DNA Sequences from the database (NCBI) and creating a masterfile with all the DNA sequences of the requested species
 '''
#Ask user to enter species name
read -p "Enter species name: " specname1
#Print species name while waiting for next steps to be run (file to be created)
echo -e "Getting $specname1 DNA"

#For entered species name, download DNA sequences from database (NCBI/GenBank) and create a fastafile per species.
esearch -db Nucleotide -query "$specname1" | efetch -format fasta >> ~/Documents/"$specname1".fasta
'''
#The program will ask if there are more species to be entered using while loop
'''
while [ -z "$REPLY" ] ; do 
	if [ -z "$1" ] ; then 
		read -p "Do you want to enter another species?(Yes/No): "
		else
			REPLY=$1
			set --
	fi

  #Use case statement to process commandline for either yes (new species) or no (continue script).
	case $REPLY in
		[Yy]es) #if Yes, repeat DNA search for newly entered species
			read -p "Enter species name: " specname2
			echo -e "Getting $specname2 DNA"
			esearch -db Nucleotide -query "$specname2" | efetch -format fasta >> ~/Documents/"$specname2".fasta
			unset REPLY ;;
		[Nn]o) #if no more species to be entered, continue with rest of script
			echo -e "Continuing...\n"
			#Print an overview of the number of sequences in each file
			echo "Number of sequences per file: "
			grep -c ">" ~/Documents/*.fasta
			#Print the next steps that will be run
			echo "Combining all species into one file and starting alignment"
	esac
done
'''
#Rename all files; replace all spaces in filenames by underscores, to make it possible to search for and combine  all species DNA into one file
'''
rename -f 's/ /_/g' ~/Documents/*.fasta
cat ~/Documents/*.fasta > ~/Documents/allseq.fasta
'''
   
#Step2: Aligning sequences
'''
clustalw -INFILE=allseq.fasta -TYPE=DNA -OUTFILE=out_allseq.phy -OUTPUT=PHYLIP
'''
   
#Step3: Estimating the most suitable tree
'''
phyml -i out_allseq.phy -d nt -n 1 -m HKY85
'''
   
#Step4: Plotting & saving the tree with R, the Command Line calls R with the following command
'''
Rscript plotTree.r
'''

#After R was called, the following script runs (plotTree.r)
'''
setwd('~/Documents/')

#Again, make sure packages are installed
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
'''
##Scripts
1. finalfile.sh
2. plotTree.r
