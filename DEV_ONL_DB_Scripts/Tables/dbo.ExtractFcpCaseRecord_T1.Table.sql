USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractFcpCaseRecord_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractFcpCaseRecord_T1', @level2type=N'COLUMN',@level2name=N'PetitionDocFile_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractFcpCaseRecord_T1', @level2type=N'COLUMN',@level2name=N'DecssPetitionKey_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractFcpCaseRecord_T1', @level2type=N'COLUMN',@level2name=N'IVDOutOfStateFips_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractFcpCaseRecord_T1', @level2type=N'COLUMN',@level2name=N'IVDOutOfStateRespondInit_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractFcpCaseRecord_T1', @level2type=N'COLUMN',@level2name=N'Petition_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractFcpCaseRecord_T1', @level2type=N'COLUMN',@level2name=N'County_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractFcpCaseRecord_T1', @level2type=N'COLUMN',@level2name=N'TypeCase_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractFcpCaseRecord_T1', @level2type=N'COLUMN',@level2name=N'TypePetition_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractFcpCaseRecord_T1', @level2type=N'COLUMN',@level2name=N'Case_IDNO'

GO
/****** Object:  Table [dbo].[ExtractFcpCaseRecord_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[ExtractFcpCaseRecord_T1]
GO
/****** Object:  Table [dbo].[ExtractFcpCaseRecord_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ExtractFcpCaseRecord_T1](
	[Case_IDNO] [char](6) NOT NULL,
	[TypePetition_CODE] [char](4) NOT NULL,
	[TypeCase_CODE] [char](1) NOT NULL,
	[County_IDNO] [char](3) NOT NULL,
	[Petition_IDNO] [char](7) NOT NULL,
	[IVDOutOfStateRespondInit_CODE] [char](2) NOT NULL,
	[IVDOutOfStateFips_CODE] [char](2) NOT NULL,
	[DecssPetitionKey_IDNO] [char](8) NOT NULL,
	[PetitionDocFile_NAME] [char](27) NOT NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the Cases in DAG Approved Case Petitions that are generated for the DACSES Case' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractFcpCaseRecord_T1', @level2type=N'COLUMN',@level2name=N'Case_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Type of petition that was filed at DACSES under ESTP Activity Chain.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractFcpCaseRecord_T1', @level2type=N'COLUMN',@level2name=N'TypePetition_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'IV-D case type.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractFcpCaseRecord_T1', @level2type=N'COLUMN',@level2name=N'TypeCase_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'County that owns the case.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractFcpCaseRecord_T1', @level2type=N'COLUMN',@level2name=N'County_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Petition number that had been previously filed with Family Court for the same Case ID' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractFcpCaseRecord_T1', @level2type=N'COLUMN',@level2name=N'Petition_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Intergovernmental status of the case.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractFcpCaseRecord_T1', @level2type=N'COLUMN',@level2name=N'IVDOutOfStateRespondInit_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Out of State IV-D Agency.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractFcpCaseRecord_T1', @level2type=N'COLUMN',@level2name=N'IVDOutOfStateFips_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Sequence of the major activity instance that was used to generate the outgoing referral to Family Court' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractFcpCaseRecord_T1', @level2type=N'COLUMN',@level2name=N'DecssPetitionKey_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Name of the petition document(s) being sent to the SFTP DTI server' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractFcpCaseRecord_T1', @level2type=N'COLUMN',@level2name=N'PetitionDocFile_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'Table to store all DAG approved Cases to be sent to Family Court' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractFcpCaseRecord_T1'
GO
