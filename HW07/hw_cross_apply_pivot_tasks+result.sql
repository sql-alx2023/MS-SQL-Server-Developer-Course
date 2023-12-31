/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "05 - Операторы CROSS APPLY, PIVOT, UNPIVOT".

Задания выполняются с использованием базы данных WideWorldImporters.

Бэкап БД можно скачать отсюда:
https://github.com/Microsoft/sql-server-samples/releases/tag/wide-world-importers-v1.0
Нужен WideWorldImporters-Full.bak

Описание WideWorldImporters от Microsoft:
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-what-is
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-oltp-database-catalog
*/

-- ---------------------------------------------------------------------------
-- Задание - написать выборки для получения указанных ниже данных.
-- ---------------------------------------------------------------------------

USE WideWorldImporters

/*
1. Требуется написать запрос, который в результате своего выполнения 
формирует сводку по количеству покупок в разрезе клиентов и месяцев.
В строках должны быть месяцы (дата начала месяца), в столбцах - клиенты.

Клиентов взять с ID 2-6, это все подразделение Tailspin Toys.
Имя клиента нужно поменять так чтобы осталось только уточнение.
Например, исходное значение "Tailspin Toys (Gasport, NY)" - вы выводите только "Gasport, NY".
Дата должна иметь формат dd.mm.yyyy, например, 25.12.2019.

Пример, как должны выглядеть результаты:
-------------+--------------------+--------------------+-------------+--------------+------------
InvoiceMonth | Peeples Valley, AZ | Medicine Lodge, KS | Gasport, NY | Sylvanite, MT | Jessie, ND
-------------+--------------------+--------------------+-------------+--------------+------------
01.01.2013   |      3             |        1           |      4      |      2        |     2
01.02.2013   |      7             |        3           |      4      |      2        |     1
-------------+--------------------+--------------------+-------------+--------------+------------
*/
use WideWorldImporters
-- В таблице Orders нет клиентов с ContactPersonID от 2 до 6. минимальный ID 1001
-- Буду делать для ID от 1002 до 1006
	
with datatable as
(
select distinct
count(orderID) over (partition by ContactPersonID, month(orderdate), year(orderdate)) as Number,
--DATEFROMPARTS(YEAR(orderdate),MONTH(orderdate),1) as beginMonth, 
DATETRUNC(month, orderdate) as beginMonth,
substring(cus.CustomerName, CHARINDEX('(', cus.CustomerName)+1, len(cus.CustomerName)-CHARINDEX('(', CustomerName)-1) as FullName
from sales.Orders as ord
inner join Sales.Customers cus
on ord.CustomerID = cus.CustomerID
where cus.CustomerID between 2 and 6
)

select convert(varchar, beginMonth, 104) as 'InvoiceMonth', [Peeples Valley, AZ], [Medicine Lodge, KS], [Gasport, NY], [Sylvanite, MT], [Jessie, ND]
from  datatable
PIVOT (sum(Number)
		for FullName in ([Peeples Valley, AZ], [Medicine Lodge, KS], [Gasport, NY], [Sylvanite, MT], [Jessie, ND])
) as pivottable

/*
2. Для всех клиентов с именем, в котором есть "Tailspin Toys"
вывести все адреса, которые есть в таблице, в одной колонке.

Пример результата:
----------------------------+--------------------
CustomerName                | AddressLine
----------------------------+--------------------
Tailspin Toys (Head Office) | Shop 38
Tailspin Toys (Head Office) | 1877 Mittal Road
Tailspin Toys (Head Office) | PO Box 8975
Tailspin Toys (Head Office) | Ribeiroville
----------------------------+--------------------
*/
select CustomerName, AddressVariant
from (
	select 
		CustomerName, 
		DeliveryAddressLine1, 
		DeliveryAddressLine2, 
		PostalAddressLine1, 
		PostalAddressLine2 
		from Sales.Customers 
		where CustomerName like '%Tailspin Toys%'
		) as adrs
unpivot (AddressVariant for AddressType in (DeliveryAddressLine1, DeliveryAddressLine2, PostalAddressLine1, PostalAddressLine2)) as unp


/*
3. В таблице стран (Application.Countries) есть поля с цифровым кодом страны и с буквенным.
Сделайте выборку ИД страны, названия и ее кода так, 
чтобы в поле с кодом был либо цифровой либо буквенный код.

Пример результата:
--------------------------------
CountryId | CountryName | Code
----------+-------------+-------
1         | Afghanistan | AFG
1         | Afghanistan | 4
3         | Albania     | ALB
3         | Albania     | 8
----------+-------------+-------
*/

select CountryID, CountryName, Code 
from 
(
	select 
		cast(CountryID as varchar(3)) as CountryID, 
		CountryName, 
		cast(IsoAlpha3Code as varchar(3)) IsoAlpha3Code, 
		cast(IsoNumericCode as varchar(3)) as IsoNumericCode 
	from Application.Countries
) as country
unpivot (Code for CountryData in (IsoAlpha3Code, IsoNumericCode)) as unp


/*
4. Выберите по каждому клиенту два самых дорогих товара, которые он покупал.
В результатах должно быть ид клиета, его название, ид товара, цена, дата покупки.
*/

with t2 as
(
	select CustomerID, CustomerName, StockItemID, UnitPrice, OrderDate,
	ROW_NUMBER() over (partition by t1.CustomerID order by t1.UnitPrice desc) as number1
	from(
		select cus.CustomerID, cus.CustomerName, ordl.StockItemID, ordl.UnitPrice, max(ord.OrderDate) as OrderDate
		from Sales.OrderLines ordl
		inner join Sales.Orders ord
		on ordl.OrderID = ord.OrderID
		inner join Sales.Customers cus
		on ord.CustomerID = cus.CustomerID
		group by cus.CustomerID, cus.CustomerName, ordl.StockItemID, ordl.UnitPrice
		) t1
)
select CustomerID, CustomerName, StockItemID, UnitPrice, OrderDate from t2 where number1 < 3
order by t2.CustomerName
