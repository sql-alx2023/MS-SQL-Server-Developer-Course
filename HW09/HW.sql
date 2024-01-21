/****** Скрипт для команды SelectTopNRows из среды SSMS  ******/
SELECT TOP (1000) *  FROM [WideWorldImporters].[Sales].[Customers]

--1/ 
  insert into Sales.Customers(CustomerID,[CustomerName],[BillToCustomerID],[CustomerCategoryID],[BuyingGroupID],[PrimaryContactPersonID],[AlternateContactPersonID]
      ,[DeliveryMethodID],[DeliveryCityID],[PostalCityID],[CreditLimit],[AccountOpenedDate],[StandardDiscountPercentage],[IsStatementSent],[IsOnCreditHold]
      ,[PaymentDays],[PhoneNumber],[FaxNumber],[DeliveryRun],[RunPosition],[WebsiteURL],[DeliveryAddressLine1],[DeliveryAddressLine2],[DeliveryPostalCode],[DeliveryLocation]
      ,[PostalAddressLine1],[PostalAddressLine2],[PostalPostalCode],[LastEditedBy]) 
	  values
	  (1062, N'XXX1062',  1062,  5,  null,  3261,  null,  3,   19881,  19881,  1600,  '2016-05-07',  0,  0,  0,  7,  '(206) 555-0100',  '(206) 555-0101',
  null,   null,   '',   'Shop 12',   '652 Victoria Lane',   '90243',   null,   'PO Box 8112',   'Milicaville',   '90243',   1),
	  (1063, N'XXX1063',  1063,  5,  null,  3261,  null,  3,   19881,  19881,  1600,  '2016-05-07',  0,  0,  0,  7,  '(206) 555-0100',  '(206) 555-0101',
  null,   null,   '',   'Shop 12',   '652 Victoria Lane',   '90243',   null,   'PO Box 8112',   'Milicaville',   '90243',   1),
	  (1064, N'XXX1064',  1064,  5,  null,  3261,  null,  3,   19881,  19881,  1600,  '2016-05-07',  0,  0,  0,  7,  '(206) 555-0100',  '(206) 555-0101',
  null,   null,   '',   'Shop 12',   '652 Victoria Lane',   '90243',   null,   'PO Box 8112',   'Milicaville',   '90243',   1),
	  (1065, N'XXX1065',  1065,  5,  null,  3261,  null,  3,   19881,  19881,  1600,  '2016-05-07',  0,  0,  0,  7,  '(206) 555-0100',  '(206) 555-0101',
  null,   null,   '',   'Shop 12',   '652 Victoria Lane',   '90243',   null,   'PO Box 8112',   'Milicaville',   '90243',   1),
	  (1066, N'XXX1066',  1066,  5,  null,  3261,  null,  3,   19881,  19881,  1600,  '2016-05-07',  0,  0,  0,  7,  '(206) 555-0100',  '(206) 555-0101',
  null,   null,   '',   'Shop 12',   '652 Victoria Lane',   '90243',   null,   'PO Box 8112',   'Milicaville',   '90243',   1)

--2/ 
delete from Sales.Customers where CustomerID = 1062

--3/ 
update Sales.Customers set CustomerName = 'XXX1067' where CustomerID = 1066

