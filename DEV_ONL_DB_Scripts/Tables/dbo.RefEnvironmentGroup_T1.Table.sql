USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefEnvironmentGroup_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefEnvironmentGroup_T1', @level2type=N'COLUMN',@level2name=N'OutputPath_TEXT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefEnvironmentGroup_T1', @level2type=N'COLUMN',@level2name=N'InputPath_TEXT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefEnvironmentGroup_T1', @level2type=N'COLUMN',@level2name=N'Description_TEXT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefEnvironmentGroup_T1', @level2type=N'COLUMN',@level2name=N'Environment_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefEnvironmentGroup_T1', @level2type=N'COLUMN',@level2name=N'Database_NAME'

GO
/****** Object:  Table [dbo].[RefEnvironmentGroup_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[RefEnvironmentGroup_T1]
GO
/****** Object:  Table [dbo].[RefEnvironmentGroup_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[RefEnvironmentGroup_T1](
	[Database_NAME] [char](10) NOT NULL,
	[Environment_CODE] [char](3) NOT NULL,
	[Description_TEXT] [varchar](50) NOT NULL,
	[InputPath_TEXT] [varchar](80) NOT NULL,
	[OutputPath_TEXT] [varchar](80) NOT NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the Name of the current Database.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefEnvironmentGroup_T1', @level2type=N'COLUMN',@level2name=N'Database_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the three character associated with the current database environment DEV, CNV, PRD, TST.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefEnvironmentGroup_T1', @level2type=N'COLUMN',@level2name=N'Environment_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores significant information about the database used.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefEnvironmentGroup_T1', @level2type=N'COLUMN',@level2name=N'Description_TEXT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the oracle directory name where the inputs files will be residing.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefEnvironmentGroup_T1', @level2type=N'COLUMN',@level2name=N'InputPath_TEXT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the oracle directory name where the output files will be created.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefEnvironmentGroup_T1', @level2type=N'COLUMN',@level2name=N'OutputPath_TEXT'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'This is a reference table which has the virtual oracle directory for Input and output files.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefEnvironmentGroup_T1'
GO
