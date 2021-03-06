USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BatchRestart_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BatchRestart_T1', @level2type=N'COLUMN',@level2name=N'RestartKey_TEXT'

GO
EXEC sys.sp_dropextendedproperty @name=N'2' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BatchRestart_T1', @level2type=N'COLUMN',@level2name=N'Run_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BatchRestart_T1', @level2type=N'COLUMN',@level2name=N'Job_ID'

GO
/****** Object:  Table [dbo].[BatchRestart_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[BatchRestart_T1]
GO
/****** Object:  Table [dbo].[BatchRestart_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[BatchRestart_T1](
	[Job_ID] [char](7) NOT NULL,
	[Run_DATE] [date] NOT NULL,
	[RestartKey_TEXT] [varchar](200) NOT NULL,
 CONSTRAINT [RSTL_I1] PRIMARY KEY CLUSTERED 
(
	[Job_ID] ASC,
	[Run_DATE] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
EXEC sys.sp_addextendedproperty @name=N'1', @value=N'This column stores unique ID associated with the Batch job.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BatchRestart_T1', @level2type=N'COLUMN',@level2name=N'Job_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'2', @value=N'This column stores the last run date of the job.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BatchRestart_T1', @level2type=N'COLUMN',@level2name=N'Run_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The restart key stores the values of one field or more fields that will be  used to restart the program from the point where it last committed.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BatchRestart_T1', @level2type=N'COLUMN',@level2name=N'RestartKey_TEXT'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'It is used to store the key values of each batches. This information is used to restart the batch.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BatchRestart_T1'
GO