--4/ 
  drop table IF EXISTS sales.Customers_copy;

  select * into sales.Customers_copy from Sales.Customers where 1=2

  insert into Sales.Customers_copy(CustomerID,[CustomerName],[BillToCustomerID],[CustomerCategoryID],[BuyingGroupID],[PrimaryContactPersonID],[AlternateContactPersonID]
      ,[DeliveryMethodID],[DeliveryCityID],[PostalCityID],[CreditLimit],[AccountOpenedDate],[StandardDiscountPercentage],[IsStatementSent],[IsOnCreditHold]
      ,[PaymentDays],[PhoneNumber],[FaxNumber],[DeliveryRun],[RunPosition],[WebsiteURL],[DeliveryAddressLine1],[DeliveryAddressLine2],[DeliveryPostalCode],[DeliveryLocation]
      ,[PostalAddressLine1],[PostalAddressLine2],[PostalPostalCode],[LastEditedBy], ValidFrom, ValidTo) 
	  values
	  (1062, N'XXX1062',  1062,  5,  null,  3261,  null,  3,   19881,  19881,  1600,  '2016-05-07',  0,  0,  0,  7,  '(206) 555-0100',  '(206) 555-0101',
  null,   null,   '',   'Shop 12',   '652 Victoria Lane',   '90243',   null,   'PO Box 8112',   'Milicaville',   '90243',   1, GETDATE(), GETDATE()),
	  (1063, N'XXX1063',  1063,  5,  null,  3261,  null,  3,   19881,  19881,  1600,  '2016-05-07',  0,  0,  0,  7,  '(206) 555-0100',  '(206) 555-0101',
  null,   null,   '',   'Shop 12',   '652 Victoria Lane',   '90243',   null,   'PO Box 8112',   'Milicaville',   '90243',   1, GETDATE(), GETDATE()),
	  (1064, N'XXX1064',  1064,  5,  null,  3261,  null,  3,   19881,  19881,  1600,  '2016-05-07',  0,  0,  0,  7,  '(206) 555-0100',  '(206) 555-0101',
  null,   null,   '',   'Shop 12',   '652 Victoria Lane',   '90243',   null,   'PO Box 8112',   'Milicaville',   '90243',   1, GETDATE(), GETDATE()),
	  (1065, N'XXX1065',  1065,  5,  null,  3261,  null,  3,   19881,  19881,  1600,  '2016-05-07',  0,  0,  0,  7,  '(206) 555-0100',  '(206) 555-0101',
  null,   null,   '',   'Shop 12',   '652 Victoria Lane',   '90243',   null,   'PO Box 8112',   'Milicaville',   '90243',   1, GETDATE(), GETDATE()),
	  (1066, N'XXX1066',  1066,  5,  null,  3261,  null,  3,   19881,  19881,  1600,  '2016-05-07',  0,  0,  0,  7,  '(206) 555-0100',  '(206) 555-0101',
  null,   null,   '',   'Shop 12',   '652 Victoria Lane',   '90243',   null,   'PO Box 8112',   'Milicaville',   '90243',   1, GETDATE(), GETDATE())

  select * from Sales.Customers where CustomerID > 1061
  select * from Sales.Customers_copy

  merge into Sales.Customers as TTarget
  using Sales.Customers_copy as TSource
  on TTarget.CustomerID = TSource.CustomerID
  when matched and TTarget.CustomerName <> TSource.CustomerName
	then update set TTarget.CustomerName = TSource.CustomerName
  when not matched by target
	then insert (CustomerID,[CustomerName],[BillToCustomerID],[CustomerCategoryID],[BuyingGroupID],[PrimaryContactPersonID],[AlternateContactPersonID]
      ,[DeliveryMethodID],[DeliveryCityID],[PostalCityID],[CreditLimit],[AccountOpenedDate],[StandardDiscountPercentage],[IsStatementSent],[IsOnCreditHold]
      ,[PaymentDays],[PhoneNumber],[FaxNumber],[DeliveryRun],[RunPosition],[WebsiteURL],[DeliveryAddressLine1],[DeliveryAddressLine2],[DeliveryPostalCode],[DeliveryLocation]
      ,[PostalAddressLine1],[PostalAddressLine2],[PostalPostalCode],[LastEditedBy])
	  values
	  (TSource.CustomerID,TSource.[CustomerName],TSource.[BillToCustomerID],TSource.[CustomerCategoryID],TSource.[BuyingGroupID],TSource.[PrimaryContactPersonID],TSource.[AlternateContactPersonID]
      ,TSource.[DeliveryMethodID],TSource.[DeliveryCityID],TSource.[PostalCityID],TSource.[CreditLimit],TSource.[AccountOpenedDate],TSource.[StandardDiscountPercentage],TSource.[IsStatementSent],TSource.[IsOnCreditHold]
      ,TSource.[PaymentDays],TSource.[PhoneNumber],TSource.[FaxNumber],TSource.[DeliveryRun],TSource.[RunPosition],TSource.[WebsiteURL],TSource.[DeliveryAddressLine1],TSource.[DeliveryAddressLine2],TSource.[DeliveryPostalCode],TSource.[DeliveryLocation]
      ,TSource.[PostalAddressLine1],TSource.[PostalAddressLine2],TSource.[PostalPostalCode],TSource.[LastEditedBy]);

--5/ 
E:\BCP>bcp WideWorldImporters.Sales.Customers out e:\BCP\Customers.csv -c -T -S COMPUTER\SQL2022

select * into sales.Customers_from_file from Sales.Customers where 1=2
BULK INSERT sales.Customers_from_file
FROM 'e:\BCP\Customers.csv'

select * from sales.Customers_from_file