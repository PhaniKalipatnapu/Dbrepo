USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetHostErrors_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetHostErrors_T1', @level2type=N'COLUMN',@level2name=N'TransHeader_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetHostErrors_T1', @level2type=N'COLUMN',@level2name=N'Update_DTTM'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetHostErrors_T1', @level2type=N'COLUMN',@level2name=N'WorkerUpdate_ID'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetHostErrors_T1', @level2type=N'COLUMN',@level2name=N'ActionTaken_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetHostErrors_T1', @level2type=N'COLUMN',@level2name=N'DescriptionError_TEXT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetHostErrors_T1', @level2type=N'COLUMN',@level2name=N'Error_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'2' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetHostErrors_T1', @level2type=N'COLUMN',@level2name=N'Transaction_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetHostErrors_T1', @level2type=N'COLUMN',@level2name=N'Resolution_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetHostErrors_T1', @level2type=N'COLUMN',@level2name=N'Reason_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetHostErrors_T1', @level2type=N'COLUMN',@level2name=N'Function_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetHostErrors_T1', @level2type=N'COLUMN',@level2name=N'Action_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetHostErrors_T1', @level2type=N'COLUMN',@level2name=N'OutStateCase_ID'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetHostErrors_T1', @level2type=N'COLUMN',@level2name=N'Case_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'3' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetHostErrors_T1', @level2type=N'COLUMN',@level2name=N'OtherFips_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetHostErrors_T1', @level2type=N'COLUMN',@level2name=N'Fips_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'4' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetHostErrors_T1', @level2type=N'COLUMN',@level2name=N'SeqError_IDNO'

GO
/****** Object:  Table [dbo].[CsenetHostErrors_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[CsenetHostErrors_T1]
GO
/****** Object:  Table [dbo].[CsenetHostErrors_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[CsenetHostErrors_T1](
	[SeqError_IDNO] [numeric](6, 0) NOT NULL,
	[Fips_CODE] [char](7) NOT NULL,
	[OtherFips_CODE] [char](7) NOT NULL,
	[Case_IDNO] [numeric](6, 0) NOT NULL,
	[OutStateCase_ID] [char](15) NOT NULL,
	[Action_CODE] [char](1) NOT NULL,
	[Function_CODE] [char](3) NOT NULL,
	[Reason_CODE] [char](5) NOT NULL,
	[Resolution_DATE] [date] NOT NULL,
	[Transaction_DATE] [date] NOT NULL,
	[Error_CODE] [char](4) NOT NULL,
	[DescriptionError_TEXT] [varchar](41) NOT NULL,
	[ActionTaken_DATE] [date] NOT NULL,
	[WorkerUpdate_ID] [char](30) NOT NULL,
	[Update_DTTM] [datetime2](7) NOT NULL,
	[TransHeader_IDNO] [numeric](12, 0) NOT NULL,
 CONSTRAINT [CERR_I1] PRIMARY KEY CLUSTERED 
(
	[TransHeader_IDNO] ASC,
	[Transaction_DATE] ASC,
	[OtherFips_CODE] ASC,
	[SeqError_IDNO] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
EXEC sys.sp_addextendedproperty @name=N'4', @value=N'The sequential number assigned to the error by the CSENet 2000 application.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetHostErrors_T1', @level2type=N'COLUMN',@level2name=N'SeqError_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The State''s seven-digit FIPS code (their own) on the record sent by them that contained the error. Possible values are limited by values in FIPS table.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetHostErrors_T1', @level2type=N'COLUMN',@level2name=N'Fips_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'3', @value=N'The receiving, or responding, State''s seven-digit FIPS code (the State for which the transaction was intended) that contained the error. Possible values are limited by values in FIPS table.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetHostErrors_T1', @level2type=N'COLUMN',@level2name=N'OtherFips_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The originating State''s Case ID on the transaction that erred.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetHostErrors_T1', @level2type=N'COLUMN',@level2name=N'Case_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The other State''s Case ID on the transaction that erred.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetHostErrors_T1', @level2type=N'COLUMN',@level2name=N'OutStateCase_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Action code e.g., Request, Acknowledgment, etc. from the original transaction. Possible values are limited by values in CFAR table.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetHostErrors_T1', @level2type=N'COLUMN',@level2name=N'Action_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Functional Type code, e.g., ENF, PAT, LO1, etc. from the original transaction. Possible values are limited by values in CFAR table.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetHostErrors_T1', @level2type=N'COLUMN',@level2name=N'Function_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Action-Reason code, e.g., CITAX, EREXO from the original transaction. Possible values are limited by values in CFAR table.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetHostErrors_T1', @level2type=N'COLUMN',@level2name=N'Reason_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Value from the Action Resolution Date in the Transaction Header record.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetHostErrors_T1', @level2type=N'COLUMN',@level2name=N'Resolution_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'2', @value=N'Value from the Transaction Date field in the header for the record that erred.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetHostErrors_T1', @level2type=N'COLUMN',@level2name=N'Transaction_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Error Identification code that uniquely identifies each error. Values are obtained from REFM (EMSG/EMSG)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetHostErrors_T1', @level2type=N'COLUMN',@level2name=N'Error_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Error Description.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetHostErrors_T1', @level2type=N'COLUMN',@level2name=N'DescriptionError_TEXT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Date of Action Taken on the Error.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetHostErrors_T1', @level2type=N'COLUMN',@level2name=N'ActionTaken_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the worker ID who created/modified this record.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetHostErrors_T1', @level2type=N'COLUMN',@level2name=N'WorkerUpdate_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the effective Date with Time at which this record was inserted / modified in this table.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetHostErrors_T1', @level2type=N'COLUMN',@level2name=N'Update_DTTM'
GO
EXEC sys.sp_addextendedproperty @name=N'1', @value=N'Serial number of the invalid transaction record.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetHostErrors_T1', @level2type=N'COLUMN',@level2name=N'TransHeader_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'This table holds the data of Error Transactions returned by CSENET HOST' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetHostErrors_T1'
GO
