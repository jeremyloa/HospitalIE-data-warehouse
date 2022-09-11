-- DIMENSION

-- MedicineDimension
SELECT MedicineID, MedicineName, MedicineSellingPrice, MedicineBuyingPrice, MedicineExpiredDate
FROM OLTP_HospitalIE..MsMedicine

SELECT * FROM MedicineDimension

-- DoctorDimension
SELECT DoctorID, DoctorName, DoctorDOB, DoctorAddress, DoctorSalary
FROM OLTP_HospitalIE..MsDoctor

SELECT * FROM DoctorDimension

-- StaffDimension
SELECT StaffID, StaffName, StaffDOB, StaffAddress, StaffSalary
FROM OLTP_HospitalIE..MsStaff

SELECT * FROM StaffDimension

-- CustomerDimension
SELECT CustomerID, CustomerName, CustomerGender, CustomerAddress
FROM OLTP_HospitalIE..MsCustomer

SELECT * FROM CustomerDimension

-- BenefitDimension
SELECT BenefitID, BenefitName, BenefitPrice
FROM OLTP_HospitalIE..MsBenefit

SELECT * FROM BenefitDimension

-- TreatmentDimension
SELECT TreatmentID, TreatmentName, TreatmentPrice
FROM OLTP_HospitalIE..MsTreatment

SELECT * FROM TreatmentDimension

-- DistributorDimension
SELECT DistributorID, DistributorName, DistributorAddress, DistributorPhone
FROM OLTP_HospitalIE..MsDistributor

SELECT * FROM DistributorDimension

-- TimeDimension
IF EXISTS (
	SELECT * 
	FROM OLAP_HospitalIE..FilterTimestamp
	WHERE TableName = 'TimeDimension'
)
BEGIN 
	SELECT
		[Date] = d.Date,
		[Day] = DAY(d.Date),
		[Month] = MONTH(d.Date),
		[Quarter] = DATEPART(QUARTER, d.Date),
		[Year] = YEAR(d.Date)
	FROM (
		SELECT PurchaseDate AS [Date]
		FROM OLTP_HospitalIE..TrPurchaseHeader
		union
		SELECT SalesDate AS [Date]
		FROM OLTP_HospitalIE..TrSalesHeader
		union
		SELECT ServiceDate AS [Date]
		FROM OLTP_HospitalIE..TrServiceHeader
		union
		SELECT SubscriptionStartDate AS [Date]
		FROM OLTP_HospitalIE..TrSubscriptionHeader
	) AS d
	WHERE [Date] > (
		SELECT LastETL
		FROM OLAP_HospitalIE..FilterTimestamp
		WHERE TableName = 'TimeDimension'
	)
END
ELSE
BEGIN 
	SELECT
		[Date] = d.Date,
		[Day] = DAY(d.Date),
		[Month] = MONTH(d.Date),
		[Quarter] = DATEPART(QUARTER, d.Date),
		[Year] = YEAR(d.Date)
	FROM (
		SELECT PurchaseDate AS [Date]
		FROM OLTP_HospitalIE..TrPurchaseHeader
		union
		SELECT SalesDate AS [Date]
		FROM OLTP_HospitalIE..TrSalesHeader
		union
		SELECT ServiceDate AS [Date]
		FROM OLTP_HospitalIE..TrServiceHeader
		union
		SELECT SubscriptionStartDate AS [Date]
		FROM OLTP_HospitalIE..TrSubscriptionHeader
	) AS d
END

IF EXISTS (
	SELECT *
	FROM FilterTimeStamp
	WHERE TableName = 'TimeDimension'
)
BEGIN
	UPDATE FilterTimeStamp
	SET LastETL = GETDATE()
	WHERE TableName = 'TimeDimension'
END
ELSE
BEGIN
	INSERT INTO FilterTimeStamp 
	VALUES('TimeDimension', GETDATE())
END

SELECT * FROM TimeDimension

SELECT * FROM FilterTimeStamp

-- FACT

