USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BillingHistory_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BillingHistory_T1', @level2type=N'COLUMN',@level2name=N'ReqReprint_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BillingHistory_T1', @level2type=N'COLUMN',@level2name=N'Request_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'3' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BillingHistory_T1', @level2type=N'COLUMN',@level2name=N'EventGlobalSeq_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BillingHistory_T1', @level2type=N'COLUMN',@level2name=N'Arrears_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BillingHistory_T1', @level2type=N'COLUMN',@level2name=N'ExpectToPay_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BillingHistory_T1', @level2type=N'COLUMN',@level2name=N'CurrentSupport_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BillingHistory_T1', @level2type=N'COLUMN',@level2name=N'Statement_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BillingHistory_T1', @level2type=N'COLUMN',@level2name=N'EndBill_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'2' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BillingHistory_T1', @level2type=N'COLUMN',@level2name=N'BeginBill_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BillingHistory_T1', @level2type=N'COLUMN',@level2name=N'TypeBill_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BillingHistory_T1', @level2type=N'COLUMN',@level2name=N'Case_IDNO'

GO
/****** Object:  Table [dbo].[BillingHistory_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[BillingHistory_T1]
GO
/****** Object:  Table [dbo].[BillingHistory_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[BillingHistory_T1](
	[Case_IDNO] [numeric](6, 0) NOT NULL,
	[TypeBill_CODE] [char](1) NOT NULL,
	[BeginBill_DATE] [date] NOT NULL,
	[EndBill_DATE] [date] NOT NULL,
	[Statement_DATE] [date] NOT NULL,
	[CurrentSupport_AMNT] [numeric](11, 2) NOT NULL,
	[ExpectToPay_AMNT] [numeric](11, 2) NOT NULL,
	[Arrears_AMNT] [numeric](11, 2) NOT NULL,
	[EventGlobalSeq_NUMB] [numeric](19, 0) NOT NULL,
	[Request_INDC] [char](1) NOT NULL,
	[ReqReprint_DATE] [date] NOT NULL,
 CONSTRAINT [BHIS_I1] PRIMARY KEY CLUSTERED 
(
	[BeginBill_DATE] ASC,
	[Case_IDNO] ASC,
	[EventGlobalSeq_NUMB] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
EXEC sys.sp_addextendedproperty @name=N'1', @value=N'Nine digit alpha numeric which represent the case.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BillingHistory_T1', @level2type=N'COLUMN',@level2name=N'Case_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Have Only Billing Type as NCP - N.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BillingHistory_T1', @level2type=N'COLUMN',@level2name=N'TypeBill_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'2', @value=N'Date the billing quarter, for which the statement created begins.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BillingHistory_T1', @level2type=N'COLUMN',@level2name=N'BeginBill_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Date the billing quarter, for which the statement created ends.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BillingHistory_T1', @level2type=N'COLUMN',@level2name=N'EndBill_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Date of the statement.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BillingHistory_T1', @level2type=N'COLUMN',@level2name=N'Statement_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Which has the current support amount.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BillingHistory_T1', @level2type=N'COLUMN',@level2name=N'CurrentSupport_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The amount which is needed to pay.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BillingHistory_T1', @level2type=N'COLUMN',@level2name=N'ExpectToPay_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The arrears amount.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BillingHistory_T1', @level2type=N'COLUMN',@level2name=N'Arrears_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'3', @value=N'Global Event Sequence number of the Event that caused this transaction.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BillingHistory_T1', @level2type=N'COLUMN',@level2name=N'EventGlobalSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates whether there is reprint request for the current statement or not.Possible values are Y -Reprint Request Provided or N -Reprint Request Not Provided. Default value is N.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BillingHistory_T1', @level2type=N'COLUMN',@level2name=N'Request_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Date when the reprint request was made. By default it will be low date (01-JAN-0001) as there won''t be any reprint request.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BillingHistory_T1', @level2type=N'COLUMN',@level2name=N'ReqReprint_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'This is a log table table that stores the coupon printing / reprinting request details.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BillingHistory_T1'
GO
