USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcPetitionResponseDetails_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcPetitionResponseDetails_T1', @level2type=N'COLUMN',@level2name=N'Process_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcPetitionResponseDetails_T1', @level2type=N'COLUMN',@level2name=N'FileLoad_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcPetitionResponseDetails_T1', @level2type=N'COLUMN',@level2name=N'PetitionDispType_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcPetitionResponseDetails_T1', @level2type=N'COLUMN',@level2name=N'RecordTypeData_TEXT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcPetitionResponseDetails_T1', @level2type=N'COLUMN',@level2name=N'FamilyCourtFile_ID'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcPetitionResponseDetails_T1', @level2type=N'COLUMN',@level2name=N'PetitionAction_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcPetitionResponseDetails_T1', @level2type=N'COLUMN',@level2name=N'PetitionType_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcPetitionResponseDetails_T1', @level2type=N'COLUMN',@level2name=N'Case_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcPetitionResponseDetails_T1', @level2type=N'COLUMN',@level2name=N'PetitionSequence_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcPetitionResponseDetails_T1', @level2type=N'COLUMN',@level2name=N'Petition_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcPetitionResponseDetails_T1', @level2type=N'COLUMN',@level2name=N'Seq_IDNO'

GO
/****** Object:  Table [dbo].[LoadFcPetitionResponseDetails_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[LoadFcPetitionResponseDetails_T1]
GO
/****** Object:  Table [dbo].[LoadFcPetitionResponseDetails_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[LoadFcPetitionResponseDetails_T1](
	[Seq_IDNO] [numeric](19, 0) IDENTITY(1,1) NOT NULL,
	[Petition_IDNO] [char](7) NOT NULL,
	[PetitionSequence_IDNO] [char](2) NOT NULL,
	[Case_IDNO] [char](6) NOT NULL,
	[PetitionType_CODE] [char](4) NOT NULL,
	[PetitionAction_DATE] [char](8) NOT NULL,
	[FamilyCourtFile_ID] [char](10) NOT NULL,
	[RecordTypeData_TEXT] [varchar](198) NOT NULL,
	[PetitionDispType_CODE] [char](4) NOT NULL,
	[FileLoad_DATE] [date] NOT NULL,
	[Process_INDC] [char](1) NOT NULL,
 CONSTRAINT [LFCPR_I1] PRIMARY KEY CLUSTERED 
(
	[Seq_IDNO] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identity column' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcPetitionResponseDetails_T1', @level2type=N'COLUMN',@level2name=N'Seq_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Unique petition number assigned by the family court' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcPetitionResponseDetails_T1', @level2type=N'COLUMN',@level2name=N'Petition_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Petition sequence number' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcPetitionResponseDetails_T1', @level2type=N'COLUMN',@level2name=N'PetitionSequence_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Unique ID generated for the DACSES Case.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcPetitionResponseDetails_T1', @level2type=N'COLUMN',@level2name=N'Case_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Petition type request filed on the family court.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcPetitionResponseDetails_T1', @level2type=N'COLUMN',@level2name=N'PetitionType_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Petition action date' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcPetitionResponseDetails_T1', @level2type=N'COLUMN',@level2name=N'PetitionAction_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Family court file identification' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcPetitionResponseDetails_T1', @level2type=N'COLUMN',@level2name=N'FamilyCourtFile_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Family court response data based on petition disposition type value' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcPetitionResponseDetails_T1', @level2type=N'COLUMN',@level2name=N'RecordTypeData_TEXT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores Family court Petition disposition type.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcPetitionResponseDetails_T1', @level2type=N'COLUMN',@level2name=N'PetitionDispType_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Date file was loaded into the table' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcPetitionResponseDetails_T1', @level2type=N'COLUMN',@level2name=N'FileLoad_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the record was processed or not. ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcPetitionResponseDetails_T1', @level2type=N'COLUMN',@level2name=N'Process_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'Stores the petition response data from the Family Court Interface' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcPetitionResponseDetails_T1'
GO
