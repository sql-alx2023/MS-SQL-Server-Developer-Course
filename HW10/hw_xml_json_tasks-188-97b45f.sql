/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "08 - Выборки из XML и JSON полей".

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
Примечания к заданиям 1, 2:
* Если с выгрузкой в файл будут проблемы, то можно сделать просто SELECT c результатом в виде XML. 
* Если у вас в проекте предусмотрен экспорт/импорт в XML, то можете взять свой XML и свои таблицы.
* Если с этим XML вам будет скучно, то можете взять любые открытые данные и импортировать их в таблицы (например, с https://data.gov.ru).
* Пример экспорта/импорта в файл https://docs.microsoft.com/en-us/sql/relational-databases/import-export/examples-of-bulk-import-and-export-of-xml-documents-sql-server
*/


/*
1. В личном кабинете есть файл StockItems.xml.
Это данные из таблицы Warehouse.StockItems.
Преобразовать эти данные в плоскую таблицу с полями, аналогичными Warehouse.StockItems.
Поля: StockItemName, SupplierID, UnitPackageID, OuterPackageID, QuantityPerOuter, TypicalWeightPerUnit, LeadTimeDays, IsChillerStock, TaxRate, UnitPrice 

Загрузить эти данные в таблицу Warehouse.StockItems: 
существующие записи в таблице обновить, отсутствующие добавить (сопоставлять записи по полю StockItemName). 

Сделать два варианта: с помощью OPENXML и через XQuery.
*/

--SELECT * FROM OPENROWSET (BULK 'E:\BCP\StockItems.xml',  SINGLE_CLOB) AS data;
declare @xmldocument XML;
SELECT @xmlDocument = BulkColumn FROM OPENROWSET (BULK 'E:\BCP\StockItems.xml',  SINGLE_CLOB) AS data;
--SELECT @xmlDocument AS [@xmlDocument];

DECLARE @docHandle INT;
EXEC sp_xml_preparedocument @docHandle OUTPUT, @xmlDocument;

DROP TABLE IF EXISTS #StockItemsXML;

CREATE TABLE #StockItemsXML(
	[StockItemName] NVARCHAR(100),
	[SupplierID] int,
	[UnitPackageID] int,
	[OuterPackageID] int,
	[QuantityPerOuter] int,
	[TypicalWeightPerUnit] decimal(18,3),
	[LeadTimeDays] int,
	[IsChillerStock] bit,
	[TaxRate] decimal(18,3),
	[UnitPrice] decimal(18,2)
);

INSERT INTO #StockItemsXML
SELECT *
FROM OPENXML(@docHandle, N'/StockItems/Item')
WITH ( 
	[StockItemName] NVARCHAR(100)  '@Name',
	[SupplierID] int  'SupplierID',
	[UnitPackageID] int  'Package/UnitPackageID',
	[OuterPackageID] int  'Package/OuterPackageID',
	[QuantityPerOuter] int  'Package/QuantityPerOuter',
	[TypicalWeightPerUnit] decimal(18,3)  'Package/TypicalWeightPerUnit',
	[LeadTimeDays] int  'LeadTimeDays',
	[IsChillerStock] bit  'IsChillerStock',
	[TaxRate] decimal(18,3)  'TaxRate',
	[UnitPrice] decimal(18,2)  'UnitPrice'
	);

--select * from #StockItemsXML
EXEC sp_xml_removedocument @docHandle;

select * from Warehouse.StockItems as ttarget inner join #StockItemsXML as tsource on ttarget.StockItemName = tsource.StockItemName COLLATE Latin1_General_100_CI_AI

  merge into Warehouse.StockItems as TTarget
  using #StockItemsXML as TSource
  on TTarget.StockItemName = TSource.StockItemName COLLATE Latin1_General_100_CI_AI
  when matched and (TTarget.SupplierID <> TSource.SupplierID or TTarget.UnitPackageID <> TSource.UnitPackageID or 
					TTarget.OuterPackageID <> TSource.OuterPackageID or TTarget.TypicalWeightPerUnit <> TSource.TypicalWeightPerUnit or 
					TTarget.LeadTimeDays <> TSource.LeadTimeDays or TTarget.IsChillerStock <> TSource.IsChillerStock or
					TTarget.TaxRate <> TSource.TaxRate or TTarget.UnitPrice <> TSource.UnitPrice or TTarget.QuantityPerOuter <> TSource.QuantityPerOuter)
	then update set TTarget.StockItemName = TSource.StockItemName, TTarget.SupplierID = TSource.SupplierID, TTarget.UnitPackageID = TSource.UnitPackageID, TTarget.OuterPackageID = TSource.OuterPackageID, TTarget.TypicalWeightPerUnit = TSource.TypicalWeightPerUnit, 
					TTarget.LeadTimeDays = TSource.LeadTimeDays, TTarget.IsChillerStock = TSource.IsChillerStock, TTarget.TaxRate = TSource.TaxRate, TTarget.UnitPrice = TSource.UnitPrice, TTarget.QuantityPerOuter = TSource.QuantityPerOuter 
  when not matched by target
	then insert (StockItemName, SupplierID,UnitPackageID,OuterPackageID,QuantityPerOuter,TypicalWeightPerUnit,LeadTimeDays,IsChillerStock,TaxRate,UnitPrice,LastEditedBy)
	  values
	  (TSource.StockItemName,TSource.SupplierID,TSource.UnitPackageID,TSource.OuterPackageID,TSource.QuantityPerOuter,TSource.TypicalWeightPerUnit,TSource.LeadTimeDays,
	  TSource.IsChillerStock,TSource.TaxRate,TSource.UnitPrice,1);


