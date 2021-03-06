USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDetention_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDetention_T1', @level2type=N'COLUMN',@level2name=N'ReleaseReason_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDetention_T1', @level2type=N'COLUMN',@level2name=N'InstitutionStatus_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDetention_T1', @level2type=N'COLUMN',@level2name=N'WorkRelease_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDetention_T1', @level2type=N'COLUMN',@level2name=N'OthpPartyProbation_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDetention_T1', @level2type=N'COLUMN',@level2name=N'MaxRelease_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDetention_T1', @level2type=N'COLUMN',@level2name=N'ProbationOfficer_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDetention_T1', @level2type=N'COLUMN',@level2name=N'EndValidity_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDetention_T1', @level2type=N'COLUMN',@level2name=N'BeginValidity_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDetention_T1', @level2type=N'COLUMN',@level2name=N'Update_DTTM'

GO
EXEC sys.sp_dropextendedproperty @name=N'2' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDetention_T1', @level2type=N'COLUMN',@level2name=N'TransactionEventSeq_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDetention_T1', @level2type=N'COLUMN',@level2name=N'WorkerUpdate_ID'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDetention_T1', @level2type=N'COLUMN',@level2name=N'Sentence_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDetention_T1', @level2type=N'COLUMN',@level2name=N'DescriptionHold_TEXT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDetention_T1', @level2type=N'COLUMN',@level2name=N'PhoneParoleOffice_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDetention_T1', @level2type=N'COLUMN',@level2name=N'ParoleOfficer_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDetention_T1', @level2type=N'COLUMN',@level2name=N'InstFbin_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDetention_T1', @level2type=N'COLUMN',@level2name=N'InstSbin_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDetention_T1', @level2type=N'COLUMN',@level2name=N'ParoleReason_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDetention_T1', @level2type=N'COLUMN',@level2name=N'Inmate_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDetention_T1', @level2type=N'COLUMN',@level2name=N'MoveType_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDetention_T1', @level2type=N'COLUMN',@level2name=N'EligParole_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDetention_T1', @level2type=N'COLUMN',@level2name=N'Release_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDetention_T1', @level2type=N'COLUMN',@level2name=N'Incarceration_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDetention_T1', @level2type=N'COLUMN',@level2name=N'Institutionalized_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDetention_T1', @level2type=N'COLUMN',@level2name=N'PoliceDept_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDetention_T1', @level2type=N'COLUMN',@level2name=N'TypeInst_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDetention_T1', @level2type=N'COLUMN',@level2name=N'Institution_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDetention_T1', @level2type=N'COLUMN',@level2name=N'Institution_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDetention_T1', @level2type=N'COLUMN',@level2name=N'MemberMci_IDNO'

