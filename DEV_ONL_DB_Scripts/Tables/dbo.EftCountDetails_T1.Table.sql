USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EftCountDetails_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EftCountDetails_T1', @level2type=N'COLUMN',@level2name=N'CountAgencyAddenda_QNTY'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EftCountDetails_T1', @level2type=N'COLUMN',@level2name=N'CountAgency_QNTY'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EftCountDetails_T1', @level2type=N'COLUMN',@level2name=N'Agency_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EftCountDetails_T1', @level2type=N'COLUMN',@level2name=N'CountSvc_QNTY'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EftCountDetails_T1', @level2type=N'COLUMN',@level2name=N'Svc_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EftCountDetails_T1', @level2type=N'COLUMN',@level2name=N'CountDirectDeposit_QNTY'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EftCountDetails_T1', @level2type=N'COLUMN',@level2name=N'DirectDeposit_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EftCountDetails_T1', @level2type=N'COLUMN',@level2name=N'CountPreNotes_QNTY'

GO
EXEC sys.sp_dropextendedproperty @name=N'1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EftCountDetails_T1', @level2type=N'COLUMN',@level2name=N'Generate_DATE'

GO
/****** Object:  Table [dbo].[EftCountDetails_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[EftCountDetails_T1]
GO
/****** Object:  Table [dbo].[EftCountDetails_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[EftCountDetails_T1](
	[Generate_DATE] [date] NOT NULL,
	[CountPreNotes_QNTY] [numeric](11, 0) NOT NULL,
	[DirectDeposit_AMNT] [numeric](11, 2) NOT NULL,
	[CountDirectDeposit_QNTY] [numeric](11, 0) NOT NULL,
	[Svc_AMNT] [numeric](11, 2) NOT NULL,
	[CountSvc_QNTY] [numeric](11, 0) NOT NULL,
	[Agency_AMNT] [numeric](11, 2) NOT NULL,
	[CountAgency_QNTY] [numeric](11, 0) NOT NULL,
	[CountAgencyAddenda_QNTY] [numeric](11, 0) NOT NULL,
 CONSTRAINT [EFCD_I1] PRIMARY KEY CLUSTERED 
(
	[Generate_DATE] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

GO
EXEC sys.sp_addextendedproperty @name=N'1', @value=N'The Information for the EFT records on the Date generated.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EftCountDetails_T1', @level2type=N'COLUMN',@level2name=N'Generate_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This field will store the  total number of CP Direct Deposit pre-notes included in the outbound file for a given date.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EftCountDetails_T1', @level2type=N'COLUMN',@level2name=N'CountPreNotes_QNTY'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This field will store the summed total of the CP Direct Deposit disbursements for a given date.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EftCountDetails_T1', @level2type=N'COLUMN',@level2name=N'DirectDeposit_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This field will store the total count of actual CP Direct Deposit disbursements for a given date.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EftCountDetails_T1', @level2type=N'COLUMN',@level2name=N'CountDirectDeposit_QNTY'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This field will store the summed total of the CP Stored Value Card disbursements for a given date.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EftCountDetails_T1', @level2type=N'COLUMN',@level2name=N'Svc_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This field will store the total count of actual CP Stored Value Card disbursements for a given date.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EftCountDetails_T1', @level2type=N'COLUMN',@level2name=N'CountSvc_QNTY'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This field will store the summed total of the Agency EFT disbursements for a given date.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EftCountDetails_T1', @level2type=N'COLUMN',@level2name=N'Agency_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This field will store the total count of actual Agency EFT disbursements for a given date.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EftCountDetails_T1', @level2type=N'COLUMN',@level2name=N'CountAgency_QNTY'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This field will store the total count of the Agency EFT addenda records for a given date.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EftCountDetails_T1', @level2type=N'COLUMN',@level2name=N'CountAgencyAddenda_QNTY'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'This table stores the count and amount of the EFT/ Stored Value Card tranasctions that occurred on the days the financial batches were executed' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EftCountDetails_T1'
GO
