USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ScreenSearchKey_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ScreenSearchKey_T1', @level2type=N'COLUMN',@level2name=N'ScreenFunction_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ScreenSearchKey_T1', @level2type=N'COLUMN',@level2name=N'XmlSearch_TEXT'

GO
EXEC sys.sp_dropextendedproperty @name=N'3' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ScreenSearchKey_T1', @level2type=N'COLUMN',@level2name=N'Work_DTTM'

GO
EXEC sys.sp_dropextendedproperty @name=N'2' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ScreenSearchKey_T1', @level2type=N'COLUMN',@level2name=N'Worker_ID'

GO
EXEC sys.sp_dropextendedproperty @name=N'1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ScreenSearchKey_T1', @level2type=N'COLUMN',@level2name=N'Screen_ID'

GO
/****** Object:  Table [dbo].[ScreenSearchKey_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[ScreenSearchKey_T1]
GO
/****** Object:  Table [dbo].[ScreenSearchKey_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ScreenSearchKey_T1](
	[Screen_ID] [char](4) NOT NULL,
	[Worker_ID] [char](30) NOT NULL,
	[Work_DTTM] [datetime2](7) NOT NULL,
	[XmlSearch_TEXT] [varchar](4000) NOT NULL,
	[ScreenFunction_CODE] [char](10) NOT NULL,
 CONSTRAINT [SKEY_I1] PRIMARY KEY CLUSTERED 
(
	[Screen_ID] ASC,
	[Worker_ID] ASC,
	[Work_DTTM] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
EXEC sys.sp_addextendedproperty @name=N'1', @value=N'Identifies the UI screen corresponding to the sequence of navigation.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ScreenSearchKey_T1', @level2type=N'COLUMN',@level2name=N'Screen_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'2', @value=N'Identifies the DACSES worker.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ScreenSearchKey_T1', @level2type=N'COLUMN',@level2name=N'Worker_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'3', @value=N'The time at which the search performed.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ScreenSearchKey_T1', @level2type=N'COLUMN',@level2name=N'Work_DTTM'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The list of keys in xml format.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ScreenSearchKey_T1', @level2type=N'COLUMN',@level2name=N'XmlSearch_TEXT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Holds data about the individual functionality of the screen. Possible values are limited by values in SCFN table.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ScreenSearchKey_T1', @level2type=N'COLUMN',@level2name=N'ScreenFunction_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'Used to store the set of Key values used by each user for searching on the screen. This will store only the latest information for each user per screen' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ScreenSearchKey_T1'
GO
