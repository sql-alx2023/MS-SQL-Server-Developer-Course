USE [WideWorldImporters]
GO
-- 1. ������� ������� ��� �������
CREATE TABLE [Sales].[ResultReportOrdersByCustomer](
	[CustomerID] [nchar](10),
	[Date1] [date],
	[Date2] [date],
	[Count] [int],
	[ReportDate] [date]
) ON [USERDATA]
GO

-- 2. ������� ���� ���������
CREATE MESSAGE TYPE
[//WWI/SB/RequestMessage]
VALIDATION=WELL_FORMED_XML; 
CREATE MESSAGE TYPE
[//WWI/SB/ReplyMessage]
VALIDATION=WELL_FORMED_XML; 

-- 3. ������� ��������
CREATE CONTRACT [//WWI/SB/Contract]
      ([//WWI/SB/RequestMessage]
         SENT BY INITIATOR,
       [//WWI/SB/ReplyMessage]
         SENT BY TARGET
      );

-- 4. ������� ������� ��� ������� � ����������
CREATE QUEUE TargetQueueWWI;
CREATE SERVICE [//WWI/SB/TargetService]
       ON QUEUE TargetQueueWWI
       ([//WWI/SB/Contract]);

CREATE QUEUE InitiatorQueueWWI;
CREATE SERVICE [//WWI/SB/InitiatorService]
       ON QUEUE InitiatorQueueWWI
       ([//WWI/SB/Contract]);

-- 5. ��������� �������� (�� �����: InvoiceID �� ������� Invoices � ��� ���� �������������� ������)
CREATE PROCEDURE Sales.SendReport
	@InvoiceID INT,
	@Date1 Date,
	@Date2 Date
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @InitDlgHandle UNIQUEIDENTIFIER;
	DECLARE @RequestMessage NVARCHAR(4000);
	declare @CustomerID int
	declare @Result int
	
	BEGIN TRAN

	-- ����������� ID �������
	select @CustomerID = (select CustomerID from Sales.Invoices where InvoiceID = @InvoiceID)  
	
	-- ����������� ���������� ������� � ������� � �������� �������
	SELECT @Result = count(*) 
	FROM [WideWorldImporters].[Sales].[Orders]
	where CustomerID = @CustomerID and OrderDate between @Date1 and @Date2

	-- ���������� � XML (�� ����� ���� ������)
	SELECT @RequestMessage = (select * from (SELECT @CustomerID as [CustomerID], @Date1 as [Date1], @Date2 as [Date2], @result as [Count], GETDATE() as [ReportDate]) as ReportLine
								FOR XML AUTO, root('RequestMessage')); 
	
	--������� ������
	BEGIN DIALOG @InitDlgHandle
	FROM SERVICE
	[//WWI/SB/InitiatorService] --�� ����� �������
	TO SERVICE
	'//WWI/SB/TargetService'    --� ����� �������
	ON CONTRACT
	[//WWI/SB/Contract]         --� ������ ����� ���������
	WITH ENCRYPTION=OFF;        --�� �����������

	--���������� ���������
	SEND ON CONVERSATION @InitDlgHandle 
	MESSAGE TYPE
	[//WWI/SB/RequestMessage]
	(@RequestMessage);
	
	COMMIT TRAN 
END
GO

--6. ��������� ���������
CREATE PROCEDURE Sales.GetReport
AS
BEGIN

	DECLARE @TargetDlgHandle UNIQUEIDENTIFIER,
			@Message NVARCHAR(4000),
			@MessageType Sysname,
			@ReplyMessage NVARCHAR(4000),
			@ReplyMessageName Sysname,
			@InvoiceID INT,
			@CustomerID int,
			@Date1 date,
			@Date2 date,
			@Count int,
			@ReportDate DateTime,
			@xml XML;
	
	BEGIN TRAN; 

	--�������� ��������� �� ���������� ������� ��������� � �������
	RECEIVE TOP(1) 
		@TargetDlgHandle = Conversation_Handle, 
		@Message = Message_Body,
		@MessageType = Message_Type_Name 
	FROM dbo.TargetQueueWWI; 

	SET @xml = CAST(@Message AS XML);

	--������� ������
	SELECT 
	@CustomerID = R.ReportLine.value('@CustomerID','INT'),
	@Date1 = R.ReportLine.value('@Date1','DATE'),
	@Date2 = R.ReportLine.value('@Date2','DATE'),
	@Count = R.ReportLine.value('@Count','INT'),
	@ReportDate = R.ReportLine.value('@ReportDate','DATETIME') 
	FROM @xml.nodes('/RequestMessage/ReportLine') as R(ReportLine);

	-- ���������� � ������� �� �.1
	INSERT INTO Sales.ResultReportOrdersByCustomer(CustomerID, Date1, Date2, [Count], ReportDate) Values(@CustomerID, @Date1, @Date2, @Count, @ReportDate)
		
	-- Confirm and Send a reply
	IF @MessageType=N'//WWI/SB/RequestMessage' --���� ��� ��� ���������
	BEGIN
		SET @ReplyMessage =N'<ReplyMessage> Message received</ReplyMessage>'; --�����
	    --���������� ��������� ���� �����������, ��� ��� ������ ������
		SEND ON CONVERSATION @TargetDlgHandle
		MESSAGE TYPE
		[//WWI/SB/ReplyMessage]
		(@ReplyMessage);
		END CONVERSATION @TargetDlgHandle; --� ��� � ���������� �������!!! - ��� �������������(����-����) ��� ������ ����
		                                   --������ ��������� ������ �� �������� ������� ���������
	END 

	COMMIT TRAN;
END

-- 7. ��������� ��� �������/�������������
CREATE PROCEDURE Sales.ConfirmReport
AS
BEGIN
	--Receiving Reply Message from the Target.	
	DECLARE @InitiatorReplyDlgHandle UNIQUEIDENTIFIER,
			@ReplyReceivedMessage NVARCHAR(1000) 
	
	BEGIN TRAN; 
	    --�������� ��������� �� �������, ������� ��������� � ����������
		RECEIVE TOP(1)
			@InitiatorReplyDlgHandle=Conversation_Handle
			,@ReplyReceivedMessage=Message_Body
		FROM dbo.InitiatorQueueWWI; 
		
		END CONVERSATION @InitiatorReplyDlgHandle; --��� ������ ����
		
	COMMIT TRAN; 
END

--8. ����������� �������
ALTER QUEUE [dbo].[InitiatorQueueWWI] WITH STATUS = ON --OFF=������� �� ��������(������ ���� ���������� ��������)
                                          ,RETENTION = OFF --ON=��� ����������� ��������� �������� � ������� �� ��������� �������
										  ,POISON_MESSAGE_HANDLING (STATUS = OFF) --ON=����� 5 ������ ������� ����� ���������
	                                      ,ACTIVATION (STATUS = ON --OFF=������� �� ���������� ��(� PROCEDURE_NAME)(������ �� ����� ����������� ��, �� � ������� ���������)  
										              ,PROCEDURE_NAME = Sales.ConfirmReport
													  ,MAX_QUEUE_READERS = 1 --���������� �������(�� ������������ ���������) ��� ��������� ���������(0-32767)
													                         --(0=���� �� ��������� ���������)(������ �� ����� ����������� ��, ��� ������ ���������) 
													  ,EXECUTE AS OWNER --������ �� ����� ������� ���������� ��
													  ) 

GO
ALTER QUEUE [dbo].[TargetQueueWWI] WITH STATUS = ON 
                                       ,RETENTION = OFF 
									   ,POISON_MESSAGE_HANDLING (STATUS = OFF)
									   ,ACTIVATION (STATUS = ON 
									               ,PROCEDURE_NAME = Sales.GetReport
												   ,MAX_QUEUE_READERS = 1
												   ,EXECUTE AS OWNER 
												   ) 

GO

--9. �������� �����������������
EXEC Sales.SendReport @invoiceId = 1, @Date1 = '2013-06-01', @Date2 = '2013-09-01' --������������ � ��������� �����

--������������ ��� ������ �������
--EXEC Sales.GetReport;
--EXEC Sales.ConfirmReport;

Select * FROM Sales.ResultReportOrdersByCustomer --�������, ��� ����� ������ � ��������� � �������

--10. �������� �����

DROP SERVICE [//WWI/SB/TargetService]
GO
DROP SERVICE [//WWI/SB/InitiatorService]
GO
DROP QUEUE [dbo].[TargetQueueWWI]
GO 
DROP QUEUE [dbo].[InitiatorQueueWWI]
GO
DROP CONTRACT [//WWI/SB/Contract]
GO
DROP MESSAGE TYPE [//WWI/SB/RequestMessage]
GO
DROP MESSAGE TYPE [//WWI/SB/ReplyMessage]
GO
DROP PROCEDURE IF EXISTS  Sales.SendReport;
GO
DROP PROCEDURE IF EXISTS  Sales.GetReport;
GO
DROP PROCEDURE IF EXISTS  Sales.ConfirmReport;
GO
DROP TABLE Sales.ResultReportOrdersByCustomer
GO
