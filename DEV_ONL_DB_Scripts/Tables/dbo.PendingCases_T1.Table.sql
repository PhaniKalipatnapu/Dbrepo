USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingCases_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingCases_T1', @level2type=N'COLUMN',@level2name=N'Update_DTTM'

GO
EXEC sys.sp_dropextendedproperty @name=N'2' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingCases_T1', @level2type=N'COLUMN',@level2name=N'TransactionEventSeq_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingCases_T1', @level2type=N'COLUMN',@level2name=N'WorkerUpdate_ID'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingCases_T1', @level2type=N'COLUMN',@level2name=N'EndValidity_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingCases_T1', @level2type=N'COLUMN',@level2name=N'BeginValidity_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingCases_T1', @level2type=N'COLUMN',@level2name=N'StatusIvaCase_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingCases_T1', @level2type=N'COLUMN',@level2name=N'StatusIvaCase_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingCases_T1', @level2type=N'COLUMN',@level2name=N'Grantee_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingCases_T1', @level2type=N'COLUMN',@level2name=N'TypePending_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingCases_T1', @level2type=N'COLUMN',@level2name=N'Create_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingCases_T1', @level2type=N'COLUMN',@level2name=N'County_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingCases_T1', @level2type=N'COLUMN',@level2name=N'IvaCase_ID'

GO
/****** Object:  Table [dbo].[PendingCases_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[PendingCases_T1]
GO
/****** Object:  Table [dbo].[PendingCases_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[PendingCases_T1](
	[IvaCase_ID] [char](10) NOT NULL,
	[County_IDNO] [numeric](3, 0) NOT NULL,
	[Create_DATE] [date] NOT NULL,
	[TypePending_CODE] [char](2) NOT NULL,
	[Grantee_NAME] [char](20) NOT NULL,
	[StatusIvaCase_CODE] [char](1) NOT NULL,
	[StatusIvaCase_DATE] [date] NOT NULL,
	[BeginValidity_DATE] [date] NOT NULL,
	[EndValidity_DATE] [date] NOT NULL,
	[WorkerUpdate_ID] [char](30) NOT NULL,
	[TransactionEventSeq_NUMB] [numeric](19, 0) NOT NULL,
	[Update_DTTM] [datetime2](7) NOT NULL,
 CONSTRAINT [PNCS_I1] PRIMARY KEY CLUSTERED 
(
	[IvaCase_ID] ASC,
	[TransactionEventSeq_NUMB] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
EXEC sys.sp_addextendedproperty @name=N'1', @value=N'Indicates the IVA Case ID for the Pending Case.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingCases_T1', @level2type=N'COLUMN',@level2name=N'IvaCase_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the County Indicates the County in which the Pending Case is created.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingCases_T1', @level2type=N'COLUMN',@level2name=N'County_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the Date on which the records were created.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingCases_T1', @level2type=N'COLUMN',@level2name=N'Create_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the Pending type. Values to be determined in the subsequent Technical designs.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingCases_T1', @level2type=N'COLUMN',@level2name=N'TypePending_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the IVA grantee name.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingCases_T1', @level2type=N'COLUMN',@level2name=N'Grantee_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the IVA Case Status. Values are obtained from REFM (CSTS/CSTS).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingCases_T1', @level2type=N'COLUMN',@level2name=N'StatusIvaCase_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the IVA Case Date.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingCases_T1', @level2type=N'COLUMN',@level2name=N'StatusIvaCase_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The Effective date from when the Changed Information Will is Valid.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingCases_T1', @level2type=N'COLUMN',@level2name=N'BeginValidity_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The Effective date up to which the Changed Information will be Valid.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingCases_T1', @level2type=N'COLUMN',@level2name=N'EndValidity_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the worker ID who created/modified this record.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingCases_T1', @level2type=N'COLUMN',@level2name=N'WorkerUpdate_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'2', @value=N'Unique Sequence Number that will be generated for any given transaction on the Table. This field is used for checking concurrency at the time of online transaction updates.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingCases_T1', @level2type=N'COLUMN',@level2name=N'TransactionEventSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the effective Date with Time at which this record was inserted / modified in this table.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingCases_T1', @level2type=N'COLUMN',@level2name=N'Update_DTTM'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'This table is used to store the information about the pending cases due to insufficient information or wrong data. This table stores valid records as well as history records which follows the temporal model structure.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingCases_T1'
GO
