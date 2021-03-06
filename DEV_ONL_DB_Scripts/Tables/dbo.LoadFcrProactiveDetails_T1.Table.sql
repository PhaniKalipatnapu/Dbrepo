USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrProactiveDetails_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrProactiveDetails_T1', @level2type=N'COLUMN',@level2name=N'FileLoad_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrProactiveDetails_T1', @level2type=N'COLUMN',@level2name=N'Process_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrProactiveDetails_T1', @level2type=N'COLUMN',@level2name=N'DeathAssociated3_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrProactiveDetails_T1', @level2type=N'COLUMN',@level2name=N'BirthAssociated3_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrProactiveDetails_T1', @level2type=N'COLUMN',@level2name=N'MemberMciAssociated3_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrProactiveDetails_T1', @level2type=N'COLUMN',@level2name=N'TypePartAssociated3_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrProactiveDetails_T1', @level2type=N'COLUMN',@level2name=N'MemberSexAssociated3_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrProactiveDetails_T1', @level2type=N'COLUMN',@level2name=N'L1Associated3_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrProactiveDetails_T1', @level2type=N'COLUMN',@level2name=N'M1Associated3_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrProactiveDetails_T1', @level2type=N'COLUMN',@level2name=N'F1Associated3_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrProactiveDetails_T1', @level2type=N'COLUMN',@level2name=N'MemberAssociated3Ssn_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrProactiveDetails_T1', @level2type=N'COLUMN',@level2name=N'DeathAssociated2_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrProactiveDetails_T1', @level2type=N'COLUMN',@level2name=N'BirthAssociated2_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrProactiveDetails_T1', @level2type=N'COLUMN',@level2name=N'MemberMciAssociated2_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrProactiveDetails_T1', @level2type=N'COLUMN',@level2name=N'TypePartAssociated2_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrProactiveDetails_T1', @level2type=N'COLUMN',@level2name=N'MemberSexAssociated2_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrProactiveDetails_T1', @level2type=N'COLUMN',@level2name=N'L1Associated2_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrProactiveDetails_T1', @level2type=N'COLUMN',@level2name=N'M1Associated2_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrProactiveDetails_T1', @level2type=N'COLUMN',@level2name=N'F1Associated2_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrProactiveDetails_T1', @level2type=N'COLUMN',@level2name=N'MemberAssociated2Ssn_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrProactiveDetails_T1', @level2type=N'COLUMN',@level2name=N'DeathAssociated1_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrProactiveDetails_T1', @level2type=N'COLUMN',@level2name=N'BirthAssociated1_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrProactiveDetails_T1', @level2type=N'COLUMN',@level2name=N'MemberMciAssociated1_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrProactiveDetails_T1', @level2type=N'COLUMN',@level2name=N'TypePartAssociated1_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrProactiveDetails_T1', @level2type=N'COLUMN',@level2name=N'MemberSexAssociated1_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrProactiveDetails_T1', @level2type=N'COLUMN',@level2name=N'L1Associated1_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrProactiveDetails_T1', @level2type=N'COLUMN',@level2name=N'M1Associated1_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrProactiveDetails_T1', @level2type=N'COLUMN',@level2name=N'F1Associated1_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrProactiveDetails_T1', @level2type=N'COLUMN',@level2name=N'MemberAssociated1Ssn_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrProactiveDetails_T1', @level2type=N'COLUMN',@level2name=N'L1AddtlMatched4_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrProactiveDetails_T1', @level2type=N'COLUMN',@level2name=N'M1AddtlMatched4_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrProactiveDetails_T1', @level2type=N'COLUMN',@level2name=N'F1AddtlMatched4_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrProactiveDetails_T1', @level2type=N'COLUMN',@level2name=N'L1AddtlMatched3_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrProactiveDetails_T1', @level2type=N'COLUMN',@level2name=N'M1AddtlMatched3_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrProactiveDetails_T1', @level2type=N'COLUMN',@level2name=N'F1AddtlMatched3_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrProactiveDetails_T1', @level2type=N'COLUMN',@level2name=N'L1AddtlMatched2_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrProactiveDetails_T1', @level2type=N'COLUMN',@level2name=N'M1AddtlMatched2_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrProactiveDetails_T1', @level2type=N'COLUMN',@level2name=N'F1AddtlMatched2_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrProactiveDetails_T1', @level2type=N'COLUMN',@level2name=N'L1AddtlMatched1_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrProactiveDetails_T1', @level2type=N'COLUMN',@level2name=N'M1AddtlMatched1_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrProactiveDetails_T1', @level2type=N'COLUMN',@level2name=N'F1AddtlMatched1_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrProactiveDetails_T1', @level2type=N'COLUMN',@level2name=N'DeathMatched_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrProactiveDetails_T1', @level2type=N'COLUMN',@level2name=N'MatchedMemberMci_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrProactiveDetails_T1', @level2type=N'COLUMN',@level2name=N'TypeParticipantMatched_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrProactiveDetails_T1', @level2type=N'COLUMN',@level2name=N'OrderCaseMatched_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrProactiveDetails_T1', @level2type=N'COLUMN',@level2name=N'RegistrationMatched_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrProactiveDetails_T1', @level2type=N'COLUMN',@level2name=N'CountyFcrMatched_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrProactiveDetails_T1', @level2type=N'COLUMN',@level2name=N'TypeCaseMatched_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrProactiveDetails_T1', @level2type=N'COLUMN',@level2name=N'StateCaseMatched_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrProactiveDetails_T1', @level2type=N'COLUMN',@level2name=N'CaseMatched_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrProactiveDetails_T1', @level2type=N'COLUMN',@level2name=N'Response_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrProactiveDetails_T1', @level2type=N'COLUMN',@level2name=N'CaseSubmitted_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrProactiveDetails_T1', @level2type=N'COLUMN',@level2name=N'MemberMci_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrProactiveDetails_T1', @level2type=N'COLUMN',@level2name=N'MatchedSubmittedSsn_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrProactiveDetails_T1', @level2type=N'COLUMN',@level2name=N'Last_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrProactiveDetails_T1', @level2type=N'COLUMN',@level2name=N'Middle_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrProactiveDetails_T1', @level2type=N'COLUMN',@level2name=N'First_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrProactiveDetails_T1', @level2type=N'COLUMN',@level2name=N'Batch_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrProactiveDetails_T1', @level2type=N'COLUMN',@level2name=N'CountyFips_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrProactiveDetails_T1', @level2type=N'COLUMN',@level2name=N'UserField_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrProactiveDetails_T1', @level2type=N'COLUMN',@level2name=N'TypeAction_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrProactiveDetails_T1', @level2type=N'COLUMN',@level2name=N'TerritoryFips_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrProactiveDetails_T1', @level2type=N'COLUMN',@level2name=N'Rec_ID'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrProactiveDetails_T1', @level2type=N'COLUMN',@level2name=N'Seq_IDNO'

