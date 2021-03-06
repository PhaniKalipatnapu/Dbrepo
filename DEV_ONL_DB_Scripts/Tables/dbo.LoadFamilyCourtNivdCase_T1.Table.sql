USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFamilyCourtNivdCase_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFamilyCourtNivdCase_T1', @level2type=N'COLUMN',@level2name=N'ProcessIndicator_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFamilyCourtNivdCase_T1', @level2type=N'COLUMN',@level2name=N'FileLoad_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFamilyCourtNivdCase_T1', @level2type=N'COLUMN',@level2name=N'InterStateState_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFamilyCourtNivdCase_T1', @level2type=N'COLUMN',@level2name=N'InterStateStatus_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFamilyCourtNivdCase_T1', @level2type=N'COLUMN',@level2name=N'County_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFamilyCourtNivdCase_T1', @level2type=N'COLUMN',@level2name=N'IVDType_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFamilyCourtNivdCase_T1', @level2type=N'COLUMN',@level2name=N'NcpMci_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFamilyCourtNivdCase_T1', @level2type=N'COLUMN',@level2name=N'CpMci_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFamilyCourtNivdCase_T1', @level2type=N'COLUMN',@level2name=N'FamilyCrtFile_ID'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFamilyCourtNivdCase_T1', @level2type=N'COLUMN',@level2name=N'Action_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFamilyCourtNivdCase_T1', @level2type=N'COLUMN',@level2name=N'PetitionType_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFamilyCourtNivdCase_T1', @level2type=N'COLUMN',@level2name=N'Case_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFamilyCourtNivdCase_T1', @level2type=N'COLUMN',@level2name=N'RelatedSeq_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFamilyCourtNivdCase_T1', @level2type=N'COLUMN',@level2name=N'Petition_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFamilyCourtNivdCase_T1', @level2type=N'COLUMN',@level2name=N'Rec_ID'

GO
EXEC sys.sp_dropextendedproperty @name=N'1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFamilyCourtNivdCase_T1', @level2type=N'COLUMN',@level2name=N'Seq_IDNO'

GO
/****** Object:  Table [dbo].[LoadFamilyCourtNivdCase_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[LoadFamilyCourtNivdCase_T1]
GO
/****** Object:  Table [dbo].[LoadFamilyCourtNivdCase_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[LoadFamilyCourtNivdCase_T1](
	[Seq_IDNO] [numeric](19, 0) IDENTITY(1,1) NOT NULL,
	[Rec_ID] [char](4) NOT NULL,
	[Petition_IDNO] [char](7) NOT NULL,
	[RelatedSeq_NUMB] [char](2) NOT NULL,
	[Case_IDNO] [char](6) NOT NULL,
	[PetitionType_CODE] [char](4) NOT NULL,
	[Action_DATE] [char](8) NOT NULL,
	[FamilyCrtFile_ID] [char](10) NOT NULL,
	[CpMci_IDNO] [char](10) NOT NULL,
	[NcpMci_IDNO] [char](10) NOT NULL,
	[IVDType_CODE] [char](4) NOT NULL,
	[County_IDNO] [char](3) NOT NULL,
	[InterStateStatus_CODE] [char](1) NOT NULL,
	[InterStateState_CODE] [char](2) NOT NULL,
	[FileLoad_DATE] [date] NOT NULL,
	[ProcessIndicator_INDC] [char](1) NOT NULL,
 CONSTRAINT [LFCNC_I1] PRIMARY KEY CLUSTERED 
(
	[Seq_IDNO] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
EXEC sys.sp_addextendedproperty @name=N'1', @value=N'This is a unique number to uniquely identify a record.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFamilyCourtNivdCase_T1', @level2type=N'COLUMN',@level2name=N'Seq_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Record type code.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFamilyCourtNivdCase_T1', @level2type=N'COLUMN',@level2name=N'Rec_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Family Court Petition Number.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFamilyCourtNivdCase_T1', @level2type=N'COLUMN',@level2name=N'Petition_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Family Court related sequence number.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFamilyCourtNivdCase_T1', @level2type=N'COLUMN',@level2name=N'RelatedSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'DACSES case number.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFamilyCourtNivdCase_T1', @level2type=N'COLUMN',@level2name=N'Case_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Family Court Petition type.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFamilyCourtNivdCase_T1', @level2type=N'COLUMN',@level2name=N'PetitionType_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Petition action date.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFamilyCourtNivdCase_T1', @level2type=N'COLUMN',@level2name=N'Action_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Family court file number.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFamilyCourtNivdCase_T1', @level2type=N'COLUMN',@level2name=N'FamilyCrtFile_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'MCI of CP.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFamilyCourtNivdCase_T1', @level2type=N'COLUMN',@level2name=N'CpMci_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'MCI of NCP.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFamilyCourtNivdCase_T1', @level2type=N'COLUMN',@level2name=N'NcpMci_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'FAMIS IV-D type code.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFamilyCourtNivdCase_T1', @level2type=N'COLUMN',@level2name=N'IVDType_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Case County Code.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFamilyCourtNivdCase_T1', @level2type=N'COLUMN',@level2name=N'County_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Case Interstate status code.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFamilyCourtNivdCase_T1', @level2type=N'COLUMN',@level2name=N'InterStateStatus_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Case Interstate state code.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFamilyCourtNivdCase_T1', @level2type=N'COLUMN',@level2name=N'InterStateState_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The date on which incoming file from Family court is loaded.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFamilyCourtNivdCase_T1', @level2type=N'COLUMN',@level2name=N'FileLoad_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Process Indicator.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFamilyCourtNivdCase_T1', @level2type=N'COLUMN',@level2name=N'ProcessIndicator_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'Read incoming files from family court NIVD and loads Case type into temporary table' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFamilyCourtNivdCase_T1'
GO
