/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "06 - Оконные функции".

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
1. Сделать расчет суммы продаж нарастающим итогом по месяцам с 2015 года 
(в рамках одного месяца он будет одинаковый, нарастать будет в течение времени выборки).
Выведите: id продажи, название клиента, дату продажи, сумму продажи, сумму нарастающим итогом

Пример:
-------------+----------------------------
Дата продажи | Нарастающий итог по месяцу
-------------+----------------------------
 2015-01-29   | 4801725.31
 2015-01-30	 | 4801725.31
 2015-01-31	 | 4801725.31
 2015-02-01	 | 9626342.98
 2015-02-02	 | 9626342.98
 2015-02-03	 | 9626342.98
Продажи можно взять из таблицы Invoices.
Нарастающий итог должен быть без оконной функции.
*/

set statistics time, io on;

with t1 as(
select 
--ID				= inv.InvoiceID,
--Клиент			= peo.FullName,
--ДатаПродажи		= inv.InvoiceDate, 
ГодПродажи		= Year(inv.InvoiceDate),
МесяцПродажи	= Month(inv.InvoiceDate),
Сумма			= sum(invl.Quantity * invl.UnitPrice) 
from WideWorldImporters.Sales.Invoices as inv 
inner join WideWorldImporters.Sales.InvoiceLines as invl 
on inv.InvoiceID = invl.InvoiceID
where inv.InvoiceDate >= '2015-01-01'
group by Year(inv.InvoiceDate), Month(inv.InvoiceDate)
)


select 
ID				= inv.InvoiceID,
Клиент			= peo.FullName,
ДатаПродажи		= inv.InvoiceDate,
СуммаПродажи	= invl.Quantity*invl.UnitPrice,
СуммаЗаМесяц	= t1.Сумма,
НарастающийИтог = (SELECT sum(t2.Сумма) FROM t1 AS t2 WHERE t1.ГодПродажи = t2.ГодПродажи AND t1.МесяцПродажи >= t2.МесяцПродажи)
from WideWorldImporters.Sales.Invoices as inv 
inner join WideWorldImporters.Sales.InvoiceLines as invl 
on inv.InvoiceID = invl.InvoiceID
inner join WideWorldImporters.Application.People as peo
on inv.ContactPersonID = peo.PersonID
inner join t1 as t1
on Year(inv.InvoiceDate) = t1.ГодПродажи 
and Month(inv.InvoiceDate) = t1.МесяцПродажи
where inv.InvoiceDate >= '2015-01-01'
order by ДатаПродажи

--	SQL Server Execution Times:
--	CPU time = 2407 ms,  elapsed time = 7743 ms.

/*
2. Сделайте расчет суммы нарастающим итогом в предыдущем запросе с помощью оконной функции.
   Сравните производительность запросов 1 и 2 с помощью set statistics time, io on
*/
set statistics time, io on;
with t1 as(
select 
--ID				= inv.InvoiceID,
--Клиент			= peo.FullName,
--ДатаПродажи		= inv.InvoiceDate, 
ГодПродажи		= Year(inv.InvoiceDate),
МесяцПродажи	= Month(inv.InvoiceDate),
Сумма			= sum(invl.Quantity * invl.UnitPrice) 
from WideWorldImporters.Sales.Invoices as inv 
inner join WideWorldImporters.Sales.InvoiceLines as invl 
on inv.InvoiceID = invl.InvoiceID
where inv.InvoiceDate >= '2015-01-01'
group by Year(inv.InvoiceDate), Month(inv.InvoiceDate)
)


select 
ID				= inv.InvoiceID,
Клиент			= peo.FullName,
ДатаПродажи		= inv.InvoiceDate,
СуммаПродажи	= invl.Quantity*invl.UnitPrice,
СуммаЗаМесяц	= sum(invl.Quantity*invl.UnitPrice) over (partition by t1.ГодПродажи, t1.МесяцПродажи),
НарастающийИтог = sum(invl.Quantity*invl.UnitPrice) over (partition by t1.ГодПродажи order by t1.МесяцПродажи)
from WideWorldImporters.Sales.Invoices as inv 
inner join WideWorldImporters.Sales.InvoiceLines as invl 
on inv.InvoiceID = invl.InvoiceID
inner join WideWorldImporters.Application.People as peo
on inv.ContactPersonID = peo.PersonID
inner join t1 as t1
on Year(inv.InvoiceDate) = t1.ГодПродажи 
and Month(inv.InvoiceDate) = t1.МесяцПродажи
where inv.InvoiceDate >= '2015-01-01'
order by t1.ГодПродажи, t1.МесяцПродажи

--SQL Server Execution Times:
-- 1-задание
-- CPU time = 2407 ms,  elapsed time = 7743 ms.
-- 2-задание
-- CPU time = 390 ms,  elapsed time = 5343 ms.



/*
3. Вывести список 2х самых популярных продуктов (по количеству проданных) 
в каждом месяце за 2016 год (по 2 самых популярных продукта в каждом месяце).
*/

--select top 1 * from Warehouse.StockItems where StockItemID = 67

use WideWorldImporters

