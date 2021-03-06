USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadGtstResults_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadGtstResults_T1', @level2type=N'COLUMN',@level2name=N'Update_DTTM'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadGtstResults_T1', @level2type=N'COLUMN',@level2name=N'Run_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadGtstResults_T1', @level2type=N'COLUMN',@level2name=N'Process_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadGtstResults_T1', @level2type=N'COLUMN',@level2name=N'File_ID'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadGtstResults_T1', @level2type=N'COLUMN',@level2name=N'Probability_PCT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadGtstResults_T1', @level2type=N'COLUMN',@level2name=N'ResultsReceived_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadGtstResults_T1', @level2type=N'COLUMN',@level2name=N'ChildMiddle_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadGtstResults_T1', @level2type=N'COLUMN',@level2name=N'ChildLast_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadGtstResults_T1', @level2type=N'COLUMN',@level2name=N'ChildFirst_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadGtstResults_T1', @level2type=N'COLUMN',@level2name=N'MiddleFather_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadGtstResults_T1', @level2type=N'COLUMN',@level2name=N'LastFather_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadGtstResults_T1', @level2type=N'COLUMN',@level2name=N'FirstFather_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadGtstResults_T1', @level2type=N'COLUMN',@level2name=N'MiddleMother_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadGtstResults_T1', @level2type=N'COLUMN',@level2name=N'LastMother_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadGtstResults_T1', @level2type=N'COLUMN',@level2name=N'FirstMother_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadGtstResults_T1', @level2type=N'COLUMN',@level2name=N'Case_IDNO'

GO
/****** Object:  Table [dbo].[LoadGtstResults_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[LoadGtstResults_T1]
GO
/****** Object:  Table [dbo].[LoadGtstResults_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[LoadGtstResults_T1](
	[Seq_IDNO] [numeric](19, 0) IDENTITY(1,1) NOT NULL,
	[Case_IDNO] [char](11) NOT NULL,
	[FirstMother_NAME] [char](15) NOT NULL,
	[LastMother_NAME] [char](20) NOT NULL,
	[MiddleMother_NAME] [char](20) NOT NULL,
	[FirstFather_NAME] [char](15) NOT NULL,
	[LastFather_NAME] [char](20) NOT NULL,
	[MiddleFather_NAME] [char](20) NOT NULL,
	[ChildFirst_NAME] [char](15) NOT NULL,
	[ChildLast_NAME] [char](20) NOT NULL,
	[ChildMiddle_NAME] [char](20) NOT NULL,
	[ResultsReceived_DATE] [date] NOT NULL,
	[Probability_PCT] [numeric](5, 2) NOT NULL,
	[File_ID] [char](15) NOT NULL,
	[Process_INDC] [char](1) NOT NULL,
	[Run_DATE] [date] NOT NULL,
	[Update_DTTM] [datetime2](7) NOT NULL,
 CONSTRAINT [LGRES_I1] PRIMARY KEY CLUSTERED 
(
	[Seq_IDNO] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the Case ID associated with the member for which results are sent.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadGtstResults_T1', @level2type=N'COLUMN',@level2name=N'Case_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the first name of the mother.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadGtstResults_T1', @level2type=N'COLUMN',@level2name=N'FirstMother_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the last name of the mother.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadGtstResults_T1', @level2type=N'COLUMN',@level2name=N'LastMother_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the middle name of the mother.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadGtstResults_T1', @level2type=N'COLUMN',@level2name=N'MiddleMother_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the first name of the father.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadGtstResults_T1', @level2type=N'COLUMN',@level2name=N'FirstFather_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the last name of the father.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadGtstResults_T1', @level2type=N'COLUMN',@level2name=N'LastFather_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the middle name of the father.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadGtstResults_T1', @level2type=N'COLUMN',@level2name=N'MiddleFather_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the first name of the dependent.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadGtstResults_T1', @level2type=N'COLUMN',@level2name=N'ChildFirst_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the last name of the dependent.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadGtstResults_T1', @level2type=N'COLUMN',@level2name=N'ChildLast_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the middle name of the dependent.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadGtstResults_T1', @level2type=N'COLUMN',@level2name=N'ChildMiddle_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the date result received.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadGtstResults_T1', @level2type=N'COLUMN',@level2name=N'ResultsReceived_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the probability of the result.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadGtstResults_T1', @level2type=N'COLUMN',@level2name=N'Probability_PCT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the Docket ID associated with the case for which results are sent.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadGtstResults_T1', @level2type=N'COLUMN',@level2name=N'File_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates Y if record processed otherwise N.Default will be N' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadGtstResults_T1', @level2type=N'COLUMN',@level2name=N'Process_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'identifies the date on which this record was processed.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadGtstResults_T1', @level2type=N'COLUMN',@level2name=N'Run_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'identifies the date on which this record was inserted.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadGtstResults_T1', @level2type=N'COLUMN',@level2name=N'Update_DTTM'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'This table is used in BATCH_EST_GEN_TEST to load the orchid test restult into DACSES.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadGtstResults_T1'
GO
