USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CaseMembers_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'NULL' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CaseMembers_T1', @level2type=N'COLUMN',@level2name=N'TypeFamilyViolence_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'NULL' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CaseMembers_T1', @level2type=N'COLUMN',@level2name=N'FamilyViolence_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'NULL' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CaseMembers_T1', @level2type=N'COLUMN',@level2name=N'FamilyViolence_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CaseMembers_T1', @level2type=N'COLUMN',@level2name=N'Update_DTTM'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CaseMembers_T1', @level2type=N'COLUMN',@level2name=N'TransactionEventSeq_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CaseMembers_T1', @level2type=N'COLUMN',@level2name=N'WorkerUpdate_ID'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CaseMembers_T1', @level2type=N'COLUMN',@level2name=N'BeginValidity_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CaseMembers_T1', @level2type=N'COLUMN',@level2name=N'Applicant_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CaseMembers_T1', @level2type=N'COLUMN',@level2name=N'ReasonMemberStatus_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CaseMembers_T1', @level2type=N'COLUMN',@level2name=N'BenchWarrant_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CaseMembers_T1', @level2type=N'COLUMN',@level2name=N'NcpRelationshipToChild_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CaseMembers_T1', @level2type=N'COLUMN',@level2name=N'CpRelationshipToChild_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CaseMembers_T1', @level2type=N'COLUMN',@level2name=N'CaseMemberStatus_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CaseMembers_T1', @level2type=N'COLUMN',@level2name=N'CaseRelationship_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'2' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CaseMembers_T1', @level2type=N'COLUMN',@level2name=N'MemberMci_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CaseMembers_T1', @level2type=N'COLUMN',@level2name=N'Case_IDNO'

GO
/****** Object:  Index [CMEM_MEMBER_CASE_STATUS_I1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP INDEX [CMEM_MEMBER_CASE_STATUS_I1] ON [dbo].[CaseMembers_T1]
GO
/****** Object:  Index [CMEM_MEMBER_CASE_I1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP INDEX [CMEM_MEMBER_CASE_I1] ON [dbo].[CaseMembers_T1]
GO
/****** Object:  Table [dbo].[CaseMembers_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[CaseMembers_T1]
GO
/****** Object:  Table [dbo].[CaseMembers_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[CaseMembers_T1](
	[Case_IDNO] [numeric](6, 0) NOT NULL,
	[MemberMci_IDNO] [numeric](10, 0) NOT NULL,
	[CaseRelationship_CODE] [char](1) NOT NULL,
	[CaseMemberStatus_CODE] [char](1) NOT NULL,
	[CpRelationshipToChild_CODE] [char](3) NOT NULL,
	[NcpRelationshipToChild_CODE] [char](3) NOT NULL,
	[BenchWarrant_INDC] [char](1) NOT NULL,
	[ReasonMemberStatus_CODE] [char](2) NOT NULL,
	[Applicant_CODE] [char](1) NOT NULL,
	[BeginValidity_DATE] [date] NOT NULL,
	[WorkerUpdate_ID] [char](30) NOT NULL,
	[TransactionEventSeq_NUMB] [numeric](19, 0) NOT NULL,
	[Update_DTTM] [datetime2](7) NOT NULL,
	[FamilyViolence_DATE] [date] NOT NULL,
	[FamilyViolence_INDC] [char](1) NOT NULL,
	[TypeFamilyViolence_CODE] [char](2) NOT NULL,
 CONSTRAINT [CMEM_I1] PRIMARY KEY CLUSTERED 
(
	[Case_IDNO] ASC,
	[MemberMci_IDNO] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [CMEM_MEMBER_CASE_I1]    Script Date: 4/7/2015 12:53:07 PM ******/
CREATE NONCLUSTERED INDEX [CMEM_MEMBER_CASE_I1] ON [dbo].[CaseMembers_T1]
(
	[Case_IDNO] ASC,
	[MemberMci_IDNO] ASC,
	[CaseRelationship_CODE] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [CMEM_MEMBER_CASE_STATUS_I1]    Script Date: 4/7/2015 12:53:07 PM ******/
CREATE NONCLUSTERED INDEX [CMEM_MEMBER_CASE_STATUS_I1] ON [dbo].[CaseMembers_T1]
(
	[MemberMci_IDNO] ASC,
	[CaseRelationship_CODE] ASC,
	[CaseMemberStatus_CODE] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
EXEC sys.sp_addextendedproperty @name=N'1', @value=N'Unique ID generated for the DACSES Case.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CaseMembers_T1', @level2type=N'COLUMN',@level2name=N'Case_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'2', @value=N'Unique ID Assigned to the Member.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CaseMembers_T1', @level2type=N'COLUMN',@level2name=N'MemberMci_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicate the Members Case Relation. Values retrieved from REFM (RELA/CASE).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CaseMembers_T1', @level2type=N'COLUMN',@level2name=N'CaseRelationship_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the Member Status on the Case. Values are obtained from REFM (GENR/MEMS).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CaseMembers_T1', @level2type=N'COLUMN',@level2name=N'CaseMemberStatus_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the Relation Code of the CP to Dependent. Values are obtained from REFM (FMLY/RELA).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CaseMembers_T1', @level2type=N'COLUMN',@level2name=N'CpRelationshipToChild_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the Relation Code of the NCP to Dependent. Values are obtained from REFM (FMLY/RELA).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CaseMembers_T1', @level2type=N'COLUMN',@level2name=N'NcpRelationshipToChild_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicator for Bench Warrant. Values are obtained from REFM (YSNO/YSNO).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CaseMembers_T1', @level2type=N'COLUMN',@level2name=N'BenchWarrant_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Reason Member Status is inactive. Values are obtained from REFM (GENR/ MSTR).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CaseMembers_T1', @level2type=N'COLUMN',@level2name=N'ReasonMemberStatus_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicator to know whether the Member associated with the Case is the Applicant. Values are obtained from REFM (YSNO/YSNO).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CaseMembers_T1', @level2type=N'COLUMN',@level2name=N'Applicant_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The Effective date from when the Changed Information is Valid.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CaseMembers_T1', @level2type=N'COLUMN',@level2name=N'BeginValidity_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the worker ID who created/modified this record.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CaseMembers_T1', @level2type=N'COLUMN',@level2name=N'WorkerUpdate_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Unique Sequence Number that will be generated for a Transaction on the Table. This field is used for checking concurrency at the time of online transaction updates.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CaseMembers_T1', @level2type=N'COLUMN',@level2name=N'TransactionEventSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the effective Date with Time at which this record was inserted / modified in this table.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CaseMembers_T1', @level2type=N'COLUMN',@level2name=N'Update_DTTM'
GO
EXEC sys.sp_addextendedproperty @name=N'NULL', @value=N'Indicates the Family Violence Date.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CaseMembers_T1', @level2type=N'COLUMN',@level2name=N'FamilyViolence_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'NULL', @value=N'Indicates the Family Violence Indicator. Values are obtained from REFM (YSNO/YSNO)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CaseMembers_T1', @level2type=N'COLUMN',@level2name=N'FamilyViolence_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'NULL', @value=N'Type of Family Violence. Values are obtained from REFM (DEMO/VIOL)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CaseMembers_T1', @level2type=N'COLUMN',@level2name=N'TypeFamilyViolence_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'This table stores the member MCI''s associated to a given IV-D case along with the relationship and member''s status to the case. All Records in this table are valid rows. The end-dated records are stored in a This table stores the member MCIs associated to a given IV-D case along with the relationship and member''s status to the case. All Records in this table are valid rows. The end-dated records are stored in a separate history table.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CaseMembers_T1'
GO
