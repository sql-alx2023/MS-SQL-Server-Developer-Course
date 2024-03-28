CREATE DATABASE MarketDataMini;
GO

USE master;
IF DB_ID(N'MarketDataMini') IS NOT NULL
    DROP DATABASE MarketDataMini;
GO

CREATE DATABASE [MarketDataMini]
ON PRIMARY
(
    NAME = MarketDataMini, FILENAME = N'E:\MYDB\MarketDataMini\MarketDataMini.mdf',
    SIZE = 64MB,
    MAXSIZE = UNLIMITED,
    FILEGROWTH = 65536KB
)
LOG ON
(
    NAME = MarketDataMini, FILENAME = N'E:\MYDB\MarketDataMini\MarketDataMini.ldf',
    SIZE = 8MB,
    MAXSIZE = UNLIMITED,
    FILEGROWTH = 8192KB
)

-- Создаем таблицу Клиенты содержащую ФИО и email, кластерный инндекс по полю CustomersID
CREATE TABLE [Customers](
    [CustomerID] int NOT NULL,      --биржевой код клиента
    [Name] nvarchar(100) NOT NULL,
    [Email] nvarchar(50) 
    CONSTRAINT [PK_Customers] PRIMARY KEY CLUSTERED (
        [CustomerID] ASC
    )
)
-- Создаем индекс по полю Name в таблице Customers
CREATE index idx_Name on Customers(Name)

-- Создаем таблицу статусы заявок (могут принимать значения: Открыта/Исполнена/Отменена), нет необходимости в индексах
-- Возможно не нужна как отдельная таблица
CREATE TABLE [OrderStatus] (
    [OrderStatusID] int  NOT NULL,
    [Name] nvarchar(10)  NOT NULL
)

-- Создаем таблицу виды заявок/сделок (могут принимать значения: Покупка/Продажа), нет необходимости в индексах
-- Возможно не нужна как отдельная таблица
CREATE TABLE [OrdersType] (
    [OrdersTypeID] int  NOT NULL,
    [Name] nvarchar(10)  NOT NULL,
)

-- Создаем таблицу Ценные бумаги, содержащую торговый код бумаги и ее наименование, кластерный инндекс по полю SecuritiesCode
CREATE TABLE [Securities] (
    [SecuritiesCode] string  NOT NULL,
    [Name] string  NOT NULL,
    CONSTRAINT [PK_Securities] PRIMARY KEY CLUSTERED (
        [SecuritiesCode] ASC
    )
)
-- Создаем индекс по полю Name в таблице Securities
CREATE index idx_Name on Securities(Name)

-- Создаем таблицу Сделки, содержащую ID сделки, ID заявка (сделка создается только на основе исполненой заявки), дату и время создания сделки, кластерный индекс по полю TradeID 
CREATE TABLE [Trades] (
    [TradeID] int  NOT NULL ,
    [OrderID] int  NOT NULL ,
    [Date] datetime  NOT NULL ,
    CONSTRAINT [PK_Trades] PRIMARY KEY CLUSTERED (
        [TradeID] ASC
    )
)

-- Создаем таблицу Заявки с кластерным индексом OrderID
CREATE TABLE [Orders] (
    [OrderID] int  NOT NULL ,               -- ID заявки
    [Date] datetime  NOT NULL ,             -- Дата и время подачи заявка
    [CustomerID] int  NOT NULL ,            -- ID клиента
    [TypeID] int  NOT NULL ,                -- Тип заявки
    [SecuritiesCode] string  NOT NULL ,     -- ценная бумага
    [Qty] int  NOT NULL ,                   -- Количество
    [Price] int  NOT NULL ,                 -- Цена
    [Value] int  NOT NULL ,                 -- Сумма
    [OrderStatusID] int  NOT NULL ,         -- Статус заявки
    CONSTRAINT [PK_Orders] PRIMARY KEY CLUSTERED (
        [OrderID] ASC
    )
)

--EXEC sp_help Customers;

ALTER TABLE Orders ADD CONSTRAINT Orders_Status_Default DEFAULT (0) FOR OrderStatusID; -- по умолчанию заявка имеет статус Открыта
ALTER TABLE Orders ADD CONSTRAINT Orders_Status_Check CHECK (OrderStatusID in [0, 1, 2]); -- только три статуса заявки [0, 1, 2]
--ALTER TABLE Orders NOCHECK CONSTRAINT Orders_Status_Check -- если захочется отключить чек констрейнт, например добавиться новый статус заявки, например, "частично исполнена" 
--ALTER TABLE Orders CHECK CONSTRAINT Orders_Status_Check -- включить обратно

ALTER TABLE [Orders] WITH CHECK ADD CONSTRAINT [FK_Orders_CustomerID] FOREIGN KEY([CustomerID])
REFERENCES [Customer] ([CustomerID])
ON UPDATE CASCADE
ON DELETE CASCADE
ALTER TABLE [Orders] CHECK CONSTRAINT [FK_Orders_CustomerID]

ALTER TABLE [Orders] WITH CHECK ADD CONSTRAINT [FK_Orders_TypeID] FOREIGN KEY([TypeID])
REFERENCES [OrdersType] ([TypeID])
ALTER TABLE [Orders] CHECK CONSTRAINT [FK_Orders_TypeID]

ALTER TABLE [Orders] WITH CHECK ADD CONSTRAINT [FK_Orders_SecuritiesCode] FOREIGN KEY([SecuritiesCode])
REFERENCES [Securities] ([SecuritiesCode])
ON UPDATE CASCADE
ON DELETE CASCADE
ALTER TABLE [Orders] CHECK CONSTRAINT [FK_Orders_SecuritiesCode]

ALTER TABLE [Orders] WITH CHECK ADD CONSTRAINT [FK_Orders_OrderStatusID] FOREIGN KEY([OrderStatusID])
REFERENCES [OrderStatus] ([OrderStatusID])
ALTER TABLE [Orders] CHECK CONSTRAINT [FK_Orders_OrderStatusID]

ALTER TABLE [Trades] WITH CHECK ADD CONSTRAINT [FK_Trades_OrderID] FOREIGN KEY([OrderID])
REFERENCES [Orders] ([OrderID])
ON UPDATE CASCADE
ON DELETE CASCADE
ALTER TABLE [Trades] CHECK CONSTRAINT [FK_Trades_OrderID]