----- через XQuery
DECLARE @x XML;
SET @x = ( 
  SELECT * FROM OPENROWSET
  (BULK 'E:\BCP\StockItems.xml',
   SINGLE_BLOB) AS d);

DROP TABLE IF EXISTS #StockItemsXML;

CREATE TABLE #StockItemsXML(
	[StockItemName] NVARCHAR(100),
	[SupplierID] int,
	[UnitPackageID] int,
	[OuterPackageID] int,
	[QuantityPerOuter] int,
	[TypicalWeightPerUnit] decimal(18,3),
	[LeadTimeDays] int,
	[IsChillerStock] bit,
	[TaxRate] decimal(18,3),
	[UnitPrice] decimal(18,2)
);

INSERT INTO #StockItemsXML
SELECT  
  t.Item.value('(@Name[1])', 'varchar(100)') AS [SupplierName],
  t.Item.value('SupplierID[1]', 'int') AS [Id],
  t.Item.value('(Package/UnitPackageID)[1]', 'int') AS UnitPackageID,
  t.Item.value('(Package/OuterPackageID)[1]', 'int') AS OuterPackageID,
  t.Item.value('(Package/QuantityPerOuter)[1]', 'int') AS QuantityPerOuter,
  t.Item.value('(Package/TypicalWeightPerUnit)[1]', 'decimal(18,3)') AS TypicalWeightPerUnit,
  t.Item.value('(LeadTimeDays)[1]', 'int') AS LeadTimeDays,
  t.Item.value('(IsChillerStock)[1]', 'BIT') AS IsChillerStock,
  t.Item.value('(TaxRate)[1]', 'decimal(18,3)') AS TaxRate,
  t.Item.value('(UnitPrice)[1]', 'decimal(18,2)') AS UnitPrice
FROM @x.nodes('/StockItems/Item') AS t(Item);

--select * from #StockItemsXML

-- Далее аналогично предыдущему варианту

/*
2. Выгрузить данные из таблицы StockItems в такой же xml-файл, как StockItems.xml
*/

SELECT 
    StockItemName AS [@Name],
	SupplierID as [SupplierID],
	UnitPackageID as [Package/UnitPackageID],
	OuterPackageID as [Package/OuterPackageID],
	QuantityPerOuter as [Package/QuantityPerOuter],
	TypicalWeightPerUnit as [Package/TypicalWeightPerUnit],
	LeadTimeDays as [LeadTimeDays],
	IsChillerStock as [IsChillerStock],
	TaxRate as [TaxRate],
	UnitPrice as [UnitPrice]	
FROM Warehouse.StockItems 
FOR XML PATH('Item'), ROOT('StockItems');


/*
3. В таблице Warehouse.StockItems в колонке CustomFields есть данные в JSON.
Написать SELECT для вывода:
- StockItemID
- StockItemName
- CountryOfManufacture (из CustomFields)
- FirstTag (из поля CustomFields, первое значение из массива Tags)
*/

SELECT
    StockItemID AS StockItemID,
    StockItemName AS StockItemName,
    JSON_VALUE(CustomFields, '$.CountryOfManufacture') AS CountryOfManufacture,
    JSON_VALUE(CustomFields, '$.Tags[0]') AS FirstTag
 FROM Warehouse.StockItems;

/*
4. Найти в StockItems строки, где есть тэг "Vintage".
Вывести: 
- StockItemID
- StockItemName
- (опционально) все теги (из CustomFields) через запятую в одном поле

Тэги искать в поле CustomFields, а не в Tags.
Запрос написать через функции работы с JSON.
Для поиска использовать равенство, использовать LIKE запрещено.

Должно быть в таком виде:
... where ... = 'Vintage'

Так принято не будет:
... where ... Tags like '%Vintage%'
... where ... CustomFields like '%Vintage%' 
*/


SELECT
    StockItemID AS StockItemID,
    StockItemName AS StockItemName,
	JSON_QUERY(CustomFields, '$.Tags') AS AllTags
FROM Warehouse.StockItems
CROSS APPLY OPENJSON(CustomFields, '$.Tags') Tags
WHERE Tags.value = 'Vintage';
