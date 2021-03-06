USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIcr_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIcr_T1', @level2type=N'COLUMN',@level2name=N'Process_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIcr_T1', @level2type=N'COLUMN',@level2name=N'FileLoad_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIcr_T1', @level2type=N'COLUMN',@level2name=N'MultipleCase_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIcr_T1', @level2type=N'COLUMN',@level2name=N'ReceivedSsnVerification_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIcr_T1', @level2type=N'COLUMN',@level2name=N'SentSsnVerification_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIcr_T1', @level2type=N'COLUMN',@level2name=N'IVDOutOfStateRespondInit_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIcr_T1', @level2type=N'COLUMN',@level2name=N'NcpMatched_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIcr_T1', @level2type=N'COLUMN',@level2name=N'CpMatched_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIcr_T1', @level2type=N'COLUMN',@level2name=N'OutStateFipsVerification_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIcr_T1', @level2type=N'COLUMN',@level2name=N'FipsVerification_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIcr_T1', @level2type=N'COLUMN',@level2name=N'ReceivedContact_EML'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIcr_T1', @level2type=N'COLUMN',@level2name=N'ReceivedContactPhone_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIcr_T1', @level2type=N'COLUMN',@level2name=N'ReceivedContact_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIcr_T1', @level2type=N'COLUMN',@level2name=N'MatchedChild_QNTY'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIcr_T1', @level2type=N'COLUMN',@level2name=N'OutStateChild_QNTY'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIcr_T1', @level2type=N'COLUMN',@level2name=N'InStateChild_QNTY'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIcr_T1', @level2type=N'COLUMN',@level2name=N'AdultMatched_QNTY'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIcr_T1', @level2type=N'COLUMN',@level2name=N'OutStateAdult_QNTY'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIcr_T1', @level2type=N'COLUMN',@level2name=N'InStateAdult_QNTY'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIcr_T1', @level2type=N'COLUMN',@level2name=N'ReceivedMemberSex_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIcr_T1', @level2type=N'COLUMN',@level2name=N'ReceivedBirth_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIcr_T1', @level2type=N'COLUMN',@level2name=N'ReceivedMiddle_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIcr_T1', @level2type=N'COLUMN',@level2name=N'ReceivedFirst_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIcr_T1', @level2type=N'COLUMN',@level2name=N'ReceivedLast_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIcr_T1', @level2type=N'COLUMN',@level2name=N'TypeParticipant_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIcr_T1', @level2type=N'COLUMN',@level2name=N'ReceivedMemberMci_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIcr_T1', @level2type=N'COLUMN',@level2name=N'ReceivedMemberSsn_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIcr_T1', @level2type=N'COLUMN',@level2name=N'ReceivedIVDOutOfStateFips_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIcr_T1', @level2type=N'COLUMN',@level2name=N'ReceivedIVDOutOfStateCase_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIcr_T1', @level2type=N'COLUMN',@level2name=N'Reason6_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIcr_T1', @level2type=N'COLUMN',@level2name=N'Reason5_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIcr_T1', @level2type=N'COLUMN',@level2name=N'Reason4_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIcr_T1', @level2type=N'COLUMN',@level2name=N'Reason3_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIcr_T1', @level2type=N'COLUMN',@level2name=N'Reason2_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIcr_T1', @level2type=N'COLUMN',@level2name=N'Reason1_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIcr_T1', @level2type=N'COLUMN',@level2name=N'IcrStatus_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIcr_T1', @level2type=N'COLUMN',@level2name=N'SentContact_EML'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIcr_T1', @level2type=N'COLUMN',@level2name=N'SentPhoneContact_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIcr_T1', @level2type=N'COLUMN',@level2name=N'SentContact_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIcr_T1', @level2type=N'COLUMN',@level2name=N'IVDOutOfStateOfficeFips_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIcr_T1', @level2type=N'COLUMN',@level2name=N'SentIVDOutOfStateCountyFips_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIcr_T1', @level2type=N'COLUMN',@level2name=N'SentIVDOutOfStateFips_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIcr_T1', @level2type=N'COLUMN',@level2name=N'SentIVDOutOfStateCase_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIcr_T1', @level2type=N'COLUMN',@level2name=N'SentMemberSex_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIcr_T1', @level2type=N'COLUMN',@level2name=N'SentBirth_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIcr_T1', @level2type=N'COLUMN',@level2name=N'SentMiddle_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIcr_T1', @level2type=N'COLUMN',@level2name=N'SentFirst_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIcr_T1', @level2type=N'COLUMN',@level2name=N'SentLast_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIcr_T1', @level2type=N'COLUMN',@level2name=N'StatusCase_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIcr_T1', @level2type=N'COLUMN',@level2name=N'CaseRelationship_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIcr_T1', @level2type=N'COLUMN',@level2name=N'MemberMci_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIcr_T1', @level2type=N'COLUMN',@level2name=N'MemberSsn_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIcr_T1', @level2type=N'COLUMN',@level2name=N'OfficeFips_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIcr_T1', @level2type=N'COLUMN',@level2name=N'County_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIcr_T1', @level2type=N'COLUMN',@level2name=N'StateFips_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIcr_T1', @level2type=N'COLUMN',@level2name=N'RespondInit_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIcr_T1', @level2type=N'COLUMN',@level2name=N'Case_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIcr_T1', @level2type=N'COLUMN',@level2name=N'Seq_IDNO'

