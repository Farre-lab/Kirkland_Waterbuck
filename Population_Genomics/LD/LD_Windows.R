#!/bin/R

# commmandArgs:
Args = commandArgs(TRUE)
Data <- Args[1]
Chr <- Args[2]
Output <- Args[3]

## LD

LD <- read.delim(Data, sep = "\t", header = TRUE)

LD[sapply(LD, is.infinite)] <- NA

LD$pos1 = as.numeric(gsub(".*:", "", LD$site1))
LD$pos2 = as.numeric(gsub(".*:", "", LD$site2))

window.size= 100000

breaks = seq(0, max(LD$pos1, LD$pos2), by = window.size)

LD$interval1 = findInterval(LD$pos1, breaks)
LD$interval2 = findInterval(LD$pos2, breaks)

positions = c()
LD.means = c()

for (i in 1:max(LD$interval1, LD$interval2)) {
  index = which(LD$interval1 == i & LD$interval2 == i)
  positions <- append(positions, (i-1) * window.size + window.size / 2)
  LD.means <- append(LD.means, mean(LD$r2[index], na.rm = TRUE))
}

LD.output <- data.frame(chr = Chr, midpos = positions, ld = LD.means)

write.table(LD.output, file = paste(Output, '.tsv', sep = ""), sep = "\t", col.names = TRUE, row.names = FALSE, quote = FALSE)