GO
/****** Object:  Table [dbo].[MemberDetention_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[MemberDetention_T1]
GO
/****** Object:  Table [dbo].[MemberDetention_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[MemberDetention_T1](
	[MemberMci_IDNO] [numeric](10, 0) NOT NULL,
	[Institution_IDNO] [numeric](9, 0) NOT NULL,
	[Institution_NAME] [char](30) NOT NULL,
	[TypeInst_CODE] [char](2) NOT NULL,
	[PoliceDept_IDNO] [numeric](15, 0) NOT NULL,
	[Institutionalized_DATE] [date] NOT NULL,
	[Incarceration_DATE] [date] NOT NULL,
	[Release_DATE] [date] NOT NULL,
	[EligParole_DATE] [date] NOT NULL,
	[MoveType_CODE] [char](2) NOT NULL,
	[Inmate_NUMB] [numeric](15, 0) NOT NULL,
	[ParoleReason_CODE] [char](4) NOT NULL,
	[InstSbin_IDNO] [numeric](10, 0) NOT NULL,
	[InstFbin_IDNO] [numeric](9, 0) NOT NULL,
	[ParoleOfficer_NAME] [varchar](50) NOT NULL,
	[PhoneParoleOffice_NUMB] [numeric](15, 0) NOT NULL,
	[DescriptionHold_TEXT] [varchar](70) NOT NULL,
	[Sentence_CODE] [char](2) NOT NULL,
	[WorkerUpdate_ID] [char](30) NOT NULL,
	[TransactionEventSeq_NUMB] [numeric](19, 0) NOT NULL,
	[Update_DTTM] [datetime2](7) NOT NULL,
	[BeginValidity_DATE] [date] NOT NULL,
	[EndValidity_DATE] [date] NOT NULL,
	[ProbationOfficer_NAME] [varchar](50) NOT NULL,
	[MaxRelease_DATE] [date] NOT NULL,
	[OthpPartyProbation_IDNO] [numeric](9, 0) NOT NULL,
	[WorkRelease_INDC] [char](1) NOT NULL,
	[InstitutionStatus_CODE] [char](1) NOT NULL,
	[ReleaseReason_CODE] [char](4) NOT NULL,
 CONSTRAINT [MDET_I1] PRIMARY KEY CLUSTERED 
(
	[MemberMci_IDNO] ASC,
	[TransactionEventSeq_NUMB] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
EXEC sys.sp_addextendedproperty @name=N'1', @value=N'Unique System generated Id for the Member.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDetention_T1', @level2type=N'COLUMN',@level2name=N'MemberMci_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the Id of the Institution where the Member is Institutionalized.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDetention_T1', @level2type=N'COLUMN',@level2name=N'Institution_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the Name of the Institution.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDetention_T1', @level2type=N'COLUMN',@level2name=N'Institution_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the Type of the Institution. Values are retrieved from REFM (DEMO/TYPE).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDetention_T1', @level2type=N'COLUMN',@level2name=N'TypeInst_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the Police ID.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDetention_T1', @level2type=N'COLUMN',@level2name=N'PoliceDept_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the Date on which the Member was Institutionalized.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDetention_T1', @level2type=N'COLUMN',@level2name=N'Institutionalized_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the Date on which the Member was Incarcerated.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDetention_T1', @level2type=N'COLUMN',@level2name=N'Incarceration_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the Date on which the Member was Released.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDetention_T1', @level2type=N'COLUMN',@level2name=N'Release_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the Date on which the Member Is eligible for Parole.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDetention_T1', @level2type=N'COLUMN',@level2name=N'EligParole_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the Movement Type of the Member during Parole. Values are retrieved from REFM (DEMO/MOVE).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDetention_T1', @level2type=N'COLUMN',@level2name=N'MoveType_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the Members Inmate number.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDetention_T1', @level2type=N'COLUMN',@level2name=N'Inmate_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the Parole Reason of the Member. Values are retrieved from REFM (DEMO/INST).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDetention_T1', @level2type=N'COLUMN',@level2name=N'ParoleReason_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the SEIN Number of Institution.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDetention_T1', @level2type=N'COLUMN',@level2name=N'InstSbin_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the FEIN Number of the Institution.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDetention_T1', @level2type=N'COLUMN',@level2name=N'InstFbin_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the Parole Officer Name.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDetention_T1', @level2type=N'COLUMN',@level2name=N'ParoleOfficer_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the Parole Officer''s Phone Number.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDetention_T1', @level2type=N'COLUMN',@level2name=N'PhoneParoleOffice_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the Description of the Hold.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDetention_T1', @level2type=N'COLUMN',@level2name=N'DescriptionHold_TEXT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the Life or Death Sentence of the Member. Values are retrieved from REFM (DEMO/SENT).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDetention_T1', @level2type=N'COLUMN',@level2name=N'Sentence_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the worker ID who created/modified this record.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDetention_T1', @level2type=N'COLUMN',@level2name=N'WorkerUpdate_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'2', @value=N'Unique Sequence Number that will be  generated for any given transaction on the Table. This field is used for checking concurrency at the time of online transaction updates.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDetention_T1', @level2type=N'COLUMN',@level2name=N'TransactionEventSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the effective Date with Time at which this record was inserted / modified in this table.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDetention_T1', @level2type=N'COLUMN',@level2name=N'Update_DTTM'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The Effective date from when the Changed Information will be  Valid.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDetention_T1', @level2type=N'COLUMN',@level2name=N'BeginValidity_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The  Effective date up to which the Changed Information will be  Valid.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDetention_T1', @level2type=N'COLUMN',@level2name=N'EndValidity_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the Probation Officer name.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDetention_T1', @level2type=N'COLUMN',@level2name=N'ProbationOfficer_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the Date on which the Member was actually Released.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDetention_T1', @level2type=N'COLUMN',@level2name=N'MaxRelease_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the Other Party Probation Id.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDetention_T1', @level2type=N'COLUMN',@level2name=N'OthpPartyProbation_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The member Institution Work Release (YSNO/YSNO)                      Y-Yes                       N-No' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDetention_T1', @level2type=N'COLUMN',@level2name=N'WorkRelease_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The member Institution Status (BWNT/STAT). Possible values are A - Active, I - Inactive' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDetention_T1', @level2type=N'COLUMN',@level2name=N'InstitutionStatus_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Reason the NCP was released from the institution. . For the possible values please refer the table MaintenanceRef_T1: GENR/ASTS' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDetention_T1', @level2type=N'COLUMN',@level2name=N'ReleaseReason_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'This table stores the Detention Information of the Members if there are any. This table stores valid records as well as history records which follows the temporal model structure.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MemberDetention_T1'
GO
