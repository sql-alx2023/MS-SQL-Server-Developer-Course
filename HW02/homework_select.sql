/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.
Занятие "02 - Оператор SELECT и простые фильтры, JOIN".

Задания выполняются с использованием базы данных WideWorldImporters.

Бэкап БД WideWorldImporters можно скачать отсюда:
https://github.com/Microsoft/sql-server-samples/releases/download/wide-world-importers-v1.0/WideWorldImporters-Full.bak

Описание WideWorldImporters от Microsoft:
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-what-is
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-oltp-database-catalog
*/

-- ---------------------------------------------------------------------------
-- Задание - написать выборки для получения указанных ниже данных.
-- ---------------------------------------------------------------------------

USE WideWorldImporters

/*
1. Все товары, в названии которых есть "urgent" или название начинается с "Animal".
Вывести: ИД товара (StockItemID), наименование товара (StockItemName).
Таблицы: Warehouse.StockItems.
*/

select StockItemID, StockItemName from WideWorldImporters.Warehouse.StockItems
where StockItemName like '%urgent%' or StockItemName like 'Animal%'

/*
2. Поставщиков (Suppliers), у которых не было сделано ни одного заказа (PurchaseOrders).
Сделать через JOIN, с подзапросом задание принято не будет.
Вывести: ИД поставщика (SupplierID), наименование поставщика (SupplierName).
Таблицы: Purchasing.Suppliers, Purchasing.PurchaseOrders.
По каким колонкам делать JOIN подумайте самостоятельно.
*/

select sup.SupplierID, sup.SupplierName from Purchasing.Suppliers as sup left join Purchasing.PurchaseOrders as pur
on sup.SupplierID = pur.SupplierID where pur.SupplierID is null

/*
3. Заказы (Orders) с ценой товара (UnitPrice) более 100$ 
либо количеством единиц (Quantity) товара более 20 штук
и присутствующей датой комплектации всего заказа (PickingCompletedWhen).
Вывести:
* OrderID
* дату заказа (OrderDate) в формате ДД.ММ.ГГГГ
* название месяца, в котором был сделан заказ
* номер квартала, в котором был сделан заказ
* треть года, к которой относится дата заказа (каждая треть по 4 месяца)
* имя заказчика (Customer)
Добавьте вариант этого запроса с постраничной выборкой,
пропустив первую 1000 и отобразив следующие 100 записей.

Сортировка должна быть по номеру квартала, трети года, дате заказа (везде по возрастанию).

Таблицы: Sales.Orders, Sales.OrderLines, Sales.Customers.
*/
DECLARE 
    @pagesize BIGINT = 100,
    @pagenum  BIGINT = 11;

select ord.OrderID, 
	convert(varchar, ord.OrderDate, 104) [Дата заказа], 
	format(ord.OrderDate, 'MMMM', 'ru-ru') [Месяц заказа], 
	datepart(quarter, ord.OrderDate) as [Квартал],
	CEILING(cast(month(ord.OrderDate) as decimal(4,2))/4) [Треть], 
	con.CustomerName 
	from Sales.Orders ord 
	inner join Sales.OrderLines ordl on ord.OrderID = ordl.OrderID
	inner join Sales.Customers con on ord.CustomerID = con.CustomerID
	where (ordl.UnitPrice > 100 or ordl.Quantity > 20) and not ord.PickingCompletedWhen is null
	ORDER BY [Квартал], [Треть], [Дата заказа]
OFFSET (@pagenum - 1) * @pagesize ROWS FETCH NEXT @pagesize ROWS ONLY

/*
4. Заказы поставщикам (Purchasing.Suppliers),
которые должны быть исполнены (ExpectedDeliveryDate) в январе 2013 года
с доставкой "Air Freight" или "Refrigerated Air Freight" (DeliveryMethodName)
и которые исполнены (IsOrderFinalized).
Вывести:
* способ доставки (DeliveryMethodName)
* дата доставки (ExpectedDeliveryDate)
* имя поставщика
* имя контактного лица принимавшего заказ (ContactPerson)

Таблицы: Purchasing.Suppliers, Purchasing.PurchaseOrders, Application.DeliveryMethods, Application.People.
*/

select del.DeliveryMethodName, pur.ExpectedDeliveryDate, sup.SupplierName, peo.FullName from Purchasing.Suppliers sup 
inner join Purchasing.PurchaseOrders pur on sup.SupplierID = pur.SupplierID
inner join Application.DeliveryMethods del on pur.DeliveryMethodID = del.DeliveryMethodID
inner join Application.People peo on pur.ContactPersonID = peo.PersonID
where	pur.ExpectedDeliveryDate between '2013-01-01' and '2013-01-31' and
		del.DeliveryMethodName in ('Air Freight', 'Refrigerated Air Freight') and
		pur.IsOrderFinalized = 1

/*
5. Десять последних продаж (по дате продажи) с именем клиента и именем сотрудника,
который оформил заказ (SalespersonPerson).
Сделать без подзапросов.
*/

select top 10 cus.CustomerName [Имя клиента], peo.FullName [Имя сотрудника], * from Sales.Orders ord 
inner join Sales.Customers cus on ord.CustomerID = cus.CustomerID
inner join Application.People peo on ord.SalespersonPersonID = peo.PersonID
order by OrderDate desc

/*
6. Все ид и имена клиентов и их контактные телефоны,
которые покупали товар "Chocolate frogs 250g".
Имя товара смотреть в таблице Warehouse.StockItems.
*/

select ord.CustomerID [ИД], cus.CustomerName [Имя клиента], PhoneNumber [Телефон] from Sales.Orders ord 
inner join Sales.Customers cus on ord.CustomerID = cus.CustomerID
inner join Sales.OrderLines ordl on ord.OrderID = ordl.OrderID
inner join  Warehouse.StockItems sto on ordl.StockItemID = sto.StockItemID
where stockItemName = 'Chocolate frogs 250g'
