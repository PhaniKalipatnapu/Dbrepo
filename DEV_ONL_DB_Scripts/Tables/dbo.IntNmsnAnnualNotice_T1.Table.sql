USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'COMMENT' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntNmsnAnnualNotice_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntNmsnAnnualNotice_T1', @level2type=N'COLUMN',@level2name=N'Process_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntNmsnAnnualNotice_T1', @level2type=N'COLUMN',@level2name=N'OthpEmployer_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntNmsnAnnualNotice_T1', @level2type=N'COLUMN',@level2name=N'InsuranceOrdered_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntNmsnAnnualNotice_T1', @level2type=N'COLUMN',@level2name=N'CaseRelationship_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntNmsnAnnualNotice_T1', @level2type=N'COLUMN',@level2name=N'MemberMci_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntNmsnAnnualNotice_T1', @level2type=N'COLUMN',@level2name=N'Case_IDNO'

GO
/****** Object:  Table [dbo].[IntNmsnAnnualNotice_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[IntNmsnAnnualNotice_T1]
GO
/****** Object:  Table [dbo].[IntNmsnAnnualNotice_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[IntNmsnAnnualNotice_T1](
	[Seq_IDNO] [numeric](19, 0) IDENTITY(1,1) NOT NULL,
	[Case_IDNO] [numeric](6, 0) NOT NULL,
	[MemberMci_IDNO] [numeric](10, 0) NOT NULL,
	[CaseRelationship_CODE] [char](1) NOT NULL,
	[InsuranceOrdered_CODE] [char](1) NOT NULL,
	[OthpEmployer_IDNO] [numeric](9, 0) NOT NULL,
	[Process_INDC] [char](1) NOT NULL,
 CONSTRAINT [PNMSN_I1] PRIMARY KEY CLUSTERED 
(
	[Seq_IDNO] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The Case ID of the member for whom the Remedy is being enforced.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntNmsnAnnualNotice_T1', @level2type=N'COLUMN',@level2name=N'Case_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Unique number assigned by the system to the Member.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntNmsnAnnualNotice_T1', @level2type=N'COLUMN',@level2name=N'MemberMci_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the Members Case Relation. Possible values are C - CP, A -  NCP, P -  PUTATIVE.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntNmsnAnnualNotice_T1', @level2type=N'COLUMN',@level2name=N'CaseRelationship_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates who was ordered by court to provide the insurance. Values are obtained from REFM (8670 / 8670).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntNmsnAnnualNotice_T1', @level2type=N'COLUMN',@level2name=N'InsuranceOrdered_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Unique number assigned by the system to the employer.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntNmsnAnnualNotice_T1', @level2type=N'COLUMN',@level2name=N'OthpEmployer_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This indicates status of records. Values are              Y - Processed records             N- Not processed records,             A- Aborted records,             L - Locked records,            E- BATE_V1 exemption records' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntNmsnAnnualNotice_T1', @level2type=N'COLUMN',@level2name=N'Process_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'COMMENT', @value=N'This table is used to store the records to be processed by BATCH_ENF_NMSN_ANNUAL_NOTICES batch.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntNmsnAnnualNotice_T1'
GO
