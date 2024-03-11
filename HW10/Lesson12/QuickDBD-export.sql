-- Exported from QuickDBD: https://www.quickdatabasediagrams.com/
-- NOTE! If you have used non-SQL datatypes in your design, you will have to change these here.


SET XACT_ABORT ON

BEGIN TRANSACTION QUICKDBD

-- Клиенты
CREATE TABLE [Customer] (
    -- Код клиента
    [CustomerID] int  NOT NULL ,
    -- ФИО клиента
    [Name] string  NOT NULL ,
    -- E-mail клиента
    [Email] string  NOT NULL ,
    CONSTRAINT [PK_Customer] PRIMARY KEY CLUSTERED (
        [CustomerID] ASC
    )
)

-- Заявки
CREATE TABLE [Orders] (
    -- ID заявки
    [OrderID] int  NOT NULL ,
    -- Дата и время выставления заявки
    [Date] datetime  NOT NULL ,
    -- Код клиента
    [CustomerID] int  NOT NULL ,
    -- Вид заявки
    [TypeID] int  NOT NULL ,
    -- Ценная бумага
    [SecuritiesCode] string  NOT NULL ,
    -- Количество
    [Qty] int  NOT NULL ,
    -- Цена
    [Price] int  NOT NULL ,
    -- Сумма
    [Value] int  NOT NULL ,
    -- Статус заявки
    [OrderStatusID] int  NOT NULL ,
    CONSTRAINT [PK_Orders] PRIMARY KEY CLUSTERED (
        [OrderID] ASC
    )
)

-- Сделки
CREATE TABLE [Trades] (
    -- ID сделки
    [TradeID] int  NOT NULL ,
    -- ID заявки
    [OrderID] int  NOT NULL ,
    -- Дата и время сделки
    [Date] datetime  NOT NULL ,
    -- Код клиента
    [CustomerID] int  NOT NULL ,
    -- Вид сделки (покупка/продажа)
    [TypeID] int  NOT NULL ,
    -- Ценная бумага
    [SecuritiesCode] string  NOT NULL ,
    -- Количество
    [Qty] int  NOT NULL ,
    -- Цена
    [Price] int  NOT NULL ,
    -- Сумма
    [Value] int  NOT NULL ,
    CONSTRAINT [PK_Trades] PRIMARY KEY CLUSTERED (
        [TradeID] ASC
    )
)

-- Статусы заявок (Открыта/Исполнена/Отменена)
CREATE TABLE [OrderStatus] (
    [OrderStatusID] int  NOT NULL ,
    [Name] string  NOT NULL ,
    CONSTRAINT [PK_OrderStatus] PRIMARY KEY CLUSTERED (
        [OrderStatusID] ASC
    ),
    CONSTRAINT [UK_OrderStatus_Name] UNIQUE (
        [Name]
    )
)

-- Виды заявок/сделок (Покупка/Продажа)
CREATE TABLE [OrdersType] (
    [TypeID] int  NOT NULL ,
    [Name] string  NOT NULL ,
    CONSTRAINT [PK_OrdersType] PRIMARY KEY CLUSTERED (
        [TypeID] ASC
    ),
    CONSTRAINT [UK_OrdersType_Name] UNIQUE (
        [Name]
    )
)

-- Ценные бумаги
CREATE TABLE [Securities] (
    -- Код бумаги
    [SecuritiesCode] string  NOT NULL ,
    -- Наименование бумаги
    [Name] string  NOT NULL ,
    CONSTRAINT [PK_Securities] PRIMARY KEY CLUSTERED (
        [SecuritiesCode] ASC
    )
)

ALTER TABLE [Orders] WITH CHECK ADD CONSTRAINT [FK_Orders_CustomerID] FOREIGN KEY([CustomerID])
REFERENCES [Customer] ([CustomerID])

ALTER TABLE [Orders] CHECK CONSTRAINT [FK_Orders_CustomerID]

ALTER TABLE [Orders] WITH CHECK ADD CONSTRAINT [FK_Orders_TypeID] FOREIGN KEY([TypeID])
REFERENCES [OrdersType] ([TypeID])

ALTER TABLE [Orders] CHECK CONSTRAINT [FK_Orders_TypeID]

ALTER TABLE [Orders] WITH CHECK ADD CONSTRAINT [FK_Orders_SecuritiesCode] FOREIGN KEY([SecuritiesCode])
REFERENCES [Securities] ([SecuritiesCode])

ALTER TABLE [Orders] CHECK CONSTRAINT [FK_Orders_SecuritiesCode]

ALTER TABLE [Orders] WITH CHECK ADD CONSTRAINT [FK_Orders_OrderStatusID] FOREIGN KEY([OrderStatusID])
REFERENCES [OrderStatus] ([OrderStatusID])

ALTER TABLE [Orders] CHECK CONSTRAINT [FK_Orders_OrderStatusID]

ALTER TABLE [Trades] WITH CHECK ADD CONSTRAINT [FK_Trades_OrderID] FOREIGN KEY([OrderID])
REFERENCES [Orders] ([OrderID])

ALTER TABLE [Trades] CHECK CONSTRAINT [FK_Trades_OrderID]

ALTER TABLE [Trades] WITH CHECK ADD CONSTRAINT [FK_Trades_CustomerID] FOREIGN KEY([CustomerID])
REFERENCES [Customer] ([CustomerID])

ALTER TABLE [Trades] CHECK CONSTRAINT [FK_Trades_CustomerID]

ALTER TABLE [Trades] WITH CHECK ADD CONSTRAINT [FK_Trades_TypeID] FOREIGN KEY([TypeID])
REFERENCES [OrdersType] ([TypeID])

ALTER TABLE [Trades] CHECK CONSTRAINT [FK_Trades_TypeID]

ALTER TABLE [Trades] WITH CHECK ADD CONSTRAINT [FK_Trades_SecuritiesCode] FOREIGN KEY([SecuritiesCode])
REFERENCES [Securities] ([SecuritiesCode])

ALTER TABLE [Trades] CHECK CONSTRAINT [FK_Trades_SecuritiesCode]

COMMIT TRANSACTION QUICKDBD