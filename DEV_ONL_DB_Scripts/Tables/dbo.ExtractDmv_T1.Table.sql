USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractDmv_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractDmv_T1', @level2type=N'COLUMN',@level2name=N'Action_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractDmv_T1', @level2type=N'COLUMN',@level2name=N'MemberMci_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractDmv_T1', @level2type=N'COLUMN',@level2name=N'MemberSex_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractDmv_T1', @level2type=N'COLUMN',@level2name=N'MemberSsn_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractDmv_T1', @level2type=N'COLUMN',@level2name=N'LicenseNo_TEXT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractDmv_T1', @level2type=N'COLUMN',@level2name=N'Birth_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractDmv_T1', @level2type=N'COLUMN',@level2name=N'Middle_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractDmv_T1', @level2type=N'COLUMN',@level2name=N'First_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractDmv_T1', @level2type=N'COLUMN',@level2name=N'Last_NAME'

GO
/****** Object:  Table [dbo].[ExtractDmv_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[ExtractDmv_T1]
GO
/****** Object:  Table [dbo].[ExtractDmv_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ExtractDmv_T1](
	[Last_NAME] [char](12) NOT NULL,
	[First_NAME] [char](11) NOT NULL,
	[Middle_NAME] [char](1) NOT NULL,
	[Birth_DATE] [char](8) NOT NULL,
	[LicenseNo_TEXT] [char](12) NOT NULL,
	[MemberSsn_NUMB] [char](9) NOT NULL,
	[MemberSex_CODE] [char](1) NOT NULL,
	[MemberMci_IDNO] [char](10) NOT NULL,
	[Action_CODE] [char](1) NOT NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'NCP Last Name.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractDmv_T1', @level2type=N'COLUMN',@level2name=N'Last_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'NCP First Name.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractDmv_T1', @level2type=N'COLUMN',@level2name=N'First_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'NCP Middle Name.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractDmv_T1', @level2type=N'COLUMN',@level2name=N'Middle_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'NCP Date of Birth.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractDmv_T1', @level2type=N'COLUMN',@level2name=N'Birth_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Ncp license number.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractDmv_T1', @level2type=N'COLUMN',@level2name=N'LicenseNo_TEXT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'NCP social security number.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractDmv_T1', @level2type=N'COLUMN',@level2name=N'MemberSsn_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'NCP gender. ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractDmv_T1', @level2type=N'COLUMN',@level2name=N'MemberSex_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'NCP member MCI.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractDmv_T1', @level2type=N'COLUMN',@level2name=N'MemberMci_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Action Code for match, suspension or lifting of the licenses.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractDmv_T1', @level2type=N'COLUMN',@level2name=N'Action_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'Temporary  extract table contains all the DACSES NCPs eligible for match, suspension or lifting of the licenses' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractDmv_T1'
GO