GO
/****** Object:  Table [dbo].[LoadFcrProactiveDetails_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[LoadFcrProactiveDetails_T1]
GO
/****** Object:  Table [dbo].[LoadFcrProactiveDetails_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[LoadFcrProactiveDetails_T1](
	[Seq_IDNO] [numeric](19, 0) IDENTITY(1,1) NOT NULL,
	[Rec_ID] [char](2) NOT NULL,
	[TerritoryFips_CODE] [char](2) NOT NULL,
	[TypeAction_CODE] [char](1) NOT NULL,
	[UserField_NAME] [char](15) NOT NULL,
	[CountyFips_CODE] [char](3) NOT NULL,
	[Batch_NUMB] [char](6) NOT NULL,
	[First_NAME] [char](16) NOT NULL,
	[Middle_NAME] [char](16) NOT NULL,
	[Last_NAME] [char](30) NOT NULL,
	[MatchedSubmittedSsn_NUMB] [char](9) NOT NULL,
	[MemberMci_IDNO] [char](10) NOT NULL,
	[CaseSubmitted_IDNO] [char](6) NOT NULL,
	[Response_CODE] [char](2) NOT NULL,
	[CaseMatched_IDNO] [char](15) NOT NULL,
	[StateCaseMatched_CODE] [char](2) NOT NULL,
	[TypeCaseMatched_CODE] [char](1) NOT NULL,
	[CountyFcrMatched_IDNO] [char](3) NOT NULL,
	[RegistrationMatched_DATE] [char](8) NOT NULL,
	[OrderCaseMatched_INDC] [char](1) NOT NULL,
	[TypeParticipantMatched_CODE] [char](2) NOT NULL,
	[MatchedMemberMci_IDNO] [char](15) NOT NULL,
	[DeathMatched_DATE] [char](8) NOT NULL,
	[F1AddtlMatched1_NAME] [char](16) NOT NULL,
	[M1AddtlMatched1_NAME] [char](16) NOT NULL,
	[L1AddtlMatched1_NAME] [char](30) NOT NULL,
	[F1AddtlMatched2_NAME] [char](16) NOT NULL,
	[M1AddtlMatched2_NAME] [char](16) NOT NULL,
	[L1AddtlMatched2_NAME] [char](30) NOT NULL,
	[F1AddtlMatched3_NAME] [char](16) NOT NULL,
	[M1AddtlMatched3_NAME] [char](16) NOT NULL,
	[L1AddtlMatched3_NAME] [char](30) NOT NULL,
	[F1AddtlMatched4_NAME] [char](16) NOT NULL,
	[M1AddtlMatched4_NAME] [char](16) NOT NULL,
	[L1AddtlMatched4_NAME] [char](30) NOT NULL,
	[MemberAssociated1Ssn_NUMB] [char](9) NOT NULL,
	[F1Associated1_NAME] [char](16) NOT NULL,
	[M1Associated1_NAME] [char](16) NOT NULL,
	[L1Associated1_NAME] [char](30) NOT NULL,
	[MemberSexAssociated1_CODE] [char](1) NOT NULL,
	[TypePartAssociated1_CODE] [char](2) NOT NULL,
	[MemberMciAssociated1_IDNO] [char](15) NOT NULL,
	[BirthAssociated1_DATE] [char](8) NOT NULL,
	[DeathAssociated1_DATE] [char](8) NOT NULL,
	[MemberAssociated2Ssn_NUMB] [char](9) NOT NULL,
	[F1Associated2_NAME] [char](16) NOT NULL,
	[M1Associated2_NAME] [char](16) NOT NULL,
	[L1Associated2_NAME] [char](30) NOT NULL,
	[MemberSexAssociated2_CODE] [char](1) NOT NULL,
	[TypePartAssociated2_CODE] [char](2) NOT NULL,
	[MemberMciAssociated2_IDNO] [char](15) NOT NULL,
	[BirthAssociated2_DATE] [char](8) NOT NULL,
	[DeathAssociated2_DATE] [char](8) NOT NULL,
	[MemberAssociated3Ssn_NUMB] [char](9) NOT NULL,
	[F1Associated3_NAME] [char](16) NOT NULL,
	[M1Associated3_NAME] [char](16) NOT NULL,
	[L1Associated3_NAME] [char](30) NOT NULL,
	[MemberSexAssociated3_CODE] [char](1) NOT NULL,
	[TypePartAssociated3_CODE] [char](2) NOT NULL,
	[MemberMciAssociated3_IDNO] [char](15) NOT NULL,
	[BirthAssociated3_DATE] [char](8) NOT NULL,
	[DeathAssociated3_DATE] [char](8) NOT NULL,
	[Process_INDC] [char](1) NOT NULL,
	[FileLoad_DATE] [date] NOT NULL,
 CONSTRAINT [LFPDE_I1] PRIMARY KEY CLUSTERED 
(
	[Seq_IDNO] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Specifies the system generated sequence number to maintain uniqueness.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrProactiveDetails_T1', @level2type=N'COLUMN',@level2name=N'Seq_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies Proactive record  FT.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrProactiveDetails_T1', @level2type=N'COLUMN',@level2name=N'Rec_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Other State FIPS id.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrProactiveDetails_T1', @level2type=N'COLUMN',@level2name=N'TerritoryFips_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Action Type Code.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrProactiveDetails_T1', @level2type=N'COLUMN',@level2name=N'TypeAction_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'User Enterable Field.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrProactiveDetails_T1', @level2type=N'COLUMN',@level2name=N'UserField_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'County code.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrProactiveDetails_T1', @level2type=N'COLUMN',@level2name=N'CountyFips_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Batch Number.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrProactiveDetails_T1', @level2type=N'COLUMN',@level2name=N'Batch_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'NCP First Name.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrProactiveDetails_T1', @level2type=N'COLUMN',@level2name=N'First_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'NCP Middle Name.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrProactiveDetails_T1', @level2type=N'COLUMN',@level2name=N'Middle_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'NCP Last Name.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrProactiveDetails_T1', @level2type=N'COLUMN',@level2name=N'Last_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'NCP Verified SSN.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrProactiveDetails_T1', @level2type=N'COLUMN',@level2name=N'MatchedSubmittedSsn_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Member id.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrProactiveDetails_T1', @level2type=N'COLUMN',@level2name=N'MemberMci_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Case Id.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrProactiveDetails_T1', @level2type=N'COLUMN',@level2name=N'CaseSubmitted_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Response Code from FCR.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrProactiveDetails_T1', @level2type=N'COLUMN',@level2name=N'Response_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Matched Case ID.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrProactiveDetails_T1', @level2type=N'COLUMN',@level2name=N'CaseMatched_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'State in which the Case is filed.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrProactiveDetails_T1', @level2type=N'COLUMN',@level2name=N'StateCaseMatched_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Case Type.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrProactiveDetails_T1', @level2type=N'COLUMN',@level2name=N'TypeCaseMatched_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'County Code.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrProactiveDetails_T1', @level2type=N'COLUMN',@level2name=N'CountyFcrMatched_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Case Registration Date.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrProactiveDetails_T1', @level2type=N'COLUMN',@level2name=N'RegistrationMatched_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Case order existence indicator.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrProactiveDetails_T1', @level2type=N'COLUMN',@level2name=N'OrderCaseMatched_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Participant Type.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrProactiveDetails_T1', @level2type=N'COLUMN',@level2name=N'TypeParticipantMatched_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Member id.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrProactiveDetails_T1', @level2type=N'COLUMN',@level2name=N'MatchedMemberMci_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Member Date of Death.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrProactiveDetails_T1', @level2type=N'COLUMN',@level2name=N'DeathMatched_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Additional First Name of the Member.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrProactiveDetails_T1', @level2type=N'COLUMN',@level2name=N'F1AddtlMatched1_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Additional Middle Name of the Member.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrProactiveDetails_T1', @level2type=N'COLUMN',@level2name=N'M1AddtlMatched1_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Additional Last Name of the Member.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrProactiveDetails_T1', @level2type=N'COLUMN',@level2name=N'L1AddtlMatched1_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Additional First Name of the Member.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrProactiveDetails_T1', @level2type=N'COLUMN',@level2name=N'F1AddtlMatched2_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Additional Middle Name of the Member.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrProactiveDetails_T1', @level2type=N'COLUMN',@level2name=N'M1AddtlMatched2_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Additional Last Name of the Member.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrProactiveDetails_T1', @level2type=N'COLUMN',@level2name=N'L1AddtlMatched2_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Additional First Name of the Member.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrProactiveDetails_T1', @level2type=N'COLUMN',@level2name=N'F1AddtlMatched3_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Additional Middle Name of the Member.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrProactiveDetails_T1', @level2type=N'COLUMN',@level2name=N'M1AddtlMatched3_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Additional Last Name of the Member.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrProactiveDetails_T1', @level2type=N'COLUMN',@level2name=N'L1AddtlMatched3_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Additional First Name of the Member.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrProactiveDetails_T1', @level2type=N'COLUMN',@level2name=N'F1AddtlMatched4_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Additional Middle Name of the Member.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrProactiveDetails_T1', @level2type=N'COLUMN',@level2name=N'M1AddtlMatched4_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Additional Last Name of the Member.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrProactiveDetails_T1', @level2type=N'COLUMN',@level2name=N'L1AddtlMatched4_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Associated Person  Social Security No.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrProactiveDetails_T1', @level2type=N'COLUMN',@level2name=N'MemberAssociated1Ssn_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Associated Person 1 First Name.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrProactiveDetails_T1', @level2type=N'COLUMN',@level2name=N'F1Associated1_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Associated Person 1 Middle Name.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrProactiveDetails_T1', @level2type=N'COLUMN',@level2name=N'M1Associated1_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Associated Person 1 Last Name.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrProactiveDetails_T1', @level2type=N'COLUMN',@level2name=N'L1Associated1_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Associated Person 1  Sex.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrProactiveDetails_T1', @level2type=N'COLUMN',@level2name=N'MemberSexAssociated1_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Associated Person 1  Participant Type.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrProactiveDetails_T1', @level2type=N'COLUMN',@level2name=N'TypePartAssociated1_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Associated Person  1Member Id.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrProactiveDetails_T1', @level2type=N'COLUMN',@level2name=N'MemberMciAssociated1_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Associated Person 1 Date of Birth.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrProactiveDetails_T1', @level2type=N'COLUMN',@level2name=N'BirthAssociated1_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Associated Person 1  Death Date.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrProactiveDetails_T1', @level2type=N'COLUMN',@level2name=N'DeathAssociated1_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Associated Person  2 SSN.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrProactiveDetails_T1', @level2type=N'COLUMN',@level2name=N'MemberAssociated2Ssn_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Associated Person 2 First Name.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrProactiveDetails_T1', @level2type=N'COLUMN',@level2name=N'F1Associated2_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Associated Person 2 Middle Name.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrProactiveDetails_T1', @level2type=N'COLUMN',@level2name=N'M1Associated2_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Associated Person2  Last Name.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrProactiveDetails_T1', @level2type=N'COLUMN',@level2name=N'L1Associated2_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Associated Person2  Sex.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrProactiveDetails_T1', @level2type=N'COLUMN',@level2name=N'MemberSexAssociated2_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Associated Person 2 Participant Type.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrProactiveDetails_T1', @level2type=N'COLUMN',@level2name=N'TypePartAssociated2_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Associated Person2  Member Id.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrProactiveDetails_T1', @level2type=N'COLUMN',@level2name=N'MemberMciAssociated2_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Associated Person 2 Date of Birth.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrProactiveDetails_T1', @level2type=N'COLUMN',@level2name=N'BirthAssociated2_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Associated Person2  Death Date.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrProactiveDetails_T1', @level2type=N'COLUMN',@level2name=N'DeathAssociated2_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Associated Person 3 SSN.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrProactiveDetails_T1', @level2type=N'COLUMN',@level2name=N'MemberAssociated3Ssn_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Associated Person 3 First Name.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrProactiveDetails_T1', @level2type=N'COLUMN',@level2name=N'F1Associated3_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Associated Person 3 Middle Name.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrProactiveDetails_T1', @level2type=N'COLUMN',@level2name=N'M1Associated3_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Associated Person 3 Last Name.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrProactiveDetails_T1', @level2type=N'COLUMN',@level2name=N'L1Associated3_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Associated Person 3 Sex.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrProactiveDetails_T1', @level2type=N'COLUMN',@level2name=N'MemberSexAssociated3_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Associated Person 3 Participant Type.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrProactiveDetails_T1', @level2type=N'COLUMN',@level2name=N'TypePartAssociated3_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Associated Person 3 Member Id.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrProactiveDetails_T1', @level2type=N'COLUMN',@level2name=N'MemberMciAssociated3_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Associated Person 3 Date of Birth.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrProactiveDetails_T1', @level2type=N'COLUMN',@level2name=N'BirthAssociated3_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Associated Person 3 Death Date.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrProactiveDetails_T1', @level2type=N'COLUMN',@level2name=N'DeathAssociated3_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates Y if the record is processed otherwise N.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrProactiveDetails_T1', @level2type=N'COLUMN',@level2name=N'Process_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The date on which incoming file from Family court is loaded.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrProactiveDetails_T1', @level2type=N'COLUMN',@level2name=N'FileLoad_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'This table is used to store the proactive matches from FCR.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrProactiveDetails_T1'
GO