GO
/****** Object:  Table [dbo].[LoadIcr_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[LoadIcr_T1]
GO
/****** Object:  Table [dbo].[LoadIcr_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[LoadIcr_T1](
	[Seq_IDNO] [numeric](19, 0) IDENTITY(1,1) NOT NULL,
	[Case_IDNO] [char](15) NOT NULL,
	[RespondInit_CODE] [char](1) NOT NULL,
	[StateFips_CODE] [char](2) NOT NULL,
	[County_IDNO] [char](3) NOT NULL,
	[OfficeFips_CODE] [char](2) NOT NULL,
	[MemberSsn_NUMB] [char](9) NOT NULL,
	[MemberMci_IDNO] [char](15) NOT NULL,
	[CaseRelationship_CODE] [char](2) NOT NULL,
	[StatusCase_CODE] [char](1) NOT NULL,
	[SentLast_NAME] [char](30) NOT NULL,
	[SentFirst_NAME] [char](16) NOT NULL,
	[SentMiddle_NAME] [char](16) NOT NULL,
	[SentBirth_DATE] [char](8) NOT NULL,
	[SentMemberSex_CODE] [char](1) NOT NULL,
	[SentIVDOutOfStateCase_IDNO] [char](15) NOT NULL,
	[SentIVDOutOfStateFips_CODE] [char](2) NOT NULL,
	[SentIVDOutOfStateCountyFips_CODE] [char](3) NOT NULL,
	[IVDOutOfStateOfficeFips_CODE] [char](2) NOT NULL,
	[SentContact_NAME] [char](40) NOT NULL,
	[SentPhoneContact_NUMB] [char](10) NOT NULL,
	[SentContact_EML] [char](30) NOT NULL,
	[IcrStatus_INDC] [char](1) NOT NULL,
	[Reason1_CODE] [char](2) NOT NULL,
	[Reason2_CODE] [char](2) NOT NULL,
	[Reason3_CODE] [char](2) NOT NULL,
	[Reason4_CODE] [char](2) NOT NULL,
	[Reason5_CODE] [char](2) NOT NULL,
	[Reason6_CODE] [char](2) NOT NULL,
	[ReceivedIVDOutOfStateCase_IDNO] [char](15) NOT NULL,
	[ReceivedIVDOutOfStateFips_CODE] [char](7) NOT NULL,
	[ReceivedMemberSsn_NUMB] [char](9) NOT NULL,
	[ReceivedMemberMci_IDNO] [char](15) NOT NULL,
	[TypeParticipant_CODE] [char](2) NOT NULL,
	[ReceivedLast_NAME] [char](30) NOT NULL,
	[ReceivedFirst_NAME] [char](16) NOT NULL,
	[ReceivedMiddle_NAME] [char](16) NOT NULL,
	[ReceivedBirth_DATE] [char](8) NOT NULL,
	[ReceivedMemberSex_CODE] [char](1) NOT NULL,
	[InStateAdult_QNTY] [char](2) NOT NULL,
	[OutStateAdult_QNTY] [char](2) NOT NULL,
	[AdultMatched_QNTY] [char](2) NOT NULL,
	[InStateChild_QNTY] [char](2) NOT NULL,
	[OutStateChild_QNTY] [char](2) NOT NULL,
	[MatchedChild_QNTY] [char](2) NOT NULL,
	[ReceivedContact_NAME] [char](40) NOT NULL,
	[ReceivedContactPhone_NUMB] [char](10) NOT NULL,
	[ReceivedContact_EML] [char](30) NOT NULL,
	[FipsVerification_INDC] [char](1) NOT NULL,
	[OutStateFipsVerification_INDC] [char](1) NOT NULL,
	[CpMatched_INDC] [char](1) NOT NULL,
	[NcpMatched_INDC] [char](1) NOT NULL,
	[IVDOutOfStateRespondInit_CODE] [char](1) NOT NULL,
	[SentSsnVerification_INDC] [char](1) NOT NULL,
	[ReceivedSsnVerification_INDC] [char](1) NOT NULL,
	[MultipleCase_INDC] [char](1) NOT NULL,
	[FileLoad_DATE] [date] NOT NULL,
	[Process_INDC] [char](1) NOT NULL,
 CONSTRAINT [LIGCR_I1] PRIMARY KEY CLUSTERED 
(
	[Seq_IDNO] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
EXEC sys.sp_addextendedproperty @name=N'1', @value=N'Identifies record uniquely' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIcr_T1', @level2type=N'COLUMN',@level2name=N'Seq_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the Case ID associated with the record.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIcr_T1', @level2type=N'COLUMN',@level2name=N'Case_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Case is Initiating or Responding Case. ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIcr_T1', @level2type=N'COLUMN',@level2name=N'RespondInit_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Delaware FIPS code.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIcr_T1', @level2type=N'COLUMN',@level2name=N'StateFips_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies Case county code.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIcr_T1', @level2type=N'COLUMN',@level2name=N'County_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'FIPS office code as defined in Federal Information Processing Standards.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIcr_T1', @level2type=N'COLUMN',@level2name=N'OfficeFips_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Members social security number.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIcr_T1', @level2type=N'COLUMN',@level2name=N'MemberSsn_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies Unique Assigned by the System to the Member.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIcr_T1', @level2type=N'COLUMN',@level2name=N'MemberMci_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Members Case Relation. ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIcr_T1', @level2type=N'COLUMN',@level2name=N'CaseRelationship_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Status of the Case.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIcr_T1', @level2type=N'COLUMN',@level2name=N'StatusCase_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Last name of the member.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIcr_T1', @level2type=N'COLUMN',@level2name=N'SentLast_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'First name of the member.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIcr_T1', @level2type=N'COLUMN',@level2name=N'SentFirst_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Middle name of the member.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIcr_T1', @level2type=N'COLUMN',@level2name=N'SentMiddle_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Members date of birth.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIcr_T1', @level2type=N'COLUMN',@level2name=N'SentBirth_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Member sex code.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIcr_T1', @level2type=N'COLUMN',@level2name=N'SentMemberSex_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indentifies the Other State Case ID.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIcr_T1', @level2type=N'COLUMN',@level2name=N'SentIVDOutOfStateCase_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Interstate Case FIPS Code. ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIcr_T1', @level2type=N'COLUMN',@level2name=N'SentIVDOutOfStateFips_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N' Interstate Case County. ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIcr_T1', @level2type=N'COLUMN',@level2name=N'SentIVDOutOfStateCountyFips_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Interstate Case FIPS Code' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIcr_T1', @level2type=N'COLUMN',@level2name=N'IVDOutOfStateOfficeFips_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Contact Person Name.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIcr_T1', @level2type=N'COLUMN',@level2name=N'SentContact_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Phone Number of the Contact Person.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIcr_T1', @level2type=N'COLUMN',@level2name=N'SentPhoneContact_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Email Address of the Member.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIcr_T1', @level2type=N'COLUMN',@level2name=N'SentContact_EML'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates whether the case is matched against ICR.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIcr_T1', @level2type=N'COLUMN',@level2name=N'IcrStatus_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'First code for explanation of match results.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIcr_T1', @level2type=N'COLUMN',@level2name=N'Reason1_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Second code for explanation of match results.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIcr_T1', @level2type=N'COLUMN',@level2name=N'Reason2_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Third code for explanation of match results.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIcr_T1', @level2type=N'COLUMN',@level2name=N'Reason3_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Fourth code for explanation of match results.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIcr_T1', @level2type=N'COLUMN',@level2name=N'Reason4_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Fifth code for explanation of match results.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIcr_T1', @level2type=N'COLUMN',@level2name=N'Reason5_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Sixth code for explanation of match results.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIcr_T1', @level2type=N'COLUMN',@level2name=N'Reason6_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies Received Other State Case ID.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIcr_T1', @level2type=N'COLUMN',@level2name=N'ReceivedIVDOutOfStateCase_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N' Received Interstate Case FIPS Code. ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIcr_T1', @level2type=N'COLUMN',@level2name=N'ReceivedIVDOutOfStateFips_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Received Members social security number.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIcr_T1', @level2type=N'COLUMN',@level2name=N'ReceivedMemberSsn_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies Received Member MCI number' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIcr_T1', @level2type=N'COLUMN',@level2name=N'ReceivedMemberMci_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Participant Type' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIcr_T1', @level2type=N'COLUMN',@level2name=N'TypeParticipant_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Received Last name of the member.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIcr_T1', @level2type=N'COLUMN',@level2name=N'ReceivedLast_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Received First name of the member.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIcr_T1', @level2type=N'COLUMN',@level2name=N'ReceivedFirst_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Received Middle name of the member.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIcr_T1', @level2type=N'COLUMN',@level2name=N'ReceivedMiddle_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Received Members date of birth.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIcr_T1', @level2type=N'COLUMN',@level2name=N'ReceivedBirth_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Received Member sex code.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIcr_T1', @level2type=N'COLUMN',@level2name=N'ReceivedMemberSex_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Number of adults in DE cases.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIcr_T1', @level2type=N'COLUMN',@level2name=N'InStateAdult_QNTY'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Number of adults in other state cases.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIcr_T1', @level2type=N'COLUMN',@level2name=N'OutStateAdult_QNTY'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Number of adults in DE cases that are matched.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIcr_T1', @level2type=N'COLUMN',@level2name=N'AdultMatched_QNTY'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Number of children in DE cases.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIcr_T1', @level2type=N'COLUMN',@level2name=N'InStateChild_QNTY'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Number of children in other state cases.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIcr_T1', @level2type=N'COLUMN',@level2name=N'OutStateChild_QNTY'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Number of children in DE cases that are matched.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIcr_T1', @level2type=N'COLUMN',@level2name=N'MatchedChild_QNTY'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Received Contact Person Name.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIcr_T1', @level2type=N'COLUMN',@level2name=N'ReceivedContact_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Received Phone Number of the Contact Person.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIcr_T1', @level2type=N'COLUMN',@level2name=N'ReceivedContactPhone_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Received Email Address of the Member.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIcr_T1', @level2type=N'COLUMN',@level2name=N'ReceivedContact_EML'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates FIPS Code that was submitted by the DE state valid or not.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIcr_T1', @level2type=N'COLUMN',@level2name=N'FipsVerification_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates FIPS Code that was submitted by the other state valid or not.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIcr_T1', @level2type=N'COLUMN',@level2name=N'OutStateFipsVerification_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates whether the member is submitted as ''CP''.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIcr_T1', @level2type=N'COLUMN',@level2name=N'CpMatched_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates whether the member is submitted as ''NCP''.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIcr_T1', @level2type=N'COLUMN',@level2name=N'NcpMatched_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Intergovernmental status of the case.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIcr_T1', @level2type=N'COLUMN',@level2name=N'IVDOutOfStateRespondInit_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates SSN Verification process.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIcr_T1', @level2type=N'COLUMN',@level2name=N'SentSsnVerification_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates Received SSN Verification process.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIcr_T1', @level2type=N'COLUMN',@level2name=N'ReceivedSsnVerification_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates whether case matched multiple cases in the other state.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIcr_T1', @level2type=N'COLUMN',@level2name=N'MultipleCase_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'File Load Date.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIcr_T1', @level2type=N'COLUMN',@level2name=N'FileLoad_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates whether the record is processed or not.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIcr_T1', @level2type=N'COLUMN',@level2name=N'Process_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'This Batch loads the interstate cases and updates the out of state case id on intergovernmental case and updates SSN.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIcr_T1'
GO
