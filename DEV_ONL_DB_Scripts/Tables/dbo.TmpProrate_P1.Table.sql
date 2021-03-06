USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpProrate_P1'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpProrate_P1', @level2type=N'COLUMN',@level2name=N'MemberUnreimbGrant_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpProrate_P1', @level2type=N'COLUMN',@level2name=N'PerMemberRecoupment_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpProrate_P1', @level2type=N'COLUMN',@level2name=N'PerMemberProrated_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpProrate_P1', @level2type=N'COLUMN',@level2name=N'ArrToBePaid_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpProrate_P1', @level2type=N'COLUMN',@level2name=N'CaseWelfare_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpProrate_P1', @level2type=N'COLUMN',@level2name=N'TypeBucket_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpProrate_P1', @level2type=N'COLUMN',@level2name=N'ObligationSeq_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpProrate_P1', @level2type=N'COLUMN',@level2name=N'OrderSeq_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpProrate_P1', @level2type=N'COLUMN',@level2name=N'Case_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpProrate_P1', @level2type=N'COLUMN',@level2name=N'MemberMci_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpProrate_P1', @level2type=N'COLUMN',@level2name=N'PrDistribute_QNTY'

GO
/****** Object:  Table [dbo].[TmpProrate_P1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[TmpProrate_P1]
GO
/****** Object:  Table [dbo].[TmpProrate_P1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[TmpProrate_P1](
	[PrDistribute_QNTY] [numeric](5, 0) NOT NULL,
	[MemberMci_IDNO] [numeric](10, 0) NOT NULL,
	[Case_IDNO] [numeric](6, 0) NOT NULL,
	[OrderSeq_NUMB] [numeric](2, 0) NOT NULL,
	[ObligationSeq_NUMB] [numeric](2, 0) NOT NULL,
	[TypeBucket_CODE] [char](5) NOT NULL,
	[CaseWelfare_IDNO] [numeric](10, 0) NOT NULL,
	[ArrToBePaid_AMNT] [numeric](11, 2) NOT NULL,
	[PerMemberProrated_AMNT] [numeric](11, 2) NOT NULL,
	[PerMemberRecoupment_AMNT] [numeric](11, 2) NOT NULL,
	[MemberUnreimbGrant_AMNT] [numeric](11, 2) NOT NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Internal reference code to give Order of Priority to different receipt source and Arrear types.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpProrate_P1', @level2type=N'COLUMN',@level2name=N'PrDistribute_QNTY'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The Beneficiary (CP / Dependent) MCI id for this Obligation.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpProrate_P1', @level2type=N'COLUMN',@level2name=N'MemberMci_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Unique ID generated for the DACSES Case.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpProrate_P1', @level2type=N'COLUMN',@level2name=N'Case_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This is a system generated internal order sequence number created for a support order for a given case. Each SEQ_ORDER corresponds to a Support Order from the SUPPORT_ORDER table for a given Case ID.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpProrate_P1', @level2type=N'COLUMN',@level2name=N'OrderSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Internal reference code to uniquely identify an Obligation.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpProrate_P1', @level2type=N'COLUMN',@level2name=N'ObligationSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This is the type of Disbursement for the Amount. Possible values are C - Current Support, E - Payback Amount, ANAA - Arrears NA, APAA - Arrears PA, AUDA - Arrears UDA, ACAA - Arrears CA, AIVEF - Arrears IVEF, AMEDI - Arrears MEDI, ANFFC - Arrears NFFC, ANIVD - Arrears NIVD, ATAA - Arrears TA and AUPA - Arrears UPA.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpProrate_P1', @level2type=N'COLUMN',@level2name=N'TypeBucket_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Welfare Case ID, Created at CP level when any one dependant of the CP is in welfare program.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpProrate_P1', @level2type=N'COLUMN',@level2name=N'CaseWelfare_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Balance Arrear to be paid.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpProrate_P1', @level2type=N'COLUMN',@level2name=N'ArrToBePaid_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Amt prorated per member.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpProrate_P1', @level2type=N'COLUMN',@level2name=N'PerMemberProrated_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Amt recovered.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpProrate_P1', @level2type=N'COLUMN',@level2name=N'PerMemberRecoupment_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Unreimbursed Grant Amount for the member.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpProrate_P1', @level2type=N'COLUMN',@level2name=N'MemberUnreimbGrant_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'This is global temporary table that is used the Grant proration that prorates the IVA case grant to the IVD Case obligations' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpProrate_P1'
GO
