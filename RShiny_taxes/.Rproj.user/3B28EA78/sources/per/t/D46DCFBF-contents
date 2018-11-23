#Read in the data
install.packages("ggplot2")   # package not one of the default R libraries
require(ggplot2)    # ensure package is loaded


taxes <- read.csv(file.path("Taxes CH_01.csv"), stringsAsFactors=FALSE)
head(taxes)


plot(x=taxes$Taxable.Income, y=taxes$Tax.perc., xlab="Taxable Income", ylab="Tax (%)", col = ifelse(taxes$Canton="SO",'red','black'))

qplot(Taxable.Income, Tax.perc., colour = Canton, data = taxes)

plot(x=taxes$ï..Year, y=taxes$Total.Tax, xlim=)
?plot


x = taxes[taxes$Canton == "BE", 8]

x
+