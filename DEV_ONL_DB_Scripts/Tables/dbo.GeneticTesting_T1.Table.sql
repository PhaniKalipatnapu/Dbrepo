USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'GeneticTesting_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'GeneticTesting_T1', @level2type=N'COLUMN',@level2name=N'Probability_PCT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'GeneticTesting_T1', @level2type=N'COLUMN',@level2name=N'TestResult_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'GeneticTesting_T1', @level2type=N'COLUMN',@level2name=N'ResultsReceived_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'GeneticTesting_T1', @level2type=N'COLUMN',@level2name=N'TypeTest_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'GeneticTesting_T1', @level2type=N'COLUMN',@level2name=N'CountyLocation_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'GeneticTesting_T1', @level2type=N'COLUMN',@level2name=N'Location_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'GeneticTesting_T1', @level2type=N'COLUMN',@level2name=N'LocationState_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'GeneticTesting_T1', @level2type=N'COLUMN',@level2name=N'Lab_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'4' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'GeneticTesting_T1', @level2type=N'COLUMN',@level2name=N'TransactionEventSeq_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'GeneticTesting_T1', @level2type=N'COLUMN',@level2name=N'Update_DTTM'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'GeneticTesting_T1', @level2type=N'COLUMN',@level2name=N'WorkerUpdate_ID'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'GeneticTesting_T1', @level2type=N'COLUMN',@level2name=N'EndValidity_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'GeneticTesting_T1', @level2type=N'COLUMN',@level2name=N'BeginValidity_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'GeneticTesting_T1', @level2type=N'COLUMN',@level2name=N'PaidBy_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'GeneticTesting_T1', @level2type=N'COLUMN',@level2name=N'OthpLocation_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'GeneticTesting_T1', @level2type=N'COLUMN',@level2name=N'Test_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'GeneticTesting_T1', @level2type=N'COLUMN',@level2name=N'Test_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'3' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'GeneticTesting_T1', @level2type=N'COLUMN',@level2name=N'Schedule_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'2' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'GeneticTesting_T1', @level2type=N'COLUMN',@level2name=N'MemberMci_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'GeneticTesting_T1', @level2type=N'COLUMN',@level2name=N'Case_IDNO'

GO
/****** Object:  Table [dbo].[GeneticTesting_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[GeneticTesting_T1]
GO
/****** Object:  Table [dbo].[GeneticTesting_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[GeneticTesting_T1](
	[Case_IDNO] [numeric](6, 0) NOT NULL,
	[MemberMci_IDNO] [numeric](10, 0) NOT NULL,
	[Schedule_NUMB] [numeric](10, 0) NOT NULL,
	[Test_DATE] [date] NOT NULL,
	[Test_AMNT] [numeric](11, 2) NOT NULL,
	[OthpLocation_IDNO] [numeric](9, 0) NOT NULL,
	[PaidBy_NAME] [varchar](60) NOT NULL,
	[BeginValidity_DATE] [date] NOT NULL,
	[EndValidity_DATE] [date] NOT NULL,
	[WorkerUpdate_ID] [char](30) NOT NULL,
	[Update_DTTM] [datetime2](7) NOT NULL,
	[TransactionEventSeq_NUMB] [numeric](19, 0) NOT NULL,
	[Lab_NAME] [varchar](60) NOT NULL,
	[LocationState_CODE] [char](2) NOT NULL,
	[Location_NAME] [varchar](100) NOT NULL,
	[CountyLocation_IDNO] [numeric](3, 0) NOT NULL,
	[TypeTest_CODE] [char](1) NOT NULL,
	[ResultsReceived_DATE] [date] NOT NULL,
	[TestResult_CODE] [char](1) NOT NULL,
	[Probability_PCT] [numeric](5, 2) NOT NULL,
 CONSTRAINT [GTST_I1] PRIMARY KEY CLUSTERED 
(
	[Case_IDNO] ASC,
	[MemberMci_IDNO] ASC,
	[Schedule_NUMB] ASC,
	[TypeTest_CODE] ASC,
	[TestResult_CODE] ASC,
	[TransactionEventSeq_NUMB] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
EXEC sys.sp_addextendedproperty @name=N'1', @value=N'Unique ID generated for the DACSES Case.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'GeneticTesting_T1', @level2type=N'COLUMN',@level2name=N'Case_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'2', @value=N'Stores the Member ID for which the genetic test is made.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'GeneticTesting_T1', @level2type=N'COLUMN',@level2name=N'MemberMci_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'3', @value=N'Unique number that stores the genetic test number. Same test can be done multiple times.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'GeneticTesting_T1', @level2type=N'COLUMN',@level2name=N'Schedule_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The date on which the genetic test has been conducted.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'GeneticTesting_T1', @level2type=N'COLUMN',@level2name=N'Test_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Amount paid for the test.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'GeneticTesting_T1', @level2type=N'COLUMN',@level2name=N'Test_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Unique Location ID where the genetic test has been conducted.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'GeneticTesting_T1', @level2type=N'COLUMN',@level2name=N'OthpLocation_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The person who paid the amount for the test.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'GeneticTesting_T1', @level2type=N'COLUMN',@level2name=N'PaidBy_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The Effective date from when the Changed Information is Valid.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'GeneticTesting_T1', @level2type=N'COLUMN',@level2name=N'BeginValidity_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The Effective date up to which the Changed Information is Valid.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'GeneticTesting_T1', @level2type=N'COLUMN',@level2name=N'EndValidity_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the worker ID who created/modified this record.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'GeneticTesting_T1', @level2type=N'COLUMN',@level2name=N'WorkerUpdate_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the effective Date with Time at which this record was inserted / modified in this table.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'GeneticTesting_T1', @level2type=N'COLUMN',@level2name=N'Update_DTTM'
GO
EXEC sys.sp_addextendedproperty @name=N'4', @value=N'Unique Sequence Number that will be  generated for a Transaction on the Table. This field is used for checking concurrency at the time of online transaction updates.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'GeneticTesting_T1', @level2type=N'COLUMN',@level2name=N'TransactionEventSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Name of the Lab where the genetic test has been conducted.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'GeneticTesting_T1', @level2type=N'COLUMN',@level2name=N'Lab_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Name of the State where the genetic test has been conducted. Values are obtained from REFM (STAT/STAT).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'GeneticTesting_T1', @level2type=N'COLUMN',@level2name=N'LocationState_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Name of the location where the genetic test has been conducted.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'GeneticTesting_T1', @level2type=N'COLUMN',@level2name=N'Location_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The column indicates the county location for the lab. Values are obtained from REFM (STAT/STAT).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'GeneticTesting_T1', @level2type=N'COLUMN',@level2name=N'CountyLocation_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The type of Genetic test conducted. Values are obtained from REFM (GTST/TYPE).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'GeneticTesting_T1', @level2type=N'COLUMN',@level2name=N'TypeTest_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The date on which the results have received.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'GeneticTesting_T1', @level2type=N'COLUMN',@level2name=N'ResultsReceived_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The result of the Genetic test. Values are obtained from REFM (GTST/RESU).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'GeneticTesting_T1', @level2type=N'COLUMN',@level2name=N'TestResult_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The probability of the test result.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'GeneticTesting_T1', @level2type=N'COLUMN',@level2name=N'Probability_PCT'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'This table stores the name of the location where the genetic test has been conducted for the participant. This table stores valid records as well as history records which follows the temporal model structure.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'GeneticTesting_T1'
GO
