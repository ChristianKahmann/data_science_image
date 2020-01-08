### R code from vignette source 'fifer_package.Rnw'

###################################################
### code chunk number 1: fifer_package.Rnw:95-96
###################################################
options(prompt=" ", continue=" ")


###################################################
### code chunk number 2: fifer_package.Rnw:98-110 (eval = FALSE)
###################################################
## ### 1. first the package devtools must be installed
## install.packages("devtools")
## 
## ### 2. then we must load the package
## require(devtools)
## 
## ### 3. all that rigamarole to get the function install_github, 
## ### which is how we will install fifer
## install_github("fifer", username="dustinfife")
## 
## ### 4. now load the fifer package
## require(fifer)


###################################################
### code chunk number 3: fifer_package.Rnw:124-126
###################################################
require(fifer)
data(fakeMedicalData)


###################################################
### code chunk number 4: fifer_package.Rnw:128-138
###################################################
### first load the fakeMedicalData dataset
data(fakeMedicalData)
### show all the column names (well, the first 60 at least)
names(fakeMedicalData)[1:60]
### extract all column indices between B_regs_10A and B_regs_9B
bregs = r("B_regs_10A", "B_regs_9E", data.names=names(fakeMedicalData))
bregs
### return the names instead of the column indices
bregs = r("B_regs_10A", "B_regs_9E", data.names=names(fakeMedicalData), names=T)
bregs


###################################################
### code chunk number 5: fifer_package.Rnw:146-158
###################################################
### keep only the demographic/b_regs data
newData = make.null("ID","gender", "ethnicity", "age", 
				bregs, 
				data=fakeMedicalData, keep=TRUE)
### or we could drop everything between bregs and the end
newData2 = make.null(
			r("BCI_10A", "TNF_9E", data.names=names(fakeMedicalData)), 
			data=fakeMedicalData, keep=FALSE)
### check the dimensions of the dataset
dim(fakeMedicalData) 
dim(newData)
dim(newData2) 


###################################################
### code chunk number 6: fifer_package.Rnw:173-183
###################################################
### extract the variable names corresponding to Excel Columns AA, CD, and FF
excel.names = excelMatch("AA", "CD", "FF", names=names(fakeMedicalData))
excel.names
### or, we can extract the column indices instead 
### (note it does not require names in original dataset)
excel.names = excelMatch("AA", "CD", "FF", n=length(names(fakeMedicalData)))
excel.names
### now subset the matrix to just those using make.null
new.dat = make.null(excel.names, data=fakeMedicalData, keep=T)
head(new.dat)


###################################################
### code chunk number 7: fifer_package.Rnw:189-199
###################################################
#### generate random data (normally this would come from importing a file)
data = data.frame(matrix(rnorm(10*3), ncol=3))
names(data) = c("ANA.by.IFA.0.neg.40...pos", 
	"dsDNA....Calculated.", 
	"IgG..10.neg..10.19.low..20.89.mod...90.high")
#### print the names (so we can see how messy they are)	
names(data)
#### rename the column names, taking only the first element
names(data) = subsetString(names(data), sep=".", position=1)
names(data)


###################################################
### code chunk number 8: fifer_package.Rnw:214-221 (eval = FALSE)
###################################################
## original.path = "documents/research/medical_data_apr_2014.xlsx"
## require(xlxx)
## d = read.xlsx(original.path, sheetIndex=1, startRow=3)
## #### do some data manipulation and create a dataset 
## #### called d_new (not actually shown)
## write.fife(d_new, newfile="documents/research/medicalFormatted.csv", 
## 		originalfile=original.path, fullpath=T)


###################################################
### code chunk number 9: fifer_package.Rnw:241-242
###################################################
missing.vals(fakeMedicalData)


###################################################
### code chunk number 10: fifer_package.Rnw:248-249
###################################################
demographics(disease~age + gender + ethnicity, data=fakeMedicalData, latex=FALSE)


###################################################
### code chunk number 11: fifer_package.Rnw:253-255
###################################################
require(xtable)
print(xtable(demographics(disease~age + gender + ethnicity, data=fakeMedicalData, latex=TRUE), caption="Demographics of the Fake Medical Dataset"), sanitize.text.function=identity, caption.placement="top")


###################################################
### code chunk number 12: fifer_package.Rnw:262-270
###################################################
#### list all the variables I want to use using the r function
predictors = r("Glucose_10A", "Glucose_9E", names(fakeMedicalData), names=T)
### make sure it worked!
predictors
### now write the formula
formula = make.formula("disease", predictors)
### and look at it
formula


###################################################
### code chunk number 13: fifer_package.Rnw:277-283
###################################################
#### compute significance tests for each variable in dataset but the ID column
p.values = univariate.tests(dataframe=fakeMedicalData, exclude.cols=1, group="disease")
#### adjust those p-values using FDR (false discovery rate)
p.adjusted = p.adjust(p.values, method="fdr")
#### display only those that exceed statistical significance
p.adjusted[p.adjusted<.05]


###################################################
### code chunk number 14: fig2
###################################################
best.five = names(sort(p.adjusted)[1:5])
### prepare the layout
auto.layout(5)
for (i in 1:length(best.five)){
	### do my favorite default plotting parameters
	par1() 
	### make a formula
	formula = make.formula(best.five[i], "disease")
	### plot them
	densityPlotR(formula, data=fakeMedicalData, main="")	
}


###################################################
### code chunk number 15: fig3
###################################################
#### set layout again (but only first four)
auto.layout(4)
for (i in 1:4){
	### do my favorite default plotting parameters
	par1() 
	### make a formula
	formula = make.formula(best.five[i], "disease")
	### plot them
	prism.plots(formula, data=fakeMedicalData)
	### show significance bars
	plotSigBars(formula, data=fakeMedicalData, type="tukey")

}


###################################################
### code chunk number 16: fig4
###################################################
	### change default parameters
par2() 
	#### color code according to disease status
colors = string.to.colors(fakeMedicalData$disease, colors=c("blue", "red"))
	#### change symbol according to disease status
pch = as.numeric(string.to.colors(fakeMedicalData$disease, colors=c(15, 16)))
	#### plot it
plot(fakeMedicalData[,best.five[1]], fakeMedicalData[,best.five[2]], col=colors, 
		pch=pch, xlab = best.five[1], ylab=best.five[2])
legend("bottomright", c("Case", "Control"), pch=c(15,16), 
		col=c("blue", "red"), bty="n")


###################################################
### code chunk number 17: fig5
###################################################
	#### simulate skewed data (just for the demo)
x = rnorm(100)^2
y = rnorm(100)^2

	### induce a correlation of .6 (approx) with choselski decomp
cor = matrix(c(1, .6, .6, 1), nrow=2)	
skewed.data = cbind(x,y)%*%chol(cor)
names(skewed.data) = c("x", "y")

	#### show original plot
par2()	
plot(skewed.data, xlab="x", ylab="y")


###################################################
### code chunk number 18: fig6
###################################################
#### now show the spearman version of the plot
par2()
spearman.plot(skewed.data, xlab="rank(x)", ylab="rank(y)", pch=16)


