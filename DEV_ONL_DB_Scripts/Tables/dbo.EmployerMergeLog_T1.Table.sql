USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EmployerMergeLog_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EmployerMergeLog_T1', @level2type=N'COLUMN',@level2name=N'RowDataXml_TEXT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EmployerMergeLog_T1', @level2type=N'COLUMN',@level2name=N'Merge_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EmployerMergeLog_T1', @level2type=N'COLUMN',@level2name=N'TransactionEventSeq_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EmployerMergeLog_T1', @level2type=N'COLUMN',@level2name=N'RowsAffected_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EmployerMergeLog_T1', @level2type=N'COLUMN',@level2name=N'Table_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EmployerMergeLog_T1', @level2type=N'COLUMN',@level2name=N'OthpEmplSecondary_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EmployerMergeLog_T1', @level2type=N'COLUMN',@level2name=N'OthpEmplPrimary_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EmployerMergeLog_T1', @level2type=N'COLUMN',@level2name=N'Seq_IDNO'

GO
/****** Object:  Table [dbo].[EmployerMergeLog_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[EmployerMergeLog_T1]
GO
/****** Object:  Table [dbo].[EmployerMergeLog_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[EmployerMergeLog_T1](
	[Seq_IDNO] [numeric](19, 0) IDENTITY(1,1) NOT NULL,
	[OthpEmplPrimary_IDNO] [numeric](9, 0) NOT NULL,
	[OthpEmplSecondary_IDNO] [numeric](9, 0) NOT NULL,
	[Table_NAME] [char](10) NOT NULL,
	[RowsAffected_NUMB] [numeric](5, 0) NOT NULL,
	[TransactionEventSeq_NUMB] [numeric](19, 0) NOT NULL,
	[Merge_DATE] [date] NOT NULL,
	[RowDataXml_TEXT] [varchar](max) NOT NULL,
 CONSTRAINT [EMLG_I1] PRIMARY KEY CLUSTERED 
(
	[Seq_IDNO] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
EXEC sys.sp_addextendedproperty @name=N'1', @value=N'System assigned number to uniquely identify a record.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EmployerMergeLog_T1', @level2type=N'COLUMN',@level2name=N'Seq_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This is the Primary Employer value that will replace with the secondary Employer in all the tables that have this Employer ID.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EmployerMergeLog_T1', @level2type=N'COLUMN',@level2name=N'OthpEmplPrimary_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This is the Secondary Employer value that was replaced by the Primary Employer in all the tables that have this Employer ID as a column.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EmployerMergeLog_T1', @level2type=N'COLUMN',@level2name=N'OthpEmplSecondary_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the name of the table affected by member merge process.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EmployerMergeLog_T1', @level2type=N'COLUMN',@level2name=N'Table_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the count of records affected by member merge process in a table.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EmployerMergeLog_T1', @level2type=N'COLUMN',@level2name=N'RowsAffected_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores transaction event number that was used by the Member Merge process.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EmployerMergeLog_T1', @level2type=N'COLUMN',@level2name=N'TransactionEventSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This is the processed date of member merge request.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EmployerMergeLog_T1', @level2type=N'COLUMN',@level2name=N'Merge_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the XML format of DECSS table records affected by member merge process.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EmployerMergeLog_T1', @level2type=N'COLUMN',@level2name=N'RowDataXml_TEXT'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'This table is used to store the DECSS tables records in XML format before effected by Employer Merge Process.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EmployerMergeLog_T1'
GO