select t0.РангВМесяце, t0.Month2016, '2016' Год, t0.НазваниеТовара, t0.ID
from
(
	select 
	rank() over (partition by t1.Month2016 order by t1.ПроданоВМесяце desc) РангВМесяце,
	t1.Month2016, 
	t1.ПроданоВМесяце,
	t1.ID,
	t1.НазваниеТовара
	from 
	(
		select distinct
		Month(inv.InvoiceDate) Month2016,
		sum(invl.Quantity) over (partition by invl.StockItemID, Month(inv.InvoiceDate)) ПроданоВМесяце,
		invl.StockItemID ID,
		invl.Description НазваниеТовара
		from Sales.InvoiceLines invl inner join Sales.Invoices inv on invl.InvoiceID = inv.InvoiceID
		where inv.InvoiceDate >= '2016-01-01' 
	) t1
) t0
where t0.РангВМесяце < 3
order by t0.Month2016 asc, t0.ПроданоВМесяце desc



/*
4. Функции одним запросом
Посчитайте по таблице товаров (в вывод также должен попасть ид товара, название, брэнд и цена):
* пронумеруйте записи по названию товара, так чтобы при изменении буквы алфавита нумерация начиналась заново
* посчитайте общее количество товаров и выведете полем в этом же запросе
* посчитайте общее количество товаров в зависимости от первой буквы названия товара
* отобразите следующий id товара исходя из того, что порядок отображения товаров по имени 
* предыдущий ид товара с тем же порядком отображения (по имени)
* названия товара 2 строки назад, в случае если предыдущей строки нет нужно вывести "No items"
* сформируйте 30 групп товаров по полю вес товара на 1 шт

Для этой задачи НЕ нужно писать аналог без аналитических функций.
*/

--TODO:
--* пронумеруйте записи по названию товара, так чтобы при изменении буквы алфавита нумерация начиналась заново
--ВООБЩЕ НЕ ПОНЯТНОЕ ЗАДАНИЕ!!!
select 
row_number() over (partition by t1.firstsymbol order by t1.StockItemName),
*
from(
select SUBSTRING (StockItems.StockItemName, 1, 1) as firstsymbol, * from Warehouse.StockItems 
) t1


--* посчитайте общее количество товаров и выведете полем в этом же запросе
select
(select 
--sum(StockItems.StockItemID)
count(*)
from Warehouse.StockItems) Количество,
* from Warehouse.StockItems

--* посчитайте общее количество товаров в зависимости от первой буквы названия товара
select distinct
sum(t1.num) over (partition by t1.firstsymbol) Количество,
t1.firstsymbol
from
(
select SUBSTRING (StockItemName, 1, 1) as firstsymbol, 1 as num from Warehouse.StockItems
) t1


--* отобразите следующий id товара исходя из того, что порядок отображения товаров по имени 
-- если честно не очень понял как применить lead и lag
select 
lead(StockItemID, 1) over (partition by StockItemName order by StockItemID)
,*
from Warehouse.StockItems

--* предыдущий ид товара с тем же порядком отображения (по имени)
select 
lag(StockItemID, 1) over (partition by StockItemName order by StockItemID)
,*
from Warehouse.StockItems


/*
5. По каждому сотруднику выведите последнего клиента, которому сотрудник что-то продал.
   В результатах должны быть ид и фамилия сотрудника, ид и название клиента, дата продажи, сумму сделки.
*/
select * 
from 
(
	select 	rank() over (partition by t1.IDСотрудника order by t1.Дата desc) Последняя,
	* 
	from 
	(
		select distinct
		peo.CustomerID as IDСотрудника, 
		peo.[CustomerName] as ИмяСотрудника, 
		peo2.PersonID as IDКлиента, 
		peo2.FullName as ИмяКлиента, 
		inv.ConfirmedDeliveryTime as Дата,
		sum(invl.Quantity*invl.UnitPrice) over (partition by invl.InvoiceID) as Сумма
		from [Sales].[Invoices] inv inner join Sales.Customers peo 
		on inv.SalespersonPersonID = peo.CustomerID
		inner join [Application].[People] peo2 
		on inv.ContactPersonID = peo2.PersonID
		inner join Sales.InvoiceLines invl
		on inv.InvoiceID = invl.InvoiceID
	) t1
) t0
where t0.Последняя = 1

/*
6. Выберите по каждому клиенту два самых дорогих товара, которые он покупал.
В результатах должно быть ид клиета, его название, ид товара, цена, дата покупки.
*/

	select 	
	* 
	from 
	(
		select distinct
		peo2.CustomerID as IDКлиента, 
		peo2.[CustomerName] as ИмяКлиента, 
		invl.StockItemID as IDТовара,
		inv.InvoiceDate as Дата,
		invl.UnitPrice,
		dense_rank() over (partition by peo2.CustomerID order by invl.UnitPrice desc) as ЦенаРейтинг
		from [Sales].[Invoices] inv 
		inner join Sales.Customers peo2 
		on inv.ContactPersonID = peo2.CustomerID
		inner join Sales.InvoiceLines invl
		on inv.InvoiceID = invl.InvoiceID
	) t1 where t1.ЦенаРейтинг < 3

