library(data.table)

#' \code{annotate_pm} add Ensembl annotations to a CHIGAGO peakmatrix
#'
#' @param ban_file - bait annotation filename 
#' @param pm_file - peak matrix filename
#' @param out_file - output filename
#' @return a scalar logical depending on outcome
#' @export

annotate_pm<-function(ban_file,pm_file,out_file){
	#read in peak matrix format
	message(sprintf("Reading in peakMatrix file -  %s",pm_file))
	pm<-fread(pm_file)
	setkey(pm,baitID)
	pm[,int.id:=paste(baitID,oeID,sep=':')]
	#read in annotations
	message(sprintf("Reading in bait annotation file -  %s",ban_file))
	an<-fread(ban_file)
	ban<-an[,c('name','ensg','biotype','strand'):=tstrsplit(V5,':')][,c(4,6:9),with=FALSE]
	setnames(ban,'V4','baitID')
	setkey(ban,baitID)
	re.int<-pm[which(pm$oeID %in% ban$baitID),]
	## remove those that we already have
	dup.idx<-which(with(re.int,paste(oeID,baitID,sep=':')) %in% pm$int.id)
	#re.int<-re.int[-dup.idx,]
	## flip stuff around
	bnames<-c('baitChr','baitStart','baitEnd','baitID','baitName')
	oenames<-sub('bait','oe',bnames,fixed=TRUE)
	setnames(re.int,c(bnames,oenames),c(oenames,bnames))
	setcolorder(re.int,c(bnames,oenames,names(re.int)[11:29]))
	re.int[,dist:=dist * -1]
	pm.denorm<-rbind(pm,re.int)
	## merge the two data.frames
	DT<-merge(ban,pm.denorm,by.x='baitID',by.y='baitID',allow.cartesian=TRUE)
	export.names<-head(c('ensg','name','biotype','strand',names(pm)),-1)
	DT<-DT[,export.names,with=FALSE]
	DT<-subset(DT,!is.na(ensg))
	setkey(DT,ensg)
	message(sprintf("Writing merged file to %s",out_file))
	write.table(DT,file=out_file,sep="\t",quote=FALSE,row.names=FALSE)
}
