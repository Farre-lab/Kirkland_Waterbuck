# plots a pca, from covaraince matrix (pcangad format) and pop file (one column population assignemnt for each sample) produces png with pc1 vs pc2
# Rscript plotPCA.R "cov_matrix_filename" "pop_filename" "outpng_filename"

Args = commandArgs(TRUE)

covfile <- Args[1]
popfile <- Args[2]
outpng <- Args[3]

cov <- as.matrix(read.table(covfile))
ei <- eigen(cov)
e <- ei$vectors
v <- ei$values
vars <- v/sum(v)*100

pop <- scan(popfile, what="dfas")
npop <- length(unique(pop))

# allows up up to 20 different populations, kelly palette from package catecolors https://github.com/btupper/catecolors
cols <- c("#FFB300", "#803E75", "#FF6800", "#A6BDD7", "#C10020",  "#CEA262", "#817066", "#007D34", "#F6768E", "#00538A", "#FF7A5C", "#53377A", "#FF8E00", "#B32851", "#F4C800", "#7F180D", "#93AA00", "#593315", "#F13A13", "#232C16", "black", "red", "blue", "yellow")
cols <- cols[1:npop]
names(cols) <- unique(pop)

pdf(file = paste(outpng, ".pdf", sep = ""), width = 8, height = 6)
par(mar=c(5,5,1,10))
xlegend <- max(e[,1]) * 1.1
ylegend <- max(e[,2])         
plot(e[,1], e[,2], pch=21, cex=1.5, bg=cols[pop], xlab=paste0("PC 1 (",round(vars[1], 2),"%)"), ylab=paste0("PC 2 (",round(vars[2], 2),"%)"),cex.lab=1.2)
legend(x=xlegend, y=ylegend,
       legend=unique(pop), pt.bg=cols,
       pch=21,cex=1, pt.cex=1,bty='n', xpd=NA)
dev.off()


