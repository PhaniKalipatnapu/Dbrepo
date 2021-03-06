USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CpApplicationFee_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CpApplicationFee_T1', @level2type=N'COLUMN',@level2name=N'EndValidity_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CpApplicationFee_T1', @level2type=N'COLUMN',@level2name=N'BeginValidity_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'2' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CpApplicationFee_T1', @level2type=N'COLUMN',@level2name=N'TransactionEventSeq_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CpApplicationFee_T1', @level2type=N'COLUMN',@level2name=N'FeeCheckNo_TEXT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CpApplicationFee_T1', @level2type=N'COLUMN',@level2name=N'DescriptionReason_TEXT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CpApplicationFee_T1', @level2type=N'COLUMN',@level2name=N'Waived_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CpApplicationFee_T1', @level2type=N'COLUMN',@level2name=N'Paid_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CpApplicationFee_T1', @level2type=N'COLUMN',@level2name=N'Assessed_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CpApplicationFee_T1', @level2type=N'COLUMN',@level2name=N'Case_IDNO'

GO
/****** Object:  Table [dbo].[CpApplicationFee_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[CpApplicationFee_T1]
GO
/****** Object:  Table [dbo].[CpApplicationFee_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[CpApplicationFee_T1](
	[Case_IDNO] [numeric](6, 0) NOT NULL,
	[Assessed_AMNT] [numeric](11, 2) NOT NULL,
	[Paid_AMNT] [numeric](11, 2) NOT NULL,
	[Waived_AMNT] [numeric](11, 2) NOT NULL,
	[DescriptionReason_TEXT] [varchar](70) NOT NULL,
	[FeeCheckNo_TEXT] [char](20) NOT NULL,
	[TransactionEventSeq_NUMB] [numeric](19, 0) NOT NULL,
	[BeginValidity_DATE] [date] NOT NULL,
	[EndValidity_DATE] [date] NOT NULL,
 CONSTRAINT [CPAF_I1] PRIMARY KEY CLUSTERED 
(
	[Case_IDNO] ASC,
	[TransactionEventSeq_NUMB] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
EXEC sys.sp_addextendedproperty @name=N'1', @value=N'Unique ID generated for the DECSS Case.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CpApplicationFee_T1', @level2type=N'COLUMN',@level2name=N'Case_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This is the Amount assessed.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CpApplicationFee_T1', @level2type=N'COLUMN',@level2name=N'Assessed_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This is the total amount Paid.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CpApplicationFee_T1', @level2type=N'COLUMN',@level2name=N'Paid_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This is to show the Amount waived towards CP Fee during this transaction.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CpApplicationFee_T1', @level2type=N'COLUMN',@level2name=N'Waived_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This is the Reason of the transaction.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CpApplicationFee_T1', @level2type=N'COLUMN',@level2name=N'DescriptionReason_TEXT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Check or money order number of the IV-D application fee.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CpApplicationFee_T1', @level2type=N'COLUMN',@level2name=N'FeeCheckNo_TEXT'
GO
EXEC sys.sp_addextendedproperty @name=N'2', @value=N'Unique Sequence Number that will be generated for a given Transaction on the Table. This field is used for checking concurrency at the time of online transaction updates.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CpApplicationFee_T1', @level2type=N'COLUMN',@level2name=N'TransactionEventSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The Effective date from when the Changed Information is valid.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CpApplicationFee_T1', @level2type=N'COLUMN',@level2name=N'BeginValidity_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The Effective date up to which the Changed Information is valid.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CpApplicationFee_T1', @level2type=N'COLUMN',@level2name=N'EndValidity_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'This is a log table stores the CP application fee amount.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CpApplicationFee_T1'
GO
