####### Required Packages

install.packages("poisson")
install.packages("devtools")
install_github("easyGgplot2", "kassambara")
install.packages("gridExtra")
install.packages("mstate")
install.packages("flexsurv")
install.packages("multistateutils")
install.packages("gems")
install.packages('survminer')
install.packages("xlsx")






###### Required Libraries
library(poisson)
library(devtools)
library(easyGgplot2)
library(scales)
library(gridExtra)
library(flexsurv)
library(mstate)
library(multistateutils)
library(gems)
library(survminer)
library(survival)
library(xlsx)




### Read the excel file which includes the "Site ID", "Country", "Target Number of Subjects", "Site Initiation Visit"
# The initial excel file needed the changed described in https://answers.microsoft.com/en-us/office/forum/office_2007-excel/how-do-i-remove-the-time-section-of-a-date-format/9465396d-485a-e011-8dfc-68b599b31bf5?db=5
# Loading xlsx files
parameters.table<-read.xlsx("Simulation Site Initiation Visit.xlsx",sheetIndex=1)
parameters.table<-parameters.table[,c(1:4,7)]
## Site initiation date
parameters.table[,4]<-format(parameters.table[,4],"%Y-%m-%d")



############################## INPUT Parameters of our function ###########################################

n=300
## number of sites


target=as.vector(parameters.table[,3])
##Total potentially eligible patients at each site for the study duration.
## It is a vector with length equal to the number of sites (n).

years=(as.vector(parameters.table[,5]))

rate=(as.vector(parameters.table[,3]))/years ## annual average rate
## "Annual" average rate of potentially eligible patients for each site.
## It is a vector with length equal to the number of sites (n).


origin=as.vector(parameters.table[,4])
## The initiation date of each site.
## It is a vector with length equal to the number of sites (n). These dates should not exceed the date that we aim to complete the recruitment.


country=as.vector(parameters.table[,2])
## Country ID


format="%d%b%Y"
## the format of dates


c=2:5
## Number of dates that will be added to the screening dates generated from our function to create the randomization dates.


cohortSize=12000
## It corresponds to the total number of patients that we will recruit (i.e. the total sample size).


to=180
##Time from screening until the end of study (6 months=180 days).



## Define the eligibility criteria
## It is a function which creates an eligibility flag according to individual characteristics from the recruited population.
non.eligble<-function(dataframe) {
  dataframe[,11]<-as.character(dataframe[,11])
  for(i in 1:dim(dataframe)[1]){
    if ((dataframe[i,7]==500)) {dataframe[i,11]<-"No"}
  }
  return(dataframe)

}



## Defines the treatment arm (Active or Placebo) for each patient.
## This is a function based on permuted block size randomization. For this function, we need the size of the block.
blockrand = function(seed,blocksize,N){
  set.seed(seed)
  block = rep(1:ceiling(N/blocksize), each = blocksize)
  a1 = data.frame(block, rand=runif(length(block)), envelope= 1: length(block))
  a2 = a1[order(a1$block,a1$rand),]
  a2$arm = rep(c("Active", "Placebo"),times = length(block)/2)
  assign = a2[order(a2$envelope),]
  return(assign)
}

Treatment.Group<-blockrand(1,6,(sum(target)+n))[1:(sum(target)+n),4]





##### Specify baseline characteristics (e.g. age, gender, smoking,home)


## Gender
gender<-rbinom((sum(target)+n), 1, 0.57)
## 0-->female, 1-->male



## Age for male and female
age<-function(dataframe) {
  dataframe[,7]<-as.numeric(dataframe[,7])
  for(i in 1:dim(dataframe)[1]){
    if ((dataframe[i,6]==0)) {dataframe[i,7]<-round(rnorm(1, mean=71, sd=13))} ## female
    if ((dataframe[i,6]==1)) {dataframe[i,7]<-round(rnorm(1, mean=67, sd=13))} ## male
  }
  return(dataframe)
}


## Smoking Status
smoking<-rbinom((sum(target)+n), 1, 0.3)
## 0-->non-smoker, 1-->smoker


## Home status
home<-rbinom((sum(target)+n), 1, 0.2)
## 0-->city, 1-->countryside







############################ FUNCTION ###################################################

set.seed(10434343)


