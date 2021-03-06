USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ScreenSearchKeyHist_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ScreenSearchKeyHist_T1', @level2type=N'COLUMN',@level2name=N'ScreenFunction_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ScreenSearchKeyHist_T1', @level2type=N'COLUMN',@level2name=N'XmlSearch_TEXT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ScreenSearchKeyHist_T1', @level2type=N'COLUMN',@level2name=N'Work_DTTM'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ScreenSearchKeyHist_T1', @level2type=N'COLUMN',@level2name=N'Worker_ID'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ScreenSearchKeyHist_T1', @level2type=N'COLUMN',@level2name=N'Screen_ID'

GO
/****** Object:  Table [dbo].[ScreenSearchKeyHist_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[ScreenSearchKeyHist_T1]
GO
/****** Object:  Table [dbo].[ScreenSearchKeyHist_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ScreenSearchKeyHist_T1](
	[Screen_ID] [char](4) NOT NULL,
	[Worker_ID] [char](30) NOT NULL,
	[Work_DTTM] [datetime2](7) NOT NULL,
	[XmlSearch_TEXT] [varchar](4000) NOT NULL,
	[ScreenFunction_CODE] [char](10) NOT NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the UI screen corresponding to the sequence of navigation.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ScreenSearchKeyHist_T1', @level2type=N'COLUMN',@level2name=N'Screen_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the DACSES worker.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ScreenSearchKeyHist_T1', @level2type=N'COLUMN',@level2name=N'Worker_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The time at which the search performed.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ScreenSearchKeyHist_T1', @level2type=N'COLUMN',@level2name=N'Work_DTTM'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The list of keys in xml format.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ScreenSearchKeyHist_T1', @level2type=N'COLUMN',@level2name=N'XmlSearch_TEXT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Holds data about the individual functionality of the screen. Possible values are limited by values in SCFN table.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ScreenSearchKeyHist_T1', @level2type=N'COLUMN',@level2name=N'ScreenFunction_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'All the history information of the screen search is stored in this table' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ScreenSearchKeyHist_T1'
GO
