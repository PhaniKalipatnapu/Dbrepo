USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementLocateInterface_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementLocateInterface_T1', @level2type=N'COLUMN',@level2name=N'Reference_ID'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementLocateInterface_T1', @level2type=N'COLUMN',@level2name=N'TypeReference_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'7' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementLocateInterface_T1', @level2type=N'COLUMN',@level2name=N'TransactionEventSeq_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementLocateInterface_T1', @level2type=N'COLUMN',@level2name=N'Update_DTTM'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementLocateInterface_T1', @level2type=N'COLUMN',@level2name=N'WorkerUpdate_ID'

GO
EXEC sys.sp_dropextendedproperty @name=N'6' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementLocateInterface_T1', @level2type=N'COLUMN',@level2name=N'Process_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementLocateInterface_T1', @level2type=N'COLUMN',@level2name=N'Create_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementLocateInterface_T1', @level2type=N'COLUMN',@level2name=N'NegPos_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'4' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementLocateInterface_T1', @level2type=N'COLUMN',@level2name=N'OthpSource_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'5' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementLocateInterface_T1', @level2type=N'COLUMN',@level2name=N'TypeChange_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementLocateInterface_T1', @level2type=N'COLUMN',@level2name=N'Process_ID'

GO
EXEC sys.sp_dropextendedproperty @name=N'3' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementLocateInterface_T1', @level2type=N'COLUMN',@level2name=N'OrderSeq_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'2' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementLocateInterface_T1', @level2type=N'COLUMN',@level2name=N'Case_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementLocateInterface_T1', @level2type=N'COLUMN',@level2name=N'MemberMci_IDNO'

GO
/****** Object:  Index [ELFC_I1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP INDEX [ELFC_I1] ON [dbo].[EnforcementLocateInterface_T1] WITH ( ONLINE = OFF )
GO
/****** Object:  Table [dbo].[EnforcementLocateInterface_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[EnforcementLocateInterface_T1]
GO
/****** Object:  Table [dbo].[EnforcementLocateInterface_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[EnforcementLocateInterface_T1](
	[MemberMci_IDNO] [numeric](10, 0) NOT NULL,
	[Case_IDNO] [numeric](6, 0) NOT NULL,
	[OrderSeq_NUMB] [numeric](2, 0) NOT NULL,
	[Process_ID] [char](10) NOT NULL,
	[TypeChange_CODE] [char](2) NOT NULL,
	[OthpSource_IDNO] [numeric](10, 0) NOT NULL,
	[NegPos_CODE] [char](1) NOT NULL,
	[Create_DATE] [date] NOT NULL,
	[Process_DATE] [date] NOT NULL,
	[WorkerUpdate_ID] [char](30) NOT NULL,
	[Update_DTTM] [datetime2](7) NOT NULL,
	[TransactionEventSeq_NUMB] [numeric](19, 0) NOT NULL,
	[TypeReference_CODE] [char](5) NOT NULL,
	[Reference_ID] [char](30) NOT NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [ELFC_I1]    Script Date: 4/7/2015 12:53:07 PM ******/
CREATE CLUSTERED INDEX [ELFC_I1] ON [dbo].[EnforcementLocateInterface_T1]
(
	[Case_IDNO] ASC,
	[MemberMci_IDNO] ASC,
	[OthpSource_IDNO] ASC,
	[Reference_ID] ASC,
	[TypeChange_CODE] ASC,
	[Process_DATE] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
EXEC sys.sp_addextendedproperty @name=N'1', @value=N'Unique number assigned by the system to identify the member.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementLocateInterface_T1', @level2type=N'COLUMN',@level2name=N'MemberMci_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'2', @value=N'The Case ID of the Participant.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementLocateInterface_T1', @level2type=N'COLUMN',@level2name=N'Case_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'3', @value=N'This is a system generated internal order sequence number created for a support order for a given case.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementLocateInterface_T1', @level2type=N'COLUMN',@level2name=N'OrderSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the process ID that inserts a record into this table.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementLocateInterface_T1', @level2type=N'COLUMN',@level2name=N'Process_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'5', @value=N'Indicates the type of change that initiates either a remedy to be opened or closing it for a given case/order. Values are obtained from REFM (COMP/STAT).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementLocateInterface_T1', @level2type=N'COLUMN',@level2name=N'TypeChange_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'4', @value=N'Stores the Other party ID to which this record is linked to.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementLocateInterface_T1', @level2type=N'COLUMN',@level2name=N'OthpSource_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the value P - Positive or N - Negative. If value is P, then remedy has to be initiated. If value = N, then it has to be closed. Values are obtained from REFM (FMIS/SERE).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementLocateInterface_T1', @level2type=N'COLUMN',@level2name=N'NegPos_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the actual date on which this record is created.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementLocateInterface_T1', @level2type=N'COLUMN',@level2name=N'Create_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'6', @value=N'Stores the effective date on which this record is processed by the Enforcement program.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementLocateInterface_T1', @level2type=N'COLUMN',@level2name=N'Process_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the worker ID who created/modified this record.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementLocateInterface_T1', @level2type=N'COLUMN',@level2name=N'WorkerUpdate_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the effective Date with Time at which this record was inserted / modified in this table.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementLocateInterface_T1', @level2type=N'COLUMN',@level2name=N'Update_DTTM'
GO
EXEC sys.sp_addextendedproperty @name=N'7', @value=N'Unique Sequence Number that will be generated for a Transaction on the Table. This field is used for checking concurrency at the time of online transaction updates.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementLocateInterface_T1', @level2type=N'COLUMN',@level2name=N'TransactionEventSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'To hold the type of reference. Values are obtained from REFM (AMJR_V1.ActivityMajor_CODE/RFTP). EX: LSNR/RFTP, CSLN/RFTP' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementLocateInterface_T1', @level2type=N'COLUMN',@level2name=N'TypeReference_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'To hold the reference number.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementLocateInterface_T1', @level2type=N'COLUMN',@level2name=N'Reference_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'This table stores the information of a case that are eligible for initiating an enforcement remedy automatically on a case that were triggered by various events / programs in the system on a daily basis. This information will be then processed by the nightly batch ELFC batch program. The status reflects the current position of the action taken.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementLocateInterface_T1'
GO
