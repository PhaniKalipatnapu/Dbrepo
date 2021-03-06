USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractFcrCase_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractFcrCase_T1', @level2type=N'COLUMN',@level2name=N'CasePrevious_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractFcrCase_T1', @level2type=N'COLUMN',@level2name=N'UserField_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractFcrCase_T1', @level2type=N'COLUMN',@level2name=N'CountyFips_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractFcrCase_T1', @level2type=N'COLUMN',@level2name=N'Order_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractFcrCase_T1', @level2type=N'COLUMN',@level2name=N'TypeCase_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractFcrCase_T1', @level2type=N'COLUMN',@level2name=N'Case_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractFcrCase_T1', @level2type=N'COLUMN',@level2name=N'TypeAction_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractFcrCase_T1', @level2type=N'COLUMN',@level2name=N'Rec_ID'

GO
/****** Object:  Table [dbo].[ExtractFcrCase_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[ExtractFcrCase_T1]
GO
/****** Object:  Table [dbo].[ExtractFcrCase_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ExtractFcrCase_T1](
	[Rec_ID] [char](2) NOT NULL,
	[TypeAction_CODE] [char](1) NOT NULL,
	[Case_IDNO] [char](15) NOT NULL,
	[TypeCase_CODE] [char](1) NOT NULL,
	[Order_INDC] [char](1) NOT NULL,
	[CountyFips_CODE] [char](3) NOT NULL,
	[UserField_NAME] [char](15) NOT NULL,
	[CasePrevious_IDNO] [char](15) NOT NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies record identifier.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractFcrCase_T1', @level2type=N'COLUMN',@level2name=N'Rec_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies action type.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractFcrCase_T1', @level2type=N'COLUMN',@level2name=N'TypeAction_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the IVD Case ID.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractFcrCase_T1', @level2type=N'COLUMN',@level2name=N'Case_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies type of case (F-IVD or N-Non IVD).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractFcrCase_T1', @level2type=N'COLUMN',@level2name=N'TypeCase_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies Order indicator (if exists Y else N).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractFcrCase_T1', @level2type=N'COLUMN',@level2name=N'Order_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies fips county code.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractFcrCase_T1', @level2type=N'COLUMN',@level2name=N'CountyFips_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This field may be used for submitter-identifying information.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractFcrCase_T1', @level2type=N'COLUMN',@level2name=N'UserField_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This field may be used to change the Case ID for a case previously added to the FCR.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractFcrCase_T1', @level2type=N'COLUMN',@level2name=N'CasePrevious_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'This table is used as a staging table in BATCH_LOC_EXT_FCR package to extract CASE details to create FCR Request File.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractFcrCase_T1'
GO