General<- function( n, target, rate, origin, format, c, cohortSize, to, Treatment.Group,gender, age, smoking, home,country) {

  x<-NULL
  y<-NULL
  w<-NULL
  z<-NULL
  r<-NULL
  k<-NULL
  l<-NULL
  e<-NULL
  N<-NULL



  Pts.per.site<-NULL

  for(i in 1:n) {

    suffix<-seq(1:n)

    x[[i]]<- hpp.sim(rate[i], target[i])
    y[[i]]<-365*hpp.sim(rate[i], target[i])

    l[[i]]<- y[[i]]+sample(c, length(target[i]), replace=TRUE)

    w[[i]]<-as.Date( y[[i]], origin[i])
    z[[i]]<-format(w[[i]], format)


    r[[i]]<-as.Date( l[[i]], origin[i])
    e[[i]]<-format(r[[i]], format)

    #k[[i]]<-rep(paste("Site", paste(suffix[i])), length(z[[i]]))
    #k[[i]]<-rep(paste("Site", paste(as.vector(parameters.table[,1]))), length(z[[i]]))
    N[[i]]<-c(0:target[i])

  }



  #### Eligibility Flag according to inclusion/exclusion criteria
  eligible.flag<-rep("Yes",(sum(target)+n))

  #### Age
  age.0<-rep(0,(sum(target)+n))


  ###Site ID
  Site.number<-as.vector(parameters.table[,1])
  Site<-NULL
  for (i in 1:n){
    Site[[i]]<-rep(Site.number[i],(target[i]+1))
  }

  ###Country ID
  Country.number<-as.vector(parameters.table[,2])
  Country.ID<-NULL
  for (i in 1:n){
    Country.ID[[i]]<-rep(Country.number[i],(target[i]+1))
  }



  data<-data.frame(cbind (unlist(N), unlist(y), unlist(z), unlist(e),unlist(Site),gender,age.0,smoking,home,unlist(Country.ID),Treatment.Group,eligible.flag))
  names(data)<-c("N.Site","Enrollment Date","Formatted Enrollment Date", "Randomization Dates", "Site.ID","Gender","Age","Smoking","Home","Country","Treatment.Group","Eligible.flag")
  data$N.Site<-as.numeric(as.character(data$N.Site))



  #### Use the function for the eligibility criteria
  data<-non.eligble(data)

  #### Use function for the age
  data<-age(data)



  for (i in 1:dim(data)[1])
    if (data[i,1]==0 & data[i,2]==0) {data[i,12]<-"Yes"}


  ## Recruitment Flag
  # Order the dataset by eligible.flag()
  prefinal_data<-data[order(data[,12]=="No", as.Date(data[,3], format)),]

  for(i in 1:(cohortSize+n)){
    prefinal_data[i,13]<-"Yes"}

  for(i in (cohortSize+n+1):dim(prefinal_data)[1]){
    prefinal_data[i,13]<-"No"}

  names(prefinal_data)[13]<-"Enrolled.flag"




  final_data<-data[order(as.Date(data[,3], format)),]
  final_data<-prefinal_data[1:(cohortSize+n),]
  names(final_data)<-c("N.Site","Enrollment Date","Formatted.Enrollment.Date","Randomization.Dates","Site.ID","Gender","Age","Smoking","Home","Country","Treatment.Group","Eligible.flag","Enrolled.flag")
  final_data[,3] <-as.Date(final_data[,3], format) ## this is required for the ggplot to order the dates in xaxis





  ##Recruitment per site
  plot1<-ggplot(final_data, aes(x=Formatted.Enrollment.Date , y=N.Site, color=Site.ID)) +
    geom_point() + geom_line() + theme(legend.position="none")+
    scale_x_date(breaks = seq(min(final_data[,3]),max(final_data[,3]),by="2 months"),labels = date_format("%d%b%Y"))+
    theme(axis.text.x = element_text(angle = 90, hjust = 1))+
    #facet_wrap(~Country)+
    xlab("Date")+
    ylab("N Site")





  ###Overall Recruitment
  overall<-final_data[-c(which(final_data[,2]==0&final_data[,5]!=final_data[1,5])),]
  N.enrollment<-c(0:(dim(overall)[1]-1))
  overall[,14]<-N.enrollment
  names(overall)[14]<-"N.enrollment"


  overall<-overall[order(as.Date(overall[,4], format)),]
  overall[,4] <-as.Date(overall[,4], format) ## this is required for the ggplot to order the dates in xaxis

  N.randomization<-c(0:(dim(overall)[1]-1))
  overall[,15]<-N.randomization
  names(overall)[15]<-"N.randomization"


  overall<-overall[c(1,2,3,4,5,14,15,6,7,8,9,10,11,12,13)]   #### change the order of the columns


  for(i in 1:n){
    Pts.per.site[i]<-length(which(overall[,5]==i))

  }


  plot2<-ggplot(overall) +

    geom_line(data=overall, aes(y=N.enrollment, x = Formatted.Enrollment.Date, color="Enrollment Date"),size=0.6)+
    geom_point(aes(y=N.enrollment,x = Formatted.Enrollment.Date,color="Enrollment Date"),size=1) +

    geom_line(data=overall, aes(y=N.randomization,x =Randomization.Dates, color="Randomization Date" ),size=0.6)+
    geom_point(aes(y=N.randomization,x =Randomization.Dates,color="Randomization Date"),size=1) +

    scale_x_date(breaks = seq(min(final_data[,3]),max(final_data[,3]),by="2 months"),labels = date_format("%d%b%Y"))+
    theme(axis.text.x = element_text(angle = 90, hjust = 1))+
    xlab("Date")+
    ylab("N")+
    labs(color="Legend text")




  #average.rate<-mean(rate)
  #x<-hpp.sim(average.rate, cohortSize)
  #plot(x,0: cohortSize)
  #plot3<-hpp.plot(average.rate,cohortSize,num.sims = 200)
  #average.years<-mean(years)
  #average.rate<-mean((as.vector(parameters.table[,3]))/average.years)

  #prob.func<-function(t)pmin(1.0,0.0090+0.496*t)
  #plot3<-nhpp.plot(12000,cohortSize,prob.func,num.sims = 200,t1=3)
  #plot3<-nhpp.plot((mean(as.vector(parameters.table[,3]))/average.years)*300,cohortSize,prob.func,num.sims = 200,t1=3)

  ## auto mallon prepei na xrhsimopoihsw
 # prob.func<-function(t)pmin(1.0,0.15+0.425*t)
  #prob.func<-function(t)pmin(1.0, 0.0001+0.5*t)
  #plot3<-nhpp.plot((12000/mean(years)),cohortSize,prob.func,num.sims = 200,t1=3)



  return(list(plot1,plot2,mean(Pts.per.site)))





}


  Dataset<-General ( n,
                     target,
                     rate,
                     origin,
                     format,
                     c,
                     cohortSize,
                     to,
                     Treatment.Group,
                     gender,
                     age,
                     smoking,
                     home,
                     country
                   )




  ## Recruitment per site
  Dataset[1]


  ## Overall recruitment
  Dataset[2]


  ## Average number of patients recruited per site
  Dataset[3]


