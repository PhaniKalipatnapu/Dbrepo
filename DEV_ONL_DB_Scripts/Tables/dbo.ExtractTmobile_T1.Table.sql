USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractTmobile_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractTmobile_T1', @level2type=N'COLUMN',@level2name=N'MemberMci_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractTmobile_T1', @level2type=N'COLUMN',@level2name=N'Birth_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractTmobile_T1', @level2type=N'COLUMN',@level2name=N'MemberSsn_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractTmobile_T1', @level2type=N'COLUMN',@level2name=N'Last_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractTmobile_T1', @level2type=N'COLUMN',@level2name=N'Middle_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractTmobile_T1', @level2type=N'COLUMN',@level2name=N'First_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractTmobile_T1', @level2type=N'COLUMN',@level2name=N'FileSeq_IDNO'

GO
/****** Object:  Table [dbo].[ExtractTmobile_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[ExtractTmobile_T1]
GO
/****** Object:  Table [dbo].[ExtractTmobile_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ExtractTmobile_T1](
	[FileSeq_IDNO] [char](7) NOT NULL,
	[First_NAME] [char](15) NOT NULL,
	[Middle_NAME] [char](15) NOT NULL,
	[Last_NAME] [char](16) NOT NULL,
	[MemberSsn_NUMB] [char](9) NOT NULL,
	[Birth_DATE] [char](8) NOT NULL,
	[MemberMci_IDNO] [char](7) NOT NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'File sequence number.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractTmobile_T1', @level2type=N'COLUMN',@level2name=N'FileSeq_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Non custodial parent First Name' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractTmobile_T1', @level2type=N'COLUMN',@level2name=N'First_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Non custodial parent middle name' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractTmobile_T1', @level2type=N'COLUMN',@level2name=N'Middle_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Non custodial parent last name' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractTmobile_T1', @level2type=N'COLUMN',@level2name=N'Last_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Non custodial parent SSN number' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractTmobile_T1', @level2type=N'COLUMN',@level2name=N'MemberSsn_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Non custodial parent date of birth' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractTmobile_T1', @level2type=N'COLUMN',@level2name=N'Birth_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Last 7 digits of Non custodial parent unique ID.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractTmobile_T1', @level2type=N'COLUMN',@level2name=N'MemberMci_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'This process extracts NCPs data to create Locate requests to T-Mobile wireless. ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractTmobile_T1'
GO
