/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "03 - Подзапросы, CTE, временные таблицы".

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
-- Для всех заданий, где возможно, сделайте два варианта запросов:
--  1) через вложенный запрос
--  2) через WITH (для производных таблиц)
-- ---------------------------------------------------------------------------

USE WideWorldImporters

/*
1. Выберите сотрудников (Application.People), которые являются продажниками (IsSalesPerson), 
и не сделали ни одной продажи 04 июля 2015 года. 
Вывести ИД сотрудника и его полное имя. 
Продажи смотреть в таблице Sales.Invoices.
*/

TODO: 

select PersonID, FullName
from [Application].[People] where IsSalesperson = 1
EXCEPT 
select peo.PersonID, peo.FullName 
from [Sales].[Invoices] inv inner join [Application].[People] peo 
on inv.SalespersonPersonID = peo.PersonID
where inv.InvoiceDate = '2015-07-04' and peo.IsSalesperson = 1
group by peo.PersonID, peo.FullName

/*
2. Выберите товары с минимальной ценой (подзапросом). Сделайте два варианта подзапроса. 
Вывести: ИД товара, наименование товара, цена.
*/

TODO:

select StockItemID, StockItemName, UnitPrice from [Warehouse].[StockItems] 
where UnitPrice = (select min(UnitPrice) from [Warehouse].[StockItems])

select sti.StockItemID, sti.StockItemName, sti.UnitPrice from [Warehouse].[StockItems] sti
inner join (select top 1 UnitPrice  from [Warehouse].[StockItems] order by UnitPrice) t1
on sti.UnitPrice = t1.UnitPrice

/*
3. Выберите информацию по клиентам, которые перевели компании пять максимальных платежей 
из Sales.CustomerTransactions. 
Представьте несколько способов (в том числе с CTE). 
*/

TODO: 
select * from [Sales].[Customers] 
where CustomerID in (select top 5 CustomerID from [Sales].[CustomerTransactions] order by AmountExcludingTax desc)

with t1 as (select top 5 CustomerID from [Sales].[CustomerTransactions] order by AmountExcludingTax desc)
select c.* from [Sales].[Customers] c inner join t1 
on c.CustomerID = t1.CustomerID

/*
4. Выберите города (ид и название), в которые были доставлены товары, 
входящие в тройку самых дорогих товаров, а также имя сотрудника, 
который осуществлял упаковку заказов (PackedByPersonID).
*/

TODO: 

with t1 as (select CustomerID, PickedByPersonID, OrderID from [Sales].[Orders]
where OrderID in (select top 3 OrderID from [Sales].[OrderLines] order by UnitPrice desc))

select CityID, CityName, PreferredName
from 
	(select CityID, CityName, OrderID from [Application].[Cities] cit
	inner join 
		(select DeliveryCityID, t1.OrderID from [Sales].[Customers] c
		inner join t1 on c.CustomerID = t1.CustomerID) cus
	on cit.CityID = cus.DeliveryCityID) city
inner join 
	(select PreferredName, t1.OrderID from [Application].[People] p
	inner join t1 on p.PersonID = t1.PickedByPersonID) people
on city.OrderID = people.OrderID


-- ---------------------------------------------------------------------------
-- Опциональное задание
-- ---------------------------------------------------------------------------
-- Можно двигаться как в сторону улучшения читабельности запроса, 
-- так и в сторону упрощения плана\ускорения. 
-- Сравнить производительность запросов можно через SET STATISTICS IO, TIME ON. 
-- Если знакомы с планами запросов, то используйте их (тогда к решению также приложите планы). 
-- Напишите ваши рассуждения по поводу оптимизации. 

-- 5. Объясните, что делает и оптимизируйте запрос

SELECT 
	Invoices.InvoiceID, 
	Invoices.InvoiceDate,
	(SELECT People.FullName
		FROM Application.People
		WHERE People.PersonID = Invoices.SalespersonPersonID
	) AS SalesPersonName,
	SalesTotals.TotalSumm AS TotalSummByInvoice, 
	(SELECT SUM(OrderLines.PickedQuantity*OrderLines.UnitPrice)
		FROM Sales.OrderLines
		WHERE OrderLines.OrderId = (SELECT Orders.OrderId 
			FROM Sales.Orders
			WHERE Orders.PickingCompletedWhen IS NOT NULL	
				AND Orders.OrderId = Invoices.OrderId)	
	) AS TotalSummForPickedItems
FROM Sales.Invoices 
	JOIN
	(SELECT InvoiceId, SUM(Quantity*UnitPrice) AS TotalSumm
	FROM Sales.InvoiceLines
	GROUP BY InvoiceId
	HAVING SUM(Quantity*UnitPrice) > 27000) AS SalesTotals
		ON Invoices.InvoiceID = SalesTotals.InvoiceID
ORDER BY TotalSumm DESC

-- --

TODO: 
Выбирает ID, дату счета, продавца, общую сумму счета, общую сумму собранного заказа
для счетов, у которых общая сумма более 27000.
Результат сортирует по убыванию общей суммы счета.
Не понимаю, как можно оптимизировать.

