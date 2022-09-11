CREATE DATABASE OLAP_HospitalIE
USE OLAP_HospitalIE

CREATE TABLE MedicineDimension(
	MedicineCode INT PRIMARY KEY IDENTITY,
	MedicineID INT NOT NULL,
	MedicineName VARCHAR(100) NOT NULL,
	MedicineSellingPrice BIGINT NOT NULL,
	MedicineBuyingPrice BIGINT NOT NULL,
	MedicineExpiredDate DATE NOT NULL
)

CREATE TABLE DoctorDimension (
	DoctorCode INT PRIMARY KEY IDENTITY,
	DoctorID INT,
	DoctorName VARCHAR(100) ,
	DoctorDOB DATE,
	DoctorAddress VARCHAR(100), 
	DoctorSalary BIGINT,
	ValidFrom DATE,
	ValidTo DATE
)

CREATE TABLE StaffDimension (
	StaffCode INT PRIMARY KEY IDENTITY,
	StaffID INT,
	StaffName VARCHAR(100) ,
	StaffDOB DATE,
	StaffAddress VARCHAR(100), 
	StaffSalary BIGINT,
	ValidFrom DATE,
	ValidTo DATE 
)

CREATE TABLE CustomerDimension (
	CustomerCode INT PRIMARY KEY IDENTITY,
	CustomerID INT,
	CustomerName VARCHAR(100),
	CustomerGender VARCHAR(6), 
	CustomerAddress VARCHAR(100) 
)

CREATE TABLE BenefitDimension (
	BenefitCode INT PRIMARY KEY IDENTITY,
	BenefitID INT,
	BenefitName VARCHAR(100),
	BenefitPrice BIGINT,
	ValidFrom DATE,
	ValidTo DATE 
)

CREATE TABLE TreatmentDimension (
	TreatmentCode INT PRIMARY KEY IDENTITY,
	TreatmentID INT,
	TreatmentName VARCHAR(100),
	TreatmentPrice BIGINT,
	ValidFrom DATE,
	ValidTo DATE 
)

CREATE TABLE DistributorDimension (
	DistributorCode INT PRIMARY KEY IDENTITY,
	DistributorID INT,
	DistributorName VARCHAR(100) ,
	DistributorAddress VARCHAR(100), 
	DistributorPhone VARCHAR(15)
)

CREATE TABLE TimeDimension (
	TimeCode INT PRIMARY KEY IDENTITY,
	[Date] DATE,
	[Day] INT,
	[Month] INT,
	[Quarter] INT,
	[Year] INT
)

CREATE TABLE SalesFact (
	MedicineCode INT,
	StaffCode INT,
	CustomerCode INT,
	TotalSalesEarning BIGINT,
	TotalMedicineSold BIGINT
)

CREATE TABLE PurchaseFact (
	MedicineCode INT,
	StaffCode INT,
	DistributorCode INT,
	TotalPurchaseCost BIGINT
) 

CREATE TABLE SubscriptionFact (
	CustomerCode INT,
	StaffCode INT,
	BenefitCode INT,
	TotalSubscriptionEarning BIGINT,
	TotalSubscriberCount BIGINT
)

CREATE TABLE ServiceFact (
	CustomerCode INT,
	TreatmentCode INT,
	DoctorCode INT,
	TotalServiceEarning BIGINT,
	TotalDoctors BIGINT
)

CREATE TABLE FilterTimestamp (
	TableName VARCHAR(100) PRIMARY KEY,
	LastETL DATETIME
)

