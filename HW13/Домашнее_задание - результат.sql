/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "18 - Хранимые процедуры, функции, триггеры, курсоры".

Задания выполняются с использованием базы данных WideWorldImporters.

Бэкап БД можно скачать отсюда:
https://github.com/Microsoft/sql-server-samples/releases/tag/wide-world-importers-v1.0
Нужен WideWorldImporters-Full.bak

Описание WideWorldImporters от Microsoft:
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-what-is
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-oltp-database-catalog
*/

USE WideWorldImporters

/*
Во всех заданиях написать хранимую процедуру / функцию и продемонстрировать ее использование.
*/

/*
1) Написать функцию возвращающую Клиента с наибольшей суммой покупки.
*/

IF OBJECT_ID (N'dbo.fGetClientWithMaxSum', N'FN') IS NOT NULL
DROP FUNCTION dbo.fGetClientWithMaxSum;
GO
CREATE FUNCTION dbo.fGetClientWithMaxSum()
RETURNS nvarchar(100)
AS
BEGIN
    DECLARE @Result nvarchar(100);
    SELECT @Result = 
    (select top 1 cus.CustomerName 
	from Sales.InvoiceLines as invlines
		inner join Sales.Invoices as inv on invlines.InvoiceID = inv.InvoiceID
		inner join Sales.Customers as cus on inv.CustomerID = cus.CustomerID
	group by inv.InvoiceID, cus.CustomerName
	order by sum(invlines.Quantity*UnitPrice) desc)

    RETURN @Result;
END;
--===============
SELECT dbo.fGetClientWithMaxSum() AS Client;
--===============

/*
2) Написать хранимую процедуру с входящим параметром СustomerID, выводящую сумму покупки по этому клиенту.
Использовать таблицы :
Sales.Customers
Sales.Invoices
Sales.InvoiceLines
*/

USE WideWorldImporters;
IF OBJECT_ID(N'[Application].uspGetSumByClient', N'P') IS NOT NULL
DROP PROCEDURE [Application].uspGetSumByClient;
GO
CREATE PROCEDURE [Application].uspGetSumByClient(@CustomerID int)
AS
    SET NOCOUNT ON;

select cus.CustomerName [Клиент], inv.InvoiceID, sum(invlines.Quantity*UnitPrice) [Сумма покупки] 
	from Sales.InvoiceLines as invlines
		inner join Sales.Invoices as inv on invlines.InvoiceID = inv.InvoiceID
		inner join Sales.Customers as cus on inv.CustomerID = cus.CustomerID
	where cus.CustomerID = @CustomerID
	group by inv.InvoiceID, cus.CustomerName;

--===============
DECLARE @CustomerID int = 834;
EXEC [Application].uspGetSumByClient @CustomerID;
--===============

/*
3) Создать одинаковую функцию и хранимую процедуру, посмотреть в чем разница в производительности и почему.
*/

USE WideWorldImporters;
IF OBJECT_ID (N'dbo.f1', N'IF') IS NOT NULL
    DROP FUNCTION dbo.f1;
GO
IF OBJECT_ID(N'[Application].p1', N'P') IS NOT NULL
	DROP PROCEDURE [Application].p1;
GO

CREATE FUNCTION dbo.f1(
    @CustomerID NVARCHAR(50))
RETURNS TABLE
AS
RETURN
(
    SELECT c.CustomerName, c.PhoneNumber
	FROM Sales.[Customers] c
	where c.CustomerID = @CustomerID
);

CREATE PROCEDURE [Application].p1(@CustomerID int)
AS
    SELECT c.CustomerName, c.PhoneNumber
	FROM Sales.[Customers] c
	where c.CustomerID = @CustomerID;

--===============
declare @cus int = 834;
select * from dbo.f1(@cus)
exec [Application].p1 @cus
/*
Нет разницы в производительности, планы запросов идентичны
*/
--===============

/*
4) Создайте табличную функцию покажите как ее можно вызвать для каждой строки result set'а без использования цикла. 
*/

-- Определим штат для всех городов миллионников

IF OBJECT_ID (N'dbo.getStateByID', N'IF') IS NOT NULL
    DROP FUNCTION dbo.getStateByID;
GO

CREATE FUNCTION dbo.getStateByID(
    @StateProvinceID int)
RETURNS TABLE
AS
RETURN
(
	SELECT StateProvinceName
	FROM [WideWorldImporters].[Application].StateProvinces 
	where StateProvinceID = @StateProvinceID
);

declare @LatestRecordedPopulation bigint = 1000000
select c.CityName, s.StateProvinceName from Application.Cities c 
  cross apply dbo.getStateByID(c.StateProvinceID) s
where c.LatestRecordedPopulation > @LatestRecordedPopulation 
