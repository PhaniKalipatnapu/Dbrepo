USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadHeaderPudm_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadHeaderPudm_T1', @level2type=N'COLUMN',@level2name=N'Process_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadHeaderPudm_T1', @level2type=N'COLUMN',@level2name=N'FileLoad_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadHeaderPudm_T1', @level2type=N'COLUMN',@level2name=N'PublicUtilityGenerated_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadHeaderPudm_T1', @level2type=N'COLUMN',@level2name=N'PublicUtilityZip_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadHeaderPudm_T1', @level2type=N'COLUMN',@level2name=N'PublicUtilityState_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadHeaderPudm_T1', @level2type=N'COLUMN',@level2name=N'PublicUtilityCity_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadHeaderPudm_T1', @level2type=N'COLUMN',@level2name=N'PublicUtilityLine1_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadHeaderPudm_T1', @level2type=N'COLUMN',@level2name=N'PublicUtility_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadHeaderPudm_T1', @level2type=N'COLUMN',@level2name=N'Fein_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadHeaderPudm_T1', @level2type=N'COLUMN',@level2name=N'Rec_ID'

GO
EXEC sys.sp_dropextendedproperty @name=N'1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadHeaderPudm_T1', @level2type=N'COLUMN',@level2name=N'Seq_IDNO'

GO
/****** Object:  Table [dbo].[LoadHeaderPudm_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[LoadHeaderPudm_T1]
GO
/****** Object:  Table [dbo].[LoadHeaderPudm_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[LoadHeaderPudm_T1](
	[Seq_IDNO] [numeric](19, 0) IDENTITY(1,1) NOT NULL,
	[Rec_ID] [char](2) NOT NULL,
	[Fein_IDNO] [char](9) NOT NULL,
	[PublicUtility_NAME] [char](40) NOT NULL,
	[PublicUtilityLine1_ADDR] [char](40) NOT NULL,
	[PublicUtilityCity_ADDR] [char](16) NOT NULL,
	[PublicUtilityState_ADDR] [char](2) NOT NULL,
	[PublicUtilityZip_ADDR] [char](9) NOT NULL,
	[PublicUtilityGenerated_DATE] [char](8) NOT NULL,
	[FileLoad_DATE] [date] NOT NULL,
	[Process_INDC] [char](1) NOT NULL,
 CONSTRAINT [LHPUD_I1] PRIMARY KEY CLUSTERED 
(
	[Seq_IDNO] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
EXEC sys.sp_addextendedproperty @name=N'1', @value=N'Identifies a record  uniquely.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadHeaderPudm_T1', @level2type=N'COLUMN',@level2name=N'Seq_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Header record type.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadHeaderPudm_T1', @level2type=N'COLUMN',@level2name=N'Rec_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies Public Utility EIN number.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadHeaderPudm_T1', @level2type=N'COLUMN',@level2name=N'Fein_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Public Utility Name.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadHeaderPudm_T1', @level2type=N'COLUMN',@level2name=N'PublicUtility_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Public Utility Line 1 address.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadHeaderPudm_T1', @level2type=N'COLUMN',@level2name=N'PublicUtilityLine1_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Public Utility City address.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadHeaderPudm_T1', @level2type=N'COLUMN',@level2name=N'PublicUtilityCity_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Public Utility State address.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadHeaderPudm_T1', @level2type=N'COLUMN',@level2name=N'PublicUtilityState_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Public Utility Zip code address.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadHeaderPudm_T1', @level2type=N'COLUMN',@level2name=N'PublicUtilityZip_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Date Public Utility created the file.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadHeaderPudm_T1', @level2type=N'COLUMN',@level2name=N'PublicUtilityGenerated_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The date on which incoming file from PUDM is loaded' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadHeaderPudm_T1', @level2type=N'COLUMN',@level2name=N'FileLoad_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the process status.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadHeaderPudm_T1', @level2type=N'COLUMN',@level2name=N'Process_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'Temporary load table contains all the agency details of locate match receieved from PUDM' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadHeaderPudm_T1'
GO
