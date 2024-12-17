#!/bin/R

## Pairwise LD in windows

# commmandArgs:
Args = commandArgs(TRUE)
Data <- Args[1]
Output <- Args[2]

## LD

LD <- read.delim(Data, sep = "\t", header = FALSE)

window.size= 1000000

breaks1 = seq(0, max(LD$V2), by = window.size)
breaks2 = seq(0, max(LD$V4), by = window.size)

LD$interval1 = (findInterval(LD$V2, breaks1) - 1) * window.size
LD$interval2 = (findInterval(LD$V4, breaks2) - 1) * window.size

LDMean <- aggregate(LD$V9, by = list(LD$interval1, LD$interval2, LD$V1, LD$V3), mean, na.rm = TRUE)

LDOutput <- data.frame(Chr1 = LDMean$Group.3, Pos1 = LDMean$Group.1, Chr2 = LDMean$Group.4, Pos2 = LDMean$Group.2, LD_Mean = LDMean$x)

write.table(LDOutput, file = paste(Output, '.tsv', sep = ""), sep = "\t", col.names = TRUE, row.names = FALSE, quote = FALSE)
