USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIvaChildrenUpdates_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIvaChildrenUpdates_T1', @level2type=N'COLUMN',@level2name=N'Process_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIvaChildrenUpdates_T1', @level2type=N'COLUMN',@level2name=N'Load_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIvaChildrenUpdates_T1', @level2type=N'COLUMN',@level2name=N'Image_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIvaChildrenUpdates_T1', @level2type=N'COLUMN',@level2name=N'County_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIvaChildrenUpdates_T1', @level2type=N'COLUMN',@level2name=N'Batch_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIvaChildrenUpdates_T1', @level2type=N'COLUMN',@level2name=N'Ethnic_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIvaChildrenUpdates_T1', @level2type=N'COLUMN',@level2name=N'ChildUnmatched_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIvaChildrenUpdates_T1', @level2type=N'COLUMN',@level2name=N'Unmatched_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIvaChildrenUpdates_T1', @level2type=N'COLUMN',@level2name=N'GoodCause_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIvaChildrenUpdates_T1', @level2type=N'COLUMN',@level2name=N'AdolescentParent_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIvaChildrenUpdates_T1', @level2type=N'COLUMN',@level2name=N'ReasonRemoved_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIvaChildrenUpdates_T1', @level2type=N'COLUMN',@level2name=N'AddedRem_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIvaChildrenUpdates_T1', @level2type=N'COLUMN',@level2name=N'MemberAddedRemoved_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIvaChildrenUpdates_T1', @level2type=N'COLUMN',@level2name=N'Segment_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIvaChildrenUpdates_T1', @level2type=N'COLUMN',@level2name=N'Person1_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIvaChildrenUpdates_T1', @level2type=N'COLUMN',@level2name=N'MemberMci_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIvaChildrenUpdates_T1', @level2type=N'COLUMN',@level2name=N'Birth_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIvaChildrenUpdates_T1', @level2type=N'COLUMN',@level2name=N'MemberSex_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIvaChildrenUpdates_T1', @level2type=N'COLUMN',@level2name=N'MemberRace_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIvaChildrenUpdates_T1', @level2type=N'COLUMN',@level2name=N'Middle_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIvaChildrenUpdates_T1', @level2type=N'COLUMN',@level2name=N'First_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIvaChildrenUpdates_T1', @level2type=N'COLUMN',@level2name=N'Last_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIvaChildrenUpdates_T1', @level2type=N'COLUMN',@level2name=N'MemberSsn_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIvaChildrenUpdates_T1', @level2type=N'COLUMN',@level2name=N'Person_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIvaChildrenUpdates_T1', @level2type=N'COLUMN',@level2name=N'Record_ID'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIvaChildrenUpdates_T1', @level2type=N'COLUMN',@level2name=N'CaseWelfare_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIvaChildrenUpdates_T1', @level2type=N'COLUMN',@level2name=N'Trans_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIvaChildrenUpdates_T1', @level2type=N'COLUMN',@level2name=N'Run_NUMB'

