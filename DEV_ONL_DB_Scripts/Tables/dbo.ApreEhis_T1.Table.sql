USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ApreEhis_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ApreEhis_T1', @level2type=N'COLUMN',@level2name=N'MemberAddress_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ApreEhis_T1', @level2type=N'COLUMN',@level2name=N'EmployerAddressAsOf_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ApreEhis_T1', @level2type=N'COLUMN',@level2name=N'TypeOccupation_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'4' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ApreEhis_T1', @level2type=N'COLUMN',@level2name=N'TransactionEventSeq_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ApreEhis_T1', @level2type=N'COLUMN',@level2name=N'WorkerUpdate_ID'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ApreEhis_T1', @level2type=N'COLUMN',@level2name=N'Update_DTTM'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ApreEhis_T1', @level2type=N'COLUMN',@level2name=N'EndValidity_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ApreEhis_T1', @level2type=N'COLUMN',@level2name=N'BeginValidity_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ApreEhis_T1', @level2type=N'COLUMN',@level2name=N'ContactWork_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ApreEhis_T1', @level2type=N'COLUMN',@level2name=N'EndEmployment_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ApreEhis_T1', @level2type=N'COLUMN',@level2name=N'BeginEmployment_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ApreEhis_T1', @level2type=N'COLUMN',@level2name=N'IncomeGross_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ApreEhis_T1', @level2type=N'COLUMN',@level2name=N'TypeIncome_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ApreEhis_T1', @level2type=N'COLUMN',@level2name=N'FreqIncome_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'3' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ApreEhis_T1', @level2type=N'COLUMN',@level2name=N'OthpEmpl_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'2' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ApreEhis_T1', @level2type=N'COLUMN',@level2name=N'MemberMci_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ApreEhis_T1', @level2type=N'COLUMN',@level2name=N'Application_IDNO'

GO
/****** Object:  Table [dbo].[ApreEhis_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[ApreEhis_T1]
GO
/****** Object:  Table [dbo].[ApreEhis_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ApreEhis_T1](
	[Application_IDNO] [numeric](15, 0) NOT NULL,
	[MemberMci_IDNO] [numeric](10, 0) NOT NULL,
	[OthpEmpl_IDNO] [numeric](9, 0) NOT NULL,
	[FreqIncome_CODE] [char](1) NOT NULL,
	[TypeIncome_CODE] [char](2) NOT NULL,
	[IncomeGross_AMNT] [numeric](11, 2) NOT NULL,
	[BeginEmployment_DATE] [date] NOT NULL,
	[EndEmployment_DATE] [date] NOT NULL,
	[ContactWork_INDC] [char](1) NOT NULL,
	[BeginValidity_DATE] [date] NOT NULL,
	[EndValidity_DATE] [date] NOT NULL,
	[Update_DTTM] [datetime2](7) NOT NULL,
	[WorkerUpdate_ID] [char](30) NOT NULL,
	[TransactionEventSeq_NUMB] [numeric](19, 0) NOT NULL,
	[TypeOccupation_CODE] [char](3) NOT NULL,
	[EmployerAddressAsOf_DATE] [date] NOT NULL,
	[MemberAddress_CODE] [char](1) NOT NULL,
 CONSTRAINT [APEH_I1] PRIMARY KEY CLUSTERED 
(
	[Application_IDNO] ASC,
	[MemberMci_IDNO] ASC,
	[OthpEmpl_IDNO] ASC,
	[TransactionEventSeq_NUMB] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
EXEC sys.sp_addextendedproperty @name=N'1', @value=N'Unique ID Assigned to the Application.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ApreEhis_T1', @level2type=N'COLUMN',@level2name=N'Application_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'2', @value=N'Unique ID Assigned to the Member.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ApreEhis_T1', @level2type=N'COLUMN',@level2name=N'MemberMci_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'3', @value=N'Unique ID Assigned to the Employer.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ApreEhis_T1', @level2type=N'COLUMN',@level2name=N'OthpEmpl_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the Frequency at which Participant''s gross wage is paid. Values are obtained from REFM (EHIS/WAGE).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ApreEhis_T1', @level2type=N'COLUMN',@level2name=N'FreqIncome_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the Income Type of the Employer. Values are obtained from REFM (EHIS/SOIT).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ApreEhis_T1', @level2type=N'COLUMN',@level2name=N'TypeIncome_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Members Income.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ApreEhis_T1', @level2type=N'COLUMN',@level2name=N'IncomeGross_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Member Employment Begin Date.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ApreEhis_T1', @level2type=N'COLUMN',@level2name=N'BeginEmployment_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Member Employment End Date.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ApreEhis_T1', @level2type=N'COLUMN',@level2name=N'EndEmployment_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Can the Member be contacted at Work. Values are obtained from REFM (YSNO/YSNO).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ApreEhis_T1', @level2type=N'COLUMN',@level2name=N'ContactWork_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The Effective date from when the Changed Information will be  Valid.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ApreEhis_T1', @level2type=N'COLUMN',@level2name=N'BeginValidity_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The  Effective date up to which the Changed Information will be  Valid.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ApreEhis_T1', @level2type=N'COLUMN',@level2name=N'EndValidity_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the effective Date with Time at which this record was inserted / modified in this table.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ApreEhis_T1', @level2type=N'COLUMN',@level2name=N'Update_DTTM'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the worker ID who created/modified this record.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ApreEhis_T1', @level2type=N'COLUMN',@level2name=N'WorkerUpdate_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'4', @value=N'Unique Sequence Number that will be  generated for any given transaction on the Table. This field is used for checking concurrency at the time of online transaction updates.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ApreEhis_T1', @level2type=N'COLUMN',@level2name=N'TransactionEventSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the Members Occupation (Type of Work Performed). Values are obtained from REFM (DEMO/OCCT)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ApreEhis_T1', @level2type=N'COLUMN',@level2name=N'TypeOccupation_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Date that is associated with the Current and Last Known check boxes' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ApreEhis_T1', @level2type=N'COLUMN',@level2name=N'EmployerAddressAsOf_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates that the address on file is the NCP''s current or last known address.  The possible values are ''C'' - Current, or ''L'' - Last Known(Need REFM)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ApreEhis_T1', @level2type=N'COLUMN',@level2name=N'MemberAddress_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'This table stores the Clients Employer Information that was given at the time of application. This table stores valid records as well as history records which follows the temporal model structure.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ApreEhis_T1'
GO
