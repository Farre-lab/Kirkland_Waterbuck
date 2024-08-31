library(ape)

df <- read.table("all.outgroup.singleReadSampling.ibsMat", header = FALSE)
nam <- "bam_list_all.txt"

colnames(df) <- scan(nam, what = "raw")
a <- ape::fastme.bal(as.matrix(df))
a <- ape::root(a, "4749_UgandanKob_Outgroup")

pdf("all.outgroup.singleReadSampling.ibsMat.pdf", height=16, width=10)
ape::plot.phylo(a, cex=0.5, align.tip.label = TRUE)
ape::add.scale.bar(x=0, y=-1,cex=0.5)
dev.off()

ape::write.tree(a, "all.outgroup.singleReadSampling.ibsMat.tree")
