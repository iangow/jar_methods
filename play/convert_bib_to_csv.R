library(bibtex)
temp <- read.bib("~/Google Drive/Accounting_2014/accounting_2014b.bib")

bib.df <- data.frame(name=unlist(temp$key), journal=unlist(temp$journal),
                   year=unlist(temp$year), title=unlist(temp$title),
                   url=unlist(temp$url), uri=unlist(temp$uri),
                   stringsAsFactors=FALSE) 
bib.df$uri <- gsub("\\\\url\\{(.*)\\}", "\\1", bib.df$uri)
bib.df$title <- gsub("[{}]", "", bib.df$title)
bib.df$title <- gsub("(\\\\textquote(dbl)?(right|left))", "", bib.df$title)
head(bib.df)
write.csv(bib.df, file="~/Google Drive/Accounting_2014/accounting_2014b.csv")
