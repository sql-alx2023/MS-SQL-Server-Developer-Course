#  Exported from QuickDBD: https://www.quickdatabasediagrams.com/
#  NOTE! If you have used non-SQL datatypes in your design, you will have to change these here.

#  Клиенты
Customer
--
#  Код клиента
CustomerID int PK # Clustered
#  ФИО клиента
Name string
#  E-mail клиента
Email string

#  Заявки
Orders
--
#  ID заявки
OrderID int PK # Clustered
#  Дата и время выставления заявки
Date datetime
#  Код клиента
CustomerID int FK >- Customer.CustomerID
#  Вид заявки
TypeID int FK >- OrdersType.TypeID
#  Ценная бумага
SecuritiesCode string FK >- Securities.SecuritiesCode
#  Количество
Qty int
#  Цена
Price int
#  Сумма
Value int
#  Статус заявки
OrderStatusID int FK >- OrderStatus.OrderStatusID

#  Сделки
Trades
--
#  ID сделки
TradeID int PK # Clustered
#  ID заявки
OrderID int FK >- Orders.OrderID
#  Дата и время сделки
Date datetime

#  Статусы заявок (Открыта/Исполнена/Отменена)
OrderStatus
--
OrderStatusID int PK # Clustered
Name string UNIQUE

#  Виды заявок/сделок (Покупка/Продажа)
OrdersType
--
TypeID int PK # Clustered
Name string UNIQUE

#  Ценные бумаги
Securities
--
#  Код бумаги
SecuritiesCode string PK # Clustered
#  Наименование бумаги
Name string