-- SalesFact
IF EXISTS (
	SELECT * FROM FilterTimestamp
	WHERE TableName = 'SalesFact'
)
BEGIN
SELECT MedicineCode, StaffCode, CustomerCode, TimeCode,
[TotalSalesEarning] = SUM(SD.Quantity * MM.MedicineSellingPrice),
[TotalMedicineSold] = SUM(SD.Quantity)
FROM OLTP_HospitalIE..TrSalesHeader SH
JOIN OLTP_HospitalIE..TrSalesDetail SD ON SH.SalesID = SD.SalesID
JOIN OLTP_HospitalIE..MsMedicine MM ON MM.MedicineID = SD.MedicineID
JOIN MedicineDimension mdim ON mdim.MedicineID = MM.MedicineID
JOIN StaffDimension sdim ON sdim.StaffID = SH.StaffID
JOIN CustomerDimension cdim ON cdim.CustomerID = SH.CustomerID 
JOIN TimeDimension tdim ON tdim.Date = SH.SalesDate
WHERE SH.SalesDate > (
	SELECT LastETL FROM FilterTimestamp
	WHERE TableName = 'SalesFact'
)
GROUP BY MedicineCode, StaffCode, CustomerCode, TimeCode
END
ELSE
BEGIN
SELECT MedicineCode, StaffCode, CustomerCode, TimeCode,
[TotalSalesEarning] = SUM(SD.Quantity * MM.MedicineSellingPrice),
[TotalMedicineSold] = SUM(SD.Quantity)
FROM OLTP_HospitalIE..TrSalesHeader SH
JOIN OLTP_HospitalIE..TrSalesDetail SD ON SH.SalesID = SD.SalesID
JOIN OLTP_HospitalIE..MsMedicine MM ON MM.MedicineID = SD.MedicineID
JOIN MedicineDimension mdim ON mdim.MedicineID = MM.MedicineID
JOIN StaffDimension sdim ON sdim.StaffID = SH.StaffID
JOIN CustomerDimension cdim ON cdim.CustomerID = SH.CustomerID 
JOIN TimeDimension tdim ON tdim.Date = SH.SalesDate
GROUP BY MedicineCode, StaffCode, CustomerCode, TimeCode
END

IF EXISTS (
	SELECT *
	FROM FilterTimeStamp
	WHERE TableName = 'SalesFact'
)
BEGIN
	UPDATE FilterTimeStamp
	SET LastETL = GETDATE()
	WHERE TableName = 'SalesFact'
END
ELSE
BEGIN
	INSERT INTO FilterTimeStamp 
	VALUES('SalesFact', GETDATE())
END

SELECT * FROM SalesFact

-- PurchaseFact
IF EXISTS (
	SELECT * FROM FilterTimestamp
	WHERE TableName = 'PurchaseFact'
)
BEGIN
SELECT MedicineCode, StaffCode, DistributorCode, TimeCode,
[TotalPurchaseCost] = SUM(PD.Quantity * MM.MedicineBuyingPrice),
[TotalMedicinePurchased] = SUM(PD.Quantity)
FROM OLTP_HospitalIE..TrPurchaseHeader PH
JOIN OLTP_HospitalIE..TrPurchaseDetail PD ON PH.PurchaseID = PD.PurchaseID
JOIN OLTP_HospitalIE..MsMedicine MM ON MM.MedicineID = PD.MedicineID
JOIN MedicineDimension mdim ON mdim.MedicineID = MM.MedicineID
JOIN StaffDimension sdim ON sdim.StaffID = PH.StaffID
JOIN DistributorDimension ddim ON ddim.DistributorID = PH.DistributorID 
JOIN TimeDimension tdim ON tdim.Date = PH.PurchaseDate
WHERE PH.PurchaseDate > (
	SELECT LastETL FROM FilterTimestamp
	WHERE TableName = 'PurchaseFact'
)
GROUP BY MedicineCode, StaffCode, DistributorCode, TimeCode
END
ELSE
BEGIN
SELECT MedicineCode, StaffCode, DistributorCode, TimeCode,
[TotalPurchaseCost] = SUM(PD.Quantity * MM.MedicineBuyingPrice),
[TotalMedicinePurchased] = SUM(PD.Quantity)
FROM OLTP_HospitalIE..TrPurchaseHeader PH
JOIN OLTP_HospitalIE..TrPurchaseDetail PD ON PH.PurchaseID = PD.PurchaseID
JOIN OLTP_HospitalIE..MsMedicine MM ON MM.MedicineID = PD.MedicineID
JOIN MedicineDimension mdim ON mdim.MedicineID = MM.MedicineID
JOIN StaffDimension sdim ON sdim.StaffID = PH.StaffID
JOIN DistributorDimension ddim ON ddim.DistributorID = PH.DistributorID 
JOIN TimeDimension tdim ON tdim.Date = PH.PurchaseDate
GROUP BY MedicineCode, StaffCode, DistributorCode, TimeCode
END

IF EXISTS (
	SELECT *
	FROM FilterTimeStamp
	WHERE TableName = 'PurchaseFact'
)
BEGIN
	UPDATE FilterTimeStamp
	SET LastETL = GETDATE()
	WHERE TableName = 'PurchaseFact'
END
ELSE
BEGIN
	INSERT INTO FilterTimeStamp 
	VALUES('PurchaseFact', GETDATE())
END

SELECT * FROM PurchaseFact

-- SubscriptionFact
IF EXISTS (
	SELECT * FROM FilterTimestamp
	WHERE TableName = 'SubscriptionFact'
)
BEGIN
SELECT CustomerCode, StaffCode, BenefitCode, TimeCode,
[TotalSubscriptionEarning] = SUM(MB.BenefitPrice),
[TotalSubscriberCount] = SUM(SBH.CustomerID)
FROM OLTP_HospitalIE..TrSubscriptionHeader SBH
JOIN OLTP_HospitalIE..TrSubscriptionDetail SBD ON SBH.SubscriptionID = SBD.SubscriptionID
JOIN OLTP_HospitalIE..MsBenefit MB ON MB.BenefitID = SBD.BenefitID
JOIN BenefitDimension bdim ON bdim.BenefitID = MB.BenefitID
JOIN StaffDimension sdim ON sdim.StaffID = SBH.StaffID
JOIN CustomerDimension cdim ON cdim.CustomerID = SBH.CustomerID
JOIN TimeDimension tdim ON tdim.Date = SBH.SubscriptionStartDate
WHERE SBH.SubscriptionStartDate > (
	SELECT LastETL FROM FilterTimestamp
	WHERE TableName = 'SubscriptionFact'
)
GROUP BY CustomerCode, StaffCode, BenefitCode, TimeCode
END
ELSE
BEGIN
SELECT CustomerCode, StaffCode, BenefitCode, TimeCode,
[TotalSubscriptionEarning] = SUM(MB.BenefitPrice),
[TotalSubscriberCount] = SUM(SBH.CustomerID)
FROM OLTP_HospitalIE..TrSubscriptionHeader SBH
JOIN OLTP_HospitalIE..TrSubscriptionDetail SBD ON SBH.SubscriptionID = SBD.SubscriptionID
JOIN OLTP_HospitalIE..MsBenefit MB ON MB.BenefitID = SBD.BenefitID
JOIN BenefitDimension bdim ON bdim.BenefitID = MB.BenefitID
JOIN StaffDimension sdim ON sdim.StaffID = SBH.StaffID
JOIN CustomerDimension cdim ON cdim.CustomerID = SBH.CustomerID
JOIN TimeDimension tdim ON tdim.Date = SBH.SubscriptionStartDate
GROUP BY CustomerCode, StaffCode, BenefitCode, TimeCode
END

IF EXISTS (
	SELECT *
	FROM FilterTimeStamp
	WHERE TableName = 'SubscriptionFact'
)
BEGIN
	UPDATE FilterTimeStamp
	SET LastETL = GETDATE()
	WHERE TableName = 'SubscriptionFact'
END
ELSE
BEGIN
	INSERT INTO FilterTimeStamp 
	VALUES('SubscriptionFact', GETDATE())
END

SELECT * FROM SubscriptionFact

-- ServiceFact
IF EXISTS (
	SELECT * FROM FilterTimestamp
	WHERE TableName = 'ServiceFact'
)
BEGIN
SELECT CustomerCode, TreatmentCode, DoctorCode, TimeCode,
[TotalServiceEarning] = SUM(SVD.Quantity),
[TotalDoctors] = SUM(MD.DoctorID)
FROM OLTP_HospitalIE..TrServiceHeader SVH
JOIN OLTP_HospitalIE..TrServiceDetail SVD ON SVH.ServiceID = SVD.ServiceID
JOIN OLTP_HospitalIE..MsTreatment MT ON MT.TreatmentID = SVD.TreatmentID
JOIN OLTP_HospitalIE..MsDoctor MD ON MD.DoctorID = SVH.DoctorID
JOIN CustomerDimension cdim ON cdim.CustomerID = SVH.CustomerID
JOIN TreatmentDimension trdim ON trdim.TreatmentID = SVD.TreatmentID
JOIN DoctorDimension ddim ON ddim.DoctorID = SVH.DoctorID
JOIN TimeDimension tdim ON tdim.Date = SVH.ServiceDate
WHERE SVH.ServiceDate > (
	SELECT LastETL FROM FilterTimestamp
	WHERE TableName = 'ServiceFact'
)
GROUP BY CustomerCode, TreatmentCode, DoctorCode, TimeCode
END
ELSE
BEGIN
SELECT CustomerCode, TreatmentCode, DoctorCode, TimeCode,
[TotalServiceEarning] = SUM(SVD.Quantity),
[TotalDoctors] = SUM(MD.DoctorID)
FROM OLTP_HospitalIE..TrServiceHeader SVH
JOIN OLTP_HospitalIE..TrServiceDetail SVD ON SVH.ServiceID = SVD.ServiceID
JOIN OLTP_HospitalIE..MsTreatment MT ON MT.TreatmentID = SVD.TreatmentID
JOIN OLTP_HospitalIE..MsDoctor MD ON MD.DoctorID = SVH.DoctorID
JOIN CustomerDimension cdim ON cdim.CustomerID = SVH.CustomerID
JOIN TreatmentDimension trdim ON trdim.TreatmentID = SVD.TreatmentID
JOIN DoctorDimension ddim ON ddim.DoctorID = SVH.DoctorID
JOIN TimeDimension tdim ON tdim.Date = SVH.ServiceDate
GROUP BY CustomerCode, TreatmentCode, DoctorCode, TimeCode
END

IF EXISTS (
	SELECT *
	FROM FilterTimeStamp
	WHERE TableName = 'ServiceFact'
)
BEGIN
	UPDATE FilterTimeStamp
	SET LastETL = GETDATE()
	WHERE TableName = 'ServiceFact'
END
ELSE
BEGIN
	INSERT INTO FilterTimeStamp 
	VALUES('ServiceFact', GETDATE())
END

SELECT * FROM ServiceFact

select * from FilterTimestamp