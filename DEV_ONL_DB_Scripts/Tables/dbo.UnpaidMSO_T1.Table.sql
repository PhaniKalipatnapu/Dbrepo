USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UnpaidMSO_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UnpaidMSO_T1', @level2type=N'COLUMN',@level2name=N'EventGlobalSeq_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UnpaidMSO_T1', @level2type=N'COLUMN',@level2name=N'Begin_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UnpaidMSO_T1', @level2type=N'COLUMN',@level2name=N'Delinquency_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UnpaidMSO_T1', @level2type=N'COLUMN',@level2name=N'Case_IDNO'

GO
/****** Object:  Table [dbo].[UnpaidMSO_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[UnpaidMSO_T1]
GO
/****** Object:  Table [dbo].[UnpaidMSO_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UnpaidMSO_T1](
	[Case_IDNO] [numeric](6, 0) NOT NULL,
	[Delinquency_AMNT] [numeric](11, 2) NOT NULL,
	[Begin_DATE] [date] NOT NULL,
	[EventGlobalSeq_NUMB] [numeric](19, 0) NOT NULL,
 CONSTRAINT [UMSO_I1] PRIMARY KEY CLUSTERED 
(
	[Case_IDNO] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

GO
EXEC sys.sp_addextendedproperty @name=N'1', @value=N'Unique ID generated for the DECSS Case.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UnpaidMSO_T1', @level2type=N'COLUMN',@level2name=N'Case_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Cumulative unpaid MSO and Expect to Pay amount.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UnpaidMSO_T1', @level2type=N'COLUMN',@level2name=N'Delinquency_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Effective Date of Delinquency Amount.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UnpaidMSO_T1', @level2type=N'COLUMN',@level2name=N'Begin_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Global Event Sequence number of the Event that caused this transaction.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UnpaidMSO_T1', @level2type=N'COLUMN',@level2name=N'EventGlobalSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'Stores unpaid delinquency amount for the obligation created cases. Delinquency amount inculudes Unpaid MSO Amount and Unpaid Expect To Pay Amount. Delinquency amount calculation begins from the Date when the first Obligation Entered in the system, Obligation Begin Date, Credit Reporting Chain Closed Date, Case Reopened Date or whichever is maximum.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UnpaidMSO_T1'
GO
