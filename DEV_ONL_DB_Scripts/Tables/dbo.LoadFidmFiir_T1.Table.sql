USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFidmFiir_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFidmFiir_T1', @level2type=N'COLUMN',@level2name=N'FileLoad_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFidmFiir_T1', @level2type=N'COLUMN',@level2name=N'Process_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFidmFiir_T1', @level2type=N'COLUMN',@level2name=N'InstitutionZip_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFidmFiir_T1', @level2type=N'COLUMN',@level2name=N'InstitutionState_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFidmFiir_T1', @level2type=N'COLUMN',@level2name=N'InstitutionCity_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFidmFiir_T1', @level2type=N'COLUMN',@level2name=N'InstitutionLine2_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFidmFiir_T1', @level2type=N'COLUMN',@level2name=N'InstitutionLine1_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFidmFiir_T1', @level2type=N'COLUMN',@level2name=N'InstitutionAddrNormalization_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFidmFiir_T1', @level2type=N'COLUMN',@level2name=N'DataMatch_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFidmFiir_T1', @level2type=N'COLUMN',@level2name=N'ReportingAgentZip_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFidmFiir_T1', @level2type=N'COLUMN',@level2name=N'ReportingAgentState_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFidmFiir_T1', @level2type=N'COLUMN',@level2name=N'ReportingAgentCity_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFidmFiir_T1', @level2type=N'COLUMN',@level2name=N'ReportingAgentStreet_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFidmFiir_T1', @level2type=N'COLUMN',@level2name=N'ReportingAgent_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFidmFiir_T1', @level2type=N'COLUMN',@level2name=N'ReportingAgentEIN_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFidmFiir_T1', @level2type=N'COLUMN',@level2name=N'InstitutionZipOld_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFidmFiir_T1', @level2type=N'COLUMN',@level2name=N'InstitutionStateOld_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFidmFiir_T1', @level2type=N'COLUMN',@level2name=N'InstitutionCityOld_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFidmFiir_T1', @level2type=N'COLUMN',@level2name=N'InstitutionStreetOld_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFidmFiir_T1', @level2type=N'COLUMN',@level2name=N'TransferAgent_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFidmFiir_T1', @level2type=N'COLUMN',@level2name=N'InstitutionSecond_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFidmFiir_T1', @level2type=N'COLUMN',@level2name=N'Institution_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFidmFiir_T1', @level2type=N'COLUMN',@level2name=N'ForeignCorrespondence_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFidmFiir_T1', @level2type=N'COLUMN',@level2name=N'MagneticTape_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFidmFiir_T1', @level2type=N'COLUMN',@level2name=N'ServiceBureau_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFidmFiir_T1', @level2type=N'COLUMN',@level2name=N'ReceivedFileType_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFidmFiir_T1', @level2type=N'COLUMN',@level2name=N'FileGenerated_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFidmFiir_T1', @level2type=N'COLUMN',@level2name=N'InstitutionControl_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFidmFiir_T1', @level2type=N'COLUMN',@level2name=N'FinancialInstitutionEIN_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFidmFiir_T1', @level2type=N'COLUMN',@level2name=N'TapeReel_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFidmFiir_T1', @level2type=N'COLUMN',@level2name=N'Rec_ID'

GO
EXEC sys.sp_dropextendedproperty @name=N'1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFidmFiir_T1', @level2type=N'COLUMN',@level2name=N'Seq_IDNO'

GO
/****** Object:  Table [dbo].[LoadFidmFiir_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[LoadFidmFiir_T1]
GO
/****** Object:  Table [dbo].[LoadFidmFiir_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[LoadFidmFiir_T1](
	[Seq_IDNO] [numeric](19, 0) IDENTITY(1,1) NOT NULL,
	[Rec_ID] [char](1) NOT NULL,
	[TapeReel_NUMB] [char](3) NOT NULL,
	[FinancialInstitutionEIN_IDNO] [char](9) NOT NULL,
	[InstitutionControl_NAME] [char](4) NOT NULL,
	[FileGenerated_DATE] [char](8) NOT NULL,
	[ReceivedFileType_CODE] [char](1) NOT NULL,
	[ServiceBureau_CODE] [char](1) NOT NULL,
	[MagneticTape_CODE] [char](2) NOT NULL,
	[ForeignCorrespondence_CODE] [char](1) NOT NULL,
	[Institution_NAME] [char](40) NOT NULL,
	[InstitutionSecond_NAME] [char](40) NOT NULL,
	[TransferAgent_CODE] [char](1) NOT NULL,
	[InstitutionStreetOld_ADDR] [char](40) NOT NULL,
	[InstitutionCityOld_ADDR] [char](29) NOT NULL,
	[InstitutionStateOld_ADDR] [char](2) NOT NULL,
	[InstitutionZipOld_ADDR] [char](9) NOT NULL,
	[ReportingAgentEIN_IDNO] [char](9) NOT NULL,
	[ReportingAgent_NAME] [varchar](71) NOT NULL,
	[ReportingAgentStreet_ADDR] [char](40) NOT NULL,
	[ReportingAgentCity_ADDR] [char](29) NOT NULL,
	[ReportingAgentState_ADDR] [char](2) NOT NULL,
	[ReportingAgentZip_ADDR] [char](9) NOT NULL,
	[DataMatch_CODE] [char](1) NOT NULL,
	[InstitutionAddrNormalization_CODE] [char](1) NOT NULL,
	[InstitutionLine1_ADDR] [varchar](50) NOT NULL,
	[InstitutionLine2_ADDR] [varchar](50) NOT NULL,
	[InstitutionCity_ADDR] [char](28) NOT NULL,
	[InstitutionState_ADDR] [char](2) NOT NULL,
	[InstitutionZip_ADDR] [char](15) NOT NULL,
	[Process_INDC] [char](1) NOT NULL,
	[FileLoad_DATE] [date] NOT NULL,
 CONSTRAINT [LFIIR_I1] PRIMARY KEY CLUSTERED 
(
	[Seq_IDNO] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
EXEC sys.sp_addextendedproperty @name=N'1', @value=N'Record Sequence number' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFidmFiir_T1', @level2type=N'COLUMN',@level2name=N'Seq_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'FIDM add record type' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFidmFiir_T1', @level2type=N'COLUMN',@level2name=N'Rec_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Tape reel number' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFidmFiir_T1', @level2type=N'COLUMN',@level2name=N'TapeReel_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Financial institution''s taxpayer identification number' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFidmFiir_T1', @level2type=N'COLUMN',@level2name=N'FinancialInstitutionEIN_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Financial Institution control name' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFidmFiir_T1', @level2type=N'COLUMN',@level2name=N'InstitutionControl_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'FIDM file generated date' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFidmFiir_T1', @level2type=N'COLUMN',@level2name=N'FileGenerated_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Specifies whether the incoming file is Test file or Correction file' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFidmFiir_T1', @level2type=N'COLUMN',@level2name=N'ReceivedFileType_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Specifies whether service agent prepared data match information or not' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFidmFiir_T1', @level2type=N'COLUMN',@level2name=N'ServiceBureau_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Specifies whether information is filled in magnetic tape/cartridge or not' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFidmFiir_T1', @level2type=N'COLUMN',@level2name=N'MagneticTape_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Specifies whether financial institution is foreign corporation or not' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFidmFiir_T1', @level2type=N'COLUMN',@level2name=N'ForeignCorrespondence_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Financial institution name' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFidmFiir_T1', @level2type=N'COLUMN',@level2name=N'Institution_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Financial institution second name or Transfer agent name' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFidmFiir_T1', @level2type=N'COLUMN',@level2name=N'InstitutionSecond_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Specifies whether Institution second name has Transfer agent name or not' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFidmFiir_T1', @level2type=N'COLUMN',@level2name=N'TransferAgent_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Financial institution street address' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFidmFiir_T1', @level2type=N'COLUMN',@level2name=N'InstitutionStreetOld_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Financial institution city address' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFidmFiir_T1', @level2type=N'COLUMN',@level2name=N'InstitutionCityOld_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Financial institution state address' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFidmFiir_T1', @level2type=N'COLUMN',@level2name=N'InstitutionStateOld_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Financial institution zip address' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFidmFiir_T1', @level2type=N'COLUMN',@level2name=N'InstitutionZipOld_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Reporting agent''s Taxpayer identification number' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFidmFiir_T1', @level2type=N'COLUMN',@level2name=N'ReportingAgentEIN_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Reporting agent name' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFidmFiir_T1', @level2type=N'COLUMN',@level2name=N'ReportingAgent_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Reporting agent street address' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFidmFiir_T1', @level2type=N'COLUMN',@level2name=N'ReportingAgentStreet_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Reporting agent city address' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFidmFiir_T1', @level2type=N'COLUMN',@level2name=N'ReportingAgentCity_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Reporting agent state address' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFidmFiir_T1', @level2type=N'COLUMN',@level2name=N'ReportingAgentState_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Reporting agent zip address' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFidmFiir_T1', @level2type=N'COLUMN',@level2name=N'ReportingAgentZip_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Data match code' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFidmFiir_T1', @level2type=N'COLUMN',@level2name=N'DataMatch_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Normalization Code' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFidmFiir_T1', @level2type=N'COLUMN',@level2name=N'InstitutionAddrNormalization_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Financial institution address line 1 after Normalization' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFidmFiir_T1', @level2type=N'COLUMN',@level2name=N'InstitutionLine1_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Financial institution address line 2 after Normalization' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFidmFiir_T1', @level2type=N'COLUMN',@level2name=N'InstitutionLine2_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Financial institution city address after Normalization' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFidmFiir_T1', @level2type=N'COLUMN',@level2name=N'InstitutionCity_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Financial institution state address after Normalization' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFidmFiir_T1', @level2type=N'COLUMN',@level2name=N'InstitutionState_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Financial institution zip address after Normalization' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFidmFiir_T1', @level2type=N'COLUMN',@level2name=N'InstitutionZip_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Process indicator' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFidmFiir_T1', @level2type=N'COLUMN',@level2name=N'Process_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'File loaded date' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFidmFiir_T1', @level2type=N'COLUMN',@level2name=N'FileLoad_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'This table is used as staging table to load Financial Institution records from FIDM (Financial institution data match) incoming file.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFidmFiir_T1'
GO
