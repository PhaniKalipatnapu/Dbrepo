USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EmployerQuarterlyWage_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'4' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EmployerQuarterlyWage_T1', @level2type=N'COLUMN',@level2name=N'TransactionEventSeq_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EmployerQuarterlyWage_T1', @level2type=N'COLUMN',@level2name=N'Update_DTTM'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EmployerQuarterlyWage_T1', @level2type=N'COLUMN',@level2name=N'Transaction_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EmployerQuarterlyWage_T1', @level2type=N'COLUMN',@level2name=N'WorkerUpdate_ID'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EmployerQuarterlyWage_T1', @level2type=N'COLUMN',@level2name=N'Wage_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EmployerQuarterlyWage_T1', @level2type=N'COLUMN',@level2name=N'Zip_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EmployerQuarterlyWage_T1', @level2type=N'COLUMN',@level2name=N'State_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EmployerQuarterlyWage_T1', @level2type=N'COLUMN',@level2name=N'City_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EmployerQuarterlyWage_T1', @level2type=N'COLUMN',@level2name=N'Line2_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EmployerQuarterlyWage_T1', @level2type=N'COLUMN',@level2name=N'Line1_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EmployerQuarterlyWage_T1', @level2type=N'COLUMN',@level2name=N'Sein_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'3' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EmployerQuarterlyWage_T1', @level2type=N'COLUMN',@level2name=N'Fein_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EmployerQuarterlyWage_T1', @level2type=N'COLUMN',@level2name=N'MatchCode_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EmployerQuarterlyWage_T1', @level2type=N'COLUMN',@level2name=N'First_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EmployerQuarterlyWage_T1', @level2type=N'COLUMN',@level2name=N'Middle_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EmployerQuarterlyWage_T1', @level2type=N'COLUMN',@level2name=N'Last_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EmployerQuarterlyWage_T1', @level2type=N'COLUMN',@level2name=N'Employer_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EmployerQuarterlyWage_T1', @level2type=N'COLUMN',@level2name=N'MemberSsn_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'2' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EmployerQuarterlyWage_T1', @level2type=N'COLUMN',@level2name=N'YearQtr_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EmployerQuarterlyWage_T1', @level2type=N'COLUMN',@level2name=N'MemberMci_IDNO'

GO
/****** Object:  Table [dbo].[EmployerQuarterlyWage_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[EmployerQuarterlyWage_T1]
GO
/****** Object:  Table [dbo].[EmployerQuarterlyWage_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[EmployerQuarterlyWage_T1](
	[MemberMci_IDNO] [numeric](10, 0) NOT NULL,
	[YearQtr_NUMB] [numeric](5, 0) NOT NULL,
	[MemberSsn_NUMB] [numeric](9, 0) NOT NULL,
	[Employer_NAME] [varchar](60) NOT NULL,
	[Last_NAME] [char](20) NOT NULL,
	[Middle_NAME] [char](20) NOT NULL,
	[First_NAME] [char](16) NOT NULL,
	[MatchCode_DATE] [date] NOT NULL,
	[Fein_IDNO] [numeric](9, 0) NOT NULL,
	[Sein_IDNO] [numeric](12, 0) NOT NULL,
	[Line1_ADDR] [varchar](50) NOT NULL,
	[Line2_ADDR] [varchar](50) NOT NULL,
	[City_ADDR] [char](28) NOT NULL,
	[State_ADDR] [char](2) NOT NULL,
	[Zip_ADDR] [char](15) NOT NULL,
	[Wage_AMNT] [numeric](11, 2) NOT NULL,
	[WorkerUpdate_ID] [char](30) NOT NULL,
	[Transaction_DATE] [date] NOT NULL,
	[Update_DTTM] [datetime2](7) NOT NULL,
	[TransactionEventSeq_NUMB] [numeric](19, 0) NOT NULL,
 CONSTRAINT [EMQW_I1] PRIMARY KEY CLUSTERED 
(
	[MemberMci_IDNO] ASC,
	[YearQtr_NUMB] ASC,
	[Fein_IDNO] ASC,
	[TransactionEventSeq_NUMB] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
EXEC sys.sp_addextendedproperty @name=N'1', @value=N'Identifies unique id for a member in DE Data base.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EmployerQuarterlyWage_T1', @level2type=N'COLUMN',@level2name=N'MemberMci_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'2', @value=N'Identifies Year/Quarter of the Employment.   QW reporting period in NYYMM N – 1,2,3,4 quarters in the given year Required .' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EmployerQuarterlyWage_T1', @level2type=N'COLUMN',@level2name=N'YearQtr_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies member SSN.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EmployerQuarterlyWage_T1', @level2type=N'COLUMN',@level2name=N'MemberSsn_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies NCP Name Received from State DE.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EmployerQuarterlyWage_T1', @level2type=N'COLUMN',@level2name=N'Employer_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies Last name of the Member.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EmployerQuarterlyWage_T1', @level2type=N'COLUMN',@level2name=N'Last_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the Middle Name of the Member.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EmployerQuarterlyWage_T1', @level2type=N'COLUMN',@level2name=N'Middle_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies First name of the Member.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EmployerQuarterlyWage_T1', @level2type=N'COLUMN',@level2name=N'First_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies Date for Match Code.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EmployerQuarterlyWage_T1', @level2type=N'COLUMN',@level2name=N'MatchCode_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'3', @value=N'Identifies Employer Federal Identification number.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EmployerQuarterlyWage_T1', @level2type=N'COLUMN',@level2name=N'Fein_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies State employer identification number.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EmployerQuarterlyWage_T1', @level2type=N'COLUMN',@level2name=N'Sein_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies Employer Address Line 1.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EmployerQuarterlyWage_T1', @level2type=N'COLUMN',@level2name=N'Line1_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies Employer Address Line 2.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EmployerQuarterlyWage_T1', @level2type=N'COLUMN',@level2name=N'Line2_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies Employer Address City.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EmployerQuarterlyWage_T1', @level2type=N'COLUMN',@level2name=N'City_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies Employer Address State. Values are obtained from REFM (STAT/STAT).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EmployerQuarterlyWage_T1', @level2type=N'COLUMN',@level2name=N'State_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies Employer Address Zip Code.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EmployerQuarterlyWage_T1', @level2type=N'COLUMN',@level2name=N'Zip_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies Wage amount of the NCP.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EmployerQuarterlyWage_T1', @level2type=N'COLUMN',@level2name=N'Wage_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the worker ID who created/modified this record.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EmployerQuarterlyWage_T1', @level2type=N'COLUMN',@level2name=N'WorkerUpdate_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Actual Date of this Transaction performed.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EmployerQuarterlyWage_T1', @level2type=N'COLUMN',@level2name=N'Transaction_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the effective Date with Time at which this record was inserted / modified in this table.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EmployerQuarterlyWage_T1', @level2type=N'COLUMN',@level2name=N'Update_DTTM'
GO
EXEC sys.sp_addextendedproperty @name=N'4', @value=N'Unique Sequence Number that will be generated for a given Transaction on the Table. This field is used for checking concurrency at the time of online transaction updates.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EmployerQuarterlyWage_T1', @level2type=N'COLUMN',@level2name=N'TransactionEventSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'This table hold data for incoming Employer and Employer Address Details.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EmployerQuarterlyWage_T1'
GO
