#!/bin/R

## Admixture Plots:

library(ggplot2)
library(tidyr)

## Input Files:
bam <- read.delim("bam_list.txt", header = FALSE, col.names = c("Sample"))
bam <- as.matrix(bam)

pop <- read.delim("pop_list1.txt", header = FALSE, col.names = c("Pop"))
pop <- as.matrix(pop)

species <- read.delim("species_list.txt", header = FALSE, col.names = c("Species"))
species <- as.matrix(species)

# Plot:
pdf("k2-12_species_pop_sample.pdf", height = 6, width = 12, pointsize = 8)
for (k in c(2:12)) {
  print(k)
  qopt <- read.delim(file = paste("waterbuck.admixture",k,"qopt", sep = "."), sep = " ", header = FALSE)
  qopt <- qopt[ ,colSums(is.na(qopt))==0]
  qopt <- as.matrix(qopt)
  qoptcbind <- cbind(qopt, bam, pop, species)
  qoptcbind <- data.frame(qoptcbind)
  qoptcbind <- pivot_longer(qoptcbind, cols=c(1:k),names_to="Q",values_to="Value")
  qoptcbind$Value = as.numeric(as.character(qoptcbind$Value)) 
  qoptcbind <- data.frame(Species_Pop_Sample = paste(qoptcbind$Species, qoptcbind$Pop, qoptcbind$Sample, sep = "_"), Q = qoptcbind$Q, Value = qoptcbind$Value)
  print(ggplot(qoptcbind,aes(x=Species_Pop_Sample,y=Value,fill=Q)) + 
  geom_bar(stat="identity",position="stack") + labs(fill = paste("k=",k,sep="")) +
  theme(axis.text.x = element_text(angle = 90, hjust=0.95, vjust=0.2, size = 4)))
}
dev.off()