GO
/****** Object:  Table [dbo].[LoadIvaChildrenUpdates_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[LoadIvaChildrenUpdates_T1]
GO
/****** Object:  Table [dbo].[LoadIvaChildrenUpdates_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[LoadIvaChildrenUpdates_T1](
	[Seq_IDNO] [numeric](19, 0) IDENTITY(1,1) NOT NULL,
	[Run_NUMB] [char](2) NOT NULL,
	[Trans_CODE] [char](3) NOT NULL,
	[CaseWelfare_IDNO] [char](10) NOT NULL,
	[Record_ID] [char](2) NOT NULL,
	[Person_CODE] [char](1) NOT NULL,
	[MemberSsn_NUMB] [char](9) NOT NULL,
	[Last_NAME] [char](12) NOT NULL,
	[First_NAME] [char](9) NOT NULL,
	[Middle_NAME] [char](1) NOT NULL,
	[MemberRace_CODE] [char](1) NOT NULL,
	[MemberSex_CODE] [char](1) NOT NULL,
	[Birth_DATE] [char](8) NOT NULL,
	[MemberMci_IDNO] [char](8) NOT NULL,
	[Person1_CODE] [char](1) NOT NULL,
	[Segment_CODE] [char](2) NOT NULL,
	[MemberAddedRemoved_CODE] [char](1) NOT NULL,
	[AddedRem_DATE] [char](8) NOT NULL,
	[ReasonRemoved_CODE] [char](2) NOT NULL,
	[AdolescentParent_CODE] [char](2) NOT NULL,
	[GoodCause_CODE] [char](2) NOT NULL,
	[Unmatched_DATE] [char](8) NOT NULL,
	[ChildUnmatched_INDC] [char](1) NOT NULL,
	[Ethnic_CODE] [char](1) NOT NULL,
	[Batch_NUMB] [char](7) NOT NULL,
	[County_IDNO] [char](2) NOT NULL,
	[Image_CODE] [char](1) NOT NULL,
	[Load_DATE] [date] NOT NULL,
	[FileLoad_DATE] [date] NOT NULL,
	[Process_INDC] [char](1) NOT NULL,
 CONSTRAINT [LCHLD_I1] PRIMARY KEY CLUSTERED 
(
	[Seq_IDNO] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the Run No.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIvaChildrenUpdates_T1', @level2type=N'COLUMN',@level2name=N'Run_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the Transaction Code.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIvaChildrenUpdates_T1', @level2type=N'COLUMN',@level2name=N'Trans_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the IVA case Number.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIvaChildrenUpdates_T1', @level2type=N'COLUMN',@level2name=N'CaseWelfare_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the Record Code.40 for Case record,41 for CP record, and 42 for Child record.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIvaChildrenUpdates_T1', @level2type=N'COLUMN',@level2name=N'Record_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the Person Code.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIvaChildrenUpdates_T1', @level2type=N'COLUMN',@level2name=N'Person_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the Social Security Number of Child.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIvaChildrenUpdates_T1', @level2type=N'COLUMN',@level2name=N'MemberSsn_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the Last Name of the Child.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIvaChildrenUpdates_T1', @level2type=N'COLUMN',@level2name=N'Last_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the First Name of the Child.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIvaChildrenUpdates_T1', @level2type=N'COLUMN',@level2name=N'First_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the Middle Name of the Child.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIvaChildrenUpdates_T1', @level2type=N'COLUMN',@level2name=N'Middle_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the Race of the Child.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIvaChildrenUpdates_T1', @level2type=N'COLUMN',@level2name=N'MemberRace_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the Gender of the Child.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIvaChildrenUpdates_T1', @level2type=N'COLUMN',@level2name=N'MemberSex_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the Date of Birth of the Child.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIvaChildrenUpdates_T1', @level2type=N'COLUMN',@level2name=N'Birth_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the Department Client Number. Unique identifier for the member.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIvaChildrenUpdates_T1', @level2type=N'COLUMN',@level2name=N'MemberMci_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the Person Code.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIvaChildrenUpdates_T1', @level2type=N'COLUMN',@level2name=N'Person1_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the status of the members.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIvaChildrenUpdates_T1', @level2type=N'COLUMN',@level2name=N'Segment_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the Member Add REM Indicator.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIvaChildrenUpdates_T1', @level2type=N'COLUMN',@level2name=N'MemberAddedRemoved_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the REM Added Date.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIvaChildrenUpdates_T1', @level2type=N'COLUMN',@level2name=N'AddedRem_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the Removed Reason Code.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIvaChildrenUpdates_T1', @level2type=N'COLUMN',@level2name=N'ReasonRemoved_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the Adolescent Parent Code.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIvaChildrenUpdates_T1', @level2type=N'COLUMN',@level2name=N'AdolescentParent_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the Good Cause Indicator.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIvaChildrenUpdates_T1', @level2type=N'COLUMN',@level2name=N'GoodCause_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the unmatched indicator.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIvaChildrenUpdates_T1', @level2type=N'COLUMN',@level2name=N'Unmatched_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the unmatched indicator. ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIvaChildrenUpdates_T1', @level2type=N'COLUMN',@level2name=N'ChildUnmatched_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the Ethnic Code.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIvaChildrenUpdates_T1', @level2type=N'COLUMN',@level2name=N'Ethnic_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the Batch Number.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIvaChildrenUpdates_T1', @level2type=N'COLUMN',@level2name=N'Batch_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the County Code.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIvaChildrenUpdates_T1', @level2type=N'COLUMN',@level2name=N'County_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the Image Code.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIvaChildrenUpdates_T1', @level2type=N'COLUMN',@level2name=N'Image_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the Load Date.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIvaChildrenUpdates_T1', @level2type=N'COLUMN',@level2name=N'Load_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the process indicator. ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIvaChildrenUpdates_T1', @level2type=N'COLUMN',@level2name=N'Process_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'It is used to store the Children details from the IVA Update file. This staging table is used in BATCH_FIN_IVA_UPDATES.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIvaChildrenUpdates_T1'
GO
