USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractParticipantBlocks_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractParticipantBlocks_T1', @level2type=N'COLUMN',@level2name=N'BlockSeq_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractParticipantBlocks_T1', @level2type=N'COLUMN',@level2name=N'Transaction_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractParticipantBlocks_T1', @level2type=N'COLUMN',@level2name=N'IVDOutOfStateFips_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractParticipantBlocks_T1', @level2type=N'COLUMN',@level2name=N'ChildPaternityStatus_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractParticipantBlocks_T1', @level2type=N'COLUMN',@level2name=N'ChildStateResidence_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractParticipantBlocks_T1', @level2type=N'COLUMN',@level2name=N'PlaceOfBirth_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractParticipantBlocks_T1', @level2type=N'COLUMN',@level2name=N'WorkPhone_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractParticipantBlocks_T1', @level2type=N'COLUMN',@level2name=N'ConfirmedEmployer_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractParticipantBlocks_T1', @level2type=N'COLUMN',@level2name=N'ConfirmedEmployer_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractParticipantBlocks_T1', @level2type=N'COLUMN',@level2name=N'ConfirmedAddress_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractParticipantBlocks_T1', @level2type=N'COLUMN',@level2name=N'ConfirmedAddress_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractParticipantBlocks_T1', @level2type=N'COLUMN',@level2name=N'EinEmployer_ID'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractParticipantBlocks_T1', @level2type=N'COLUMN',@level2name=N'EmployerZip2_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractParticipantBlocks_T1', @level2type=N'COLUMN',@level2name=N'EmployerZip1_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractParticipantBlocks_T1', @level2type=N'COLUMN',@level2name=N'EmployerState_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractParticipantBlocks_T1', @level2type=N'COLUMN',@level2name=N'EmployerCity_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractParticipantBlocks_T1', @level2type=N'COLUMN',@level2name=N'EmployerLine2_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractParticipantBlocks_T1', @level2type=N'COLUMN',@level2name=N'EmployerLine1_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractParticipantBlocks_T1', @level2type=N'COLUMN',@level2name=N'Employer_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractParticipantBlocks_T1', @level2type=N'COLUMN',@level2name=N'ParticipantZip2_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractParticipantBlocks_T1', @level2type=N'COLUMN',@level2name=N'ParticipantZip1_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractParticipantBlocks_T1', @level2type=N'COLUMN',@level2name=N'ParticipantState_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractParticipantBlocks_T1', @level2type=N'COLUMN',@level2name=N'ParticipantCity_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractParticipantBlocks_T1', @level2type=N'COLUMN',@level2name=N'ParticipantLine2_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractParticipantBlocks_T1', @level2type=N'COLUMN',@level2name=N'ParticipantLine1_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractParticipantBlocks_T1', @level2type=N'COLUMN',@level2name=N'ChildRelationshipNcp_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractParticipantBlocks_T1', @level2type=N'COLUMN',@level2name=N'ParticipantStatus_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractParticipantBlocks_T1', @level2type=N'COLUMN',@level2name=N'Relationship_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractParticipantBlocks_T1', @level2type=N'COLUMN',@level2name=N'Race_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractParticipantBlocks_T1', @level2type=N'COLUMN',@level2name=N'MemberSex_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractParticipantBlocks_T1', @level2type=N'COLUMN',@level2name=N'MemberSsn_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractParticipantBlocks_T1', @level2type=N'COLUMN',@level2name=N'Birth_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractParticipantBlocks_T1', @level2type=N'COLUMN',@level2name=N'Suffix_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractParticipantBlocks_T1', @level2type=N'COLUMN',@level2name=N'Middle_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractParticipantBlocks_T1', @level2type=N'COLUMN',@level2name=N'First_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractParticipantBlocks_T1', @level2type=N'COLUMN',@level2name=N'Last_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractParticipantBlocks_T1', @level2type=N'COLUMN',@level2name=N'MemberMci_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractParticipantBlocks_T1', @level2type=N'COLUMN',@level2name=N'TransHeader_IDNO'

GO
/****** Object:  Table [dbo].[ExtractParticipantBlocks_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[ExtractParticipantBlocks_T1]
GO
/****** Object:  Table [dbo].[ExtractParticipantBlocks_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ExtractParticipantBlocks_T1](
	[TransHeader_IDNO] [char](12) NOT NULL,
	[MemberMci_IDNO] [numeric](10, 0) NOT NULL,
	[Last_NAME] [char](21) NOT NULL,
	[First_NAME] [char](16) NOT NULL,
	[Middle_NAME] [char](16) NOT NULL,
	[Suffix_NAME] [char](3) NOT NULL,
	[Birth_DATE] [date] NOT NULL,
	[MemberSsn_NUMB] [char](9) NOT NULL,
	[MemberSex_CODE] [char](8) NOT NULL,
	[Race_CODE] [char](1) NOT NULL,
	[Relationship_CODE] [char](1) NOT NULL,
	[ParticipantStatus_CODE] [char](1) NOT NULL,
	[ChildRelationshipNcp_CODE] [char](1) NOT NULL,
	[ParticipantLine1_ADDR] [char](25) NOT NULL,
	[ParticipantLine2_ADDR] [char](25) NOT NULL,
	[ParticipantCity_ADDR] [char](18) NOT NULL,
	[ParticipantState_ADDR] [char](2) NOT NULL,
	[ParticipantZip1_ADDR] [char](5) NOT NULL,
	[ParticipantZip2_ADDR] [char](4) NOT NULL,
	[Employer_NAME] [char](40) NOT NULL,
	[EmployerLine1_ADDR] [char](25) NOT NULL,
	[EmployerLine2_ADDR] [char](25) NOT NULL,
	[EmployerCity_ADDR] [char](18) NOT NULL,
	[EmployerState_ADDR] [char](2) NOT NULL,
	[EmployerZip1_ADDR] [char](5) NOT NULL,
	[EmployerZip2_ADDR] [char](4) NOT NULL,
	[EinEmployer_ID] [char](9) NOT NULL,
	[ConfirmedAddress_INDC] [char](1) NOT NULL,
	[ConfirmedAddress_DATE] [date] NOT NULL,
	[ConfirmedEmployer_INDC] [char](1) NOT NULL,
	[ConfirmedEmployer_DATE] [date] NOT NULL,
	[WorkPhone_NUMB] [numeric](10, 0) NOT NULL,
	[PlaceOfBirth_NAME] [char](25) NOT NULL,
	[ChildStateResidence_CODE] [char](2) NOT NULL,
	[ChildPaternityStatus_CODE] [char](1) NOT NULL,
	[IVDOutOfStateFips_CODE] [char](2) NOT NULL,
	[Transaction_DATE] [date] NOT NULL,
	[BlockSeq_NUMB] [numeric](2, 0) NOT NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The link to the TRANSACTION_HEADER_BLOCK record that holds the corresponding CSENet Transaction.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractParticipantBlocks_T1', @level2type=N'COLUMN',@level2name=N'TransHeader_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Member Id.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractParticipantBlocks_T1', @level2type=N'COLUMN',@level2name=N'MemberMci_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Last name of the participant.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractParticipantBlocks_T1', @level2type=N'COLUMN',@level2name=N'Last_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'First name of the participant.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractParticipantBlocks_T1', @level2type=N'COLUMN',@level2name=N'First_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Middle name of the participant.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractParticipantBlocks_T1', @level2type=N'COLUMN',@level2name=N'Middle_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Suffix for participants name e.g., III, Jr., etc.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractParticipantBlocks_T1', @level2type=N'COLUMN',@level2name=N'Suffix_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Participant’s Date of birth.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractParticipantBlocks_T1', @level2type=N'COLUMN',@level2name=N'Birth_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Participant’s Social Security Number.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractParticipantBlocks_T1', @level2type=N'COLUMN',@level2name=N'MemberSsn_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Participant’s gender.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractParticipantBlocks_T1', @level2type=N'COLUMN',@level2name=N'MemberSex_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Participant’s race.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractParticipantBlocks_T1', @level2type=N'COLUMN',@level2name=N'Race_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This field indicates the role of this particular Participant to the case.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractParticipantBlocks_T1', @level2type=N'COLUMN',@level2name=N'Relationship_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates whether the participant is an active member in this case.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractParticipantBlocks_T1', @level2type=N'COLUMN',@level2name=N'ParticipantStatus_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This field is used if the Participant is a dependent. It describes the relationship of the dependent to the custodial party in the case.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractParticipantBlocks_T1', @level2type=N'COLUMN',@level2name=N'ChildRelationshipNcp_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Address of the participant.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractParticipantBlocks_T1', @level2type=N'COLUMN',@level2name=N'ParticipantLine1_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Address of the participant.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractParticipantBlocks_T1', @level2type=N'COLUMN',@level2name=N'ParticipantLine2_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'City of the Participant.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractParticipantBlocks_T1', @level2type=N'COLUMN',@level2name=N'ParticipantCity_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'State of the Participant.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractParticipantBlocks_T1', @level2type=N'COLUMN',@level2name=N'ParticipantState_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Five-digit zip code of the Participant.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractParticipantBlocks_T1', @level2type=N'COLUMN',@level2name=N'ParticipantZip1_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Four-digit zip code of the Participant.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractParticipantBlocks_T1', @level2type=N'COLUMN',@level2name=N'ParticipantZip2_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Employer name of the Participant..' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractParticipantBlocks_T1', @level2type=N'COLUMN',@level2name=N'Employer_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Employer address of the Participant.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractParticipantBlocks_T1', @level2type=N'COLUMN',@level2name=N'EmployerLine1_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Employer address of the Participant.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractParticipantBlocks_T1', @level2type=N'COLUMN',@level2name=N'EmployerLine2_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Employer City of the Participant.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractParticipantBlocks_T1', @level2type=N'COLUMN',@level2name=N'EmployerCity_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Employer State of the Participant.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractParticipantBlocks_T1', @level2type=N'COLUMN',@level2name=N'EmployerState_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Employer Zip1 code.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractParticipantBlocks_T1', @level2type=N'COLUMN',@level2name=N'EmployerZip1_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Employer Zip2 code.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractParticipantBlocks_T1', @level2type=N'COLUMN',@level2name=N'EmployerZip2_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Employer Federal Employer Identification Number (EIN).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractParticipantBlocks_T1', @level2type=N'COLUMN',@level2name=N'EinEmployer_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates if address is valid.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractParticipantBlocks_T1', @level2type=N'COLUMN',@level2name=N'ConfirmedAddress_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Date address confirmed.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractParticipantBlocks_T1', @level2type=N'COLUMN',@level2name=N'ConfirmedAddress_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicator if employer listed has been confirmed.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractParticipantBlocks_T1', @level2type=N'COLUMN',@level2name=N'ConfirmedEmployer_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Date employer confirmed.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractParticipantBlocks_T1', @level2type=N'COLUMN',@level2name=N'ConfirmedEmployer_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Participant work phone number.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractParticipantBlocks_T1', @level2type=N'COLUMN',@level2name=N'WorkPhone_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Participant place of birth.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractParticipantBlocks_T1', @level2type=N'COLUMN',@level2name=N'PlaceOfBirth_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This field is used if the participant is a dependent.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractParticipantBlocks_T1', @level2type=N'COLUMN',@level2name=N'ChildStateResidence_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'For dependents only (Relationship = D).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractParticipantBlocks_T1', @level2type=N'COLUMN',@level2name=N'ChildPaternityStatus_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'State FIPS for the state with which you are communicating.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractParticipantBlocks_T1', @level2type=N'COLUMN',@level2name=N'IVDOutOfStateFips_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Transaction Date.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractParticipantBlocks_T1', @level2type=N'COLUMN',@level2name=N'Transaction_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Block Serial Number.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractParticipantBlocks_T1', @level2type=N'COLUMN',@level2name=N'BlockSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'This is a staging table to hold data for Case Participants Data Block and carry out validations for outbound CSENET transaction' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractParticipantBlocks_T1'
GO
