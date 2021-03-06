USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractDfw_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractDfw_T1', @level2type=N'COLUMN',@level2name=N'SupLiftRequest_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractDfw_T1', @level2type=N'COLUMN',@level2name=N'Middle_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractDfw_T1', @level2type=N'COLUMN',@level2name=N'Last_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractDfw_T1', @level2type=N'COLUMN',@level2name=N'First_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractDfw_T1', @level2type=N'COLUMN',@level2name=N'MemberMci_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractDfw_T1', @level2type=N'COLUMN',@level2name=N'LicenseNo_TEXT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractDfw_T1', @level2type=N'COLUMN',@level2name=N'TypeLicense_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractDfw_T1', @level2type=N'COLUMN',@level2name=N'MemberSsn_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractDfw_T1', @level2type=N'COLUMN',@level2name=N'Action_CODE'

GO
/****** Object:  Table [dbo].[ExtractDfw_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[ExtractDfw_T1]
GO
/****** Object:  Table [dbo].[ExtractDfw_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ExtractDfw_T1](
	[Action_CODE] [char](1) NOT NULL,
	[MemberSsn_NUMB] [char](9) NOT NULL,
	[TypeLicense_CODE] [char](3) NOT NULL,
	[LicenseNo_TEXT] [char](20) NOT NULL,
	[MemberMci_IDNO] [char](10) NOT NULL,
	[First_NAME] [char](20) NOT NULL,
	[Last_NAME] [char](20) NOT NULL,
	[Middle_NAME] [char](1) NOT NULL,
	[SupLiftRequest_DATE] [char](8) NOT NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N' Indicates if a Suspension or a request to lift the suspension is being requested' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractDfw_T1', @level2type=N'COLUMN',@level2name=N'Action_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Dfw Member SSN' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractDfw_T1', @level2type=N'COLUMN',@level2name=N'MemberSsn_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Dfw License Type' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractDfw_T1', @level2type=N'COLUMN',@level2name=N'TypeLicense_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Dfw License Number' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractDfw_T1', @level2type=N'COLUMN',@level2name=N'LicenseNo_TEXT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'NCP Member Mci Idno' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractDfw_T1', @level2type=N'COLUMN',@level2name=N'MemberMci_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Ncp First Name' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractDfw_T1', @level2type=N'COLUMN',@level2name=N'First_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Ncp Last Name' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractDfw_T1', @level2type=N'COLUMN',@level2name=N'Last_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Ncp Middle Name' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractDfw_T1', @level2type=N'COLUMN',@level2name=N'Middle_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N' DOR license suspension lift request date from DECSS for the NCP' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractDfw_T1', @level2type=N'COLUMN',@level2name=N'SupLiftRequest_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'Extract Ncp  License Details for Suspension Or Lift' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractDfw_T1'
GO
