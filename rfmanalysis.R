install.packages("ggplot2")
library(ggplot2)

#Use Case - Online Retail dataset
#Understanding Purchase behaviour
#Reading the dataset
#Chnange the format of Invoice date

Online_Retail_Dataset = read.csv("D:\\RecogX_Backup\\Deepak\\IIM\\Dataset\\Online Retail.csv")

#Dimension of dataset

dim(Online_Retail_Dataset)

#Number of Rows = 541909
#Number of columns = 8

#Check top 6 rows of dataset
head(Online_Retail_Dataset)




#Summarise the dataset volumns
str(Online_Retail_Dataset)

#To check if there is repeated customers
length(unique(Online_Retail_Dataset$CustomerID))

#Calculating number of rows having customer id missing
sum(is.na(Online_Retail_Dataset$CustomerID))

#Extracting only those rows where we have Customer ID
clean_retail_dataset <- subset(Online_Retail_Dataset, !is.na(Online_Retail_Dataset$CustomerID))

dim(clean_retail_dataset)

#Checking the frequency distribution of data country-wise
table(clean_retail_dataset$Country)

#Extracting only United Kingdom data from dataset
UK_data <- subset(clean_retail_dataset, Country == "United Kingdom")

dim(UK_data)

#Now we will start working on UK customers only

#Check number of unique invoices/transaction and unique customers

length(unique(UK_data$InvoiceNo))
length(unique(UK_data$CustomerID))



?grepl
# Identify returns
# grepl returns TRUE if a string contains the pattern, otherwise FALSE;
#A cancel invoice has invoice number like C547104
#Fixed = TRUE means check as it is 
UK_data$Return_Item <- grepl("C", UK_data$InvoiceNo, fixed=TRUE)

head(UK_data$Return_Item)

#We have added one more column in UK_data dataset for cancel invoice using $ sign

# 0 for Return or cancelation of invoice
#1 for purchase

UK_data$purchased_item <- ifelse(UK_data$Return_Item=="TRUE", 0, 1)

#If Return_Item value is TRUE assign 0 else assign 1

head(UK_data$purchased_item)

#Now starts the understanding of customer buying behaviour. 
#Lets study  Recency, Frequency and Monetory parameter

# Recency refers to the number of days that have elapsed 
# since the customer last purchased something. or when the customer visited the 
#store and made transaction. 

#Frequency refers to the number of invoices with purchases during the year for 
#each customer

# Monetary value is the amount that the customer spent during the year. 

#Creating customer dataset

List_of_customers <- as.data.frame(unique(UK_data$CustomerID))
names(List_of_customers)

#Changing the column name to customerid
names(List_of_customers) <- "CustomerID"

names(List_of_customers)

#Converting datet time to date only. 
as.Date(UK_data$InvoiceDate)


#Recency

head(UK_data$InvoiceDate)

UK_data$recency <- as.Date("2011-12-10") - as.Date(UK_data$InvoiceDate)

head(UK_data$recency)

# remove returns and select only purchased items 
purchased <- subset(UK_data, purchased_item == 1)

head(purchased)

# Obtain number of days since most recent purchase
# geting customerid group by recency 
recency <- aggregate(recency ~ CustomerID, data=purchased, FUN=min, na.rm=TRUE)
#This means group recency by customerid. Min will let us know when last the customer visited the store


?aggregate

head(recency)
#Customer 12346 visited almost a year back and 12748 just visit the store
#The prupose of purchase is over, lets remove it
remove(purchased)

# merge or joining the recency data with main  customer data list

List_of_customers <- merge(List_of_customers, recency, by="CustomerID", all=TRUE, sort=TRUE)

head(List_of_customers)
#Now no need of recency so remove it. Customer dataset already have this information
remove(recency)

class(List_of_customers$recency)
#Converting to numeric data type
List_of_customers$recency <- as.numeric(List_of_customers$recency)

head(List_of_customers)

###Recency part over
########################################################################################
#Frequency Starts

customer.invoices <- subset(UK_data, select = c("CustomerID","InvoiceNo", "purchased_item"))
customer.invoices <- customer.invoices[!duplicated(customer.invoices), ]
customer.invoices <- customer.invoices[order(customer.invoices$CustomerID),]

head(customer.invoices)
#removing  
row.names(customer.invoices) <- NULL



# Number of invoices/year (purchases only) for each customerid
annual.invoices <- aggregate(purchased_item ~ CustomerID, data=customer.invoices, FUN=sum, na.rm=TRUE)
head(annual.invoices)
#Changing the name of purchase_item to frequency
names(annual.invoices)[names(annual.invoices)=="purchased_item"] <- "frequency"

# Add number  of invoices per customer to customers data
List_of_customers <- merge(List_of_customers, annual.invoices, by="CustomerID", all=TRUE, sort=TRUE)
#removing temporary dataset
remove(customer.invoices, annual.invoices)

range(List_of_customers$frequency)
table(List_of_customers$frequency)

# Remove customers who have not made any purchases in the past year, so removing 29 records
List_of_customers <- subset(List_of_customers, frequency > 0)

head(List_of_customers)


####################Frequency ends here

###############################
# Monetary Value of Customers #
###############################

# Total spent on each item and adding column Amount
UK_data$Amount <- UK_data$Quantity * UK_data$UnitPrice

# Aggregated total sales to customer
annual.sales <- aggregate(Amount ~ CustomerID, data=UK_data, FUN=sum, na.rm=TRUE)
#Changing name to monetory
names(annual.sales)[names(annual.sales)=="Amount"] <- "monetary"

# Add monetary value to customers dataset
List_of_customers <- merge(List_of_customers, annual.sales, by="CustomerID", all.x=TRUE, sort=TRUE)
head(List_of_customers)
remove(annual.sales)

# Identify customers with negative monetary value numbers. These are the customer who presumably returning purchases from the preceding year
hist(List_of_customers$monetary)
List_of_customers$monetary <- ifelse(List_of_customers$monetary < 0, 0, List_of_customers$monetary) # reset negative numbers to zero
hist(List_of_customers$monetary)


#Preprocess Data

# Log-transform positively-skewed variables
List_of_customers$recency.log <- log(List_of_customers$recency)
List_of_customers$frequency.log <- log(List_of_customers$frequency)
List_of_customers$monetary.log <- List_of_customers$monetary + 0.1 # can't take log(0), so add a small value to remove zeros
List_of_customers$monetary.log <- log(List_of_customers$monetary.log)

# Z-scores
List_of_customers$recency.z <- scale(List_of_customers$recency.log, center=TRUE, scale=TRUE)
List_of_customers$frequency.z <- scale(List_of_customers$frequency.log, center=TRUE, scale=TRUE)
List_of_customers$monetary.z <- scale(List_of_customers$monetary.log, center=TRUE, scale=TRUE)


