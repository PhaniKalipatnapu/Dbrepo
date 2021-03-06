USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractFcEin_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'NULL' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractFcEin_T1', @level2type=N'COLUMN',@level2name=N'Merged_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'NULL' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractFcEin_T1', @level2type=N'COLUMN',@level2name=N'MergedOthp_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'NULL' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractFcEin_T1', @level2type=N'COLUMN',@level2name=N'DeletedOthp_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'NULL' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractFcEin_T1', @level2type=N'COLUMN',@level2name=N'MergedFein_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'NULL' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractFcEin_T1', @level2type=N'COLUMN',@level2name=N'DeletedFein_IDNO'

GO
/****** Object:  Table [dbo].[ExtractFcEin_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[ExtractFcEin_T1]
GO
/****** Object:  Table [dbo].[ExtractFcEin_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ExtractFcEin_T1](
	[DeletedFein_IDNO] [char](9) NOT NULL,
	[MergedFein_IDNO] [char](9) NOT NULL,
	[DeletedOthp_IDNO] [char](9) NOT NULL,
	[MergedOthp_IDNO] [char](9) NOT NULL,
	[Merged_INDC] [char](1) NOT NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
EXEC sys.sp_addextendedproperty @name=N'NULL', @value=N'Identifies EIN number of the company to be deleted.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractFcEin_T1', @level2type=N'COLUMN',@level2name=N'DeletedFein_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'NULL', @value=N'Identifies EIN number of the new merged company. This field is populated only if the merge indicator is set to ‘Y.’' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractFcEin_T1', @level2type=N'COLUMN',@level2name=N'MergedFein_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'NULL', @value=N'Identifies OTHP ID of the company to be deleted.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractFcEin_T1', @level2type=N'COLUMN',@level2name=N'DeletedOthp_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'NULL', @value=N'Identifies OTHP number of the new merged employer. This field is only populated if the merge indicator is set to ‘Y.’' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractFcEin_T1', @level2type=N'COLUMN',@level2name=N'MergedOthp_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'NULL', @value=N'Indicates whether Employer Merge has happened or not.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractFcEin_T1', @level2type=N'COLUMN',@level2name=N'Merged_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'To provide Family Court with the most up-to-date employer. This information will be provided to FAMIS when employer OTHP types are end dated or merged.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractFcEin_T1'
GO
