USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpPaidRecoup_P1'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpPaidRecoup_P1', @level2type=N'COLUMN',@level2name=N'ArrPaidMtdUrg_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpPaidRecoup_P1', @level2type=N'COLUMN',@level2name=N'ArrPaidUrg_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpPaidRecoup_P1', @level2type=N'COLUMN',@level2name=N'ArrRecoupMtd_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpPaidRecoup_P1', @level2type=N'COLUMN',@level2name=N'ArrPaidMtd_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpPaidRecoup_P1', @level2type=N'COLUMN',@level2name=N'ArrToBePaid_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpPaidRecoup_P1', @level2type=N'COLUMN',@level2name=N'RoundedRecoup_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpPaidRecoup_P1', @level2type=N'COLUMN',@level2name=N'Rounded_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpPaidRecoup_P1', @level2type=N'COLUMN',@level2name=N'ArrRecoup_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpPaidRecoup_P1', @level2type=N'COLUMN',@level2name=N'ArrPaid_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpPaidRecoup_P1', @level2type=N'COLUMN',@level2name=N'CaseWelfare_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpPaidRecoup_P1', @level2type=N'COLUMN',@level2name=N'TypeBucket_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpPaidRecoup_P1', @level2type=N'COLUMN',@level2name=N'ObligationSeq_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpPaidRecoup_P1', @level2type=N'COLUMN',@level2name=N'OrderSeq_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpPaidRecoup_P1', @level2type=N'COLUMN',@level2name=N'Case_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpPaidRecoup_P1', @level2type=N'COLUMN',@level2name=N'MemberMci_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpPaidRecoup_P1', @level2type=N'COLUMN',@level2name=N'Seq_IDNO'

GO
/****** Object:  Table [dbo].[TmpPaidRecoup_P1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[TmpPaidRecoup_P1]
GO
/****** Object:  Table [dbo].[TmpPaidRecoup_P1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[TmpPaidRecoup_P1](
	[Seq_IDNO] [numeric](19, 0) NOT NULL,
	[MemberMci_IDNO] [numeric](10, 0) NOT NULL,
	[Case_IDNO] [numeric](6, 0) NOT NULL,
	[OrderSeq_NUMB] [numeric](2, 0) NOT NULL,
	[ObligationSeq_NUMB] [numeric](2, 0) NOT NULL,
	[TypeBucket_CODE] [char](5) NOT NULL,
	[CaseWelfare_IDNO] [numeric](10, 0) NOT NULL,
	[ArrPaid_AMNT] [numeric](11, 2) NOT NULL,
	[ArrRecoup_AMNT] [numeric](11, 2) NOT NULL,
	[Rounded_AMNT] [numeric](11, 2) NOT NULL,
	[RoundedRecoup_AMNT] [numeric](11, 2) NOT NULL,
	[ArrToBePaid_AMNT] [numeric](11, 2) NOT NULL,
	[ArrPaidMtd_AMNT] [numeric](11, 2) NOT NULL,
	[ArrRecoupMtd_AMNT] [numeric](11, 2) NOT NULL,
	[ArrPaidUrg_AMNT] [numeric](11, 2) NOT NULL,
	[ArrPaidMtdUrg_AMNT] [numeric](11, 2) NOT NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Specifies the system generated sequence number to maintain uniqueness.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpPaidRecoup_P1', @level2type=N'COLUMN',@level2name=N'Seq_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The Beneficiary (CP / Dependent) MCI id for this Obligation against whom the Recoupment is made towards Overpayment.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpPaidRecoup_P1', @level2type=N'COLUMN',@level2name=N'MemberMci_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Unique ID generated for the DACSES Case.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpPaidRecoup_P1', @level2type=N'COLUMN',@level2name=N'Case_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This is a system generated internal order sequence number created for a support order for a given case. Each SEQ_ORDER corresponds to a Support Order from the SUPPORT_ORDER table for a given Case ID.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpPaidRecoup_P1', @level2type=N'COLUMN',@level2name=N'OrderSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Internal reference code to uniquely identify an Obligation.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpPaidRecoup_P1', @level2type=N'COLUMN',@level2name=N'ObligationSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This is the type of Disbursement for the Amount. Possible values are C - Current Support, E - Payback Amount, ANAA - Arrears NA, APAA - Arrears PA, AUDA - Arrears UDA, ACAA - Arrears CA, AIVEF - Arrears IVEF, AMEDI - Arrears MEDI, ANFFC - Arrears NFFC, ANIVD - Arrears NIVD, ATAA - Arrears TA and AUPA - Arrears UPA.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpPaidRecoup_P1', @level2type=N'COLUMN',@level2name=N'TypeBucket_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Welfare Case ID, Created at CP level when any one dependant of the CP is in welfare program.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpPaidRecoup_P1', @level2type=N'COLUMN',@level2name=N'CaseWelfare_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The Amount paid towards arrear in this transaction.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpPaidRecoup_P1', @level2type=N'COLUMN',@level2name=N'ArrPaid_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Amount of Arrear recouped from this Transaction.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpPaidRecoup_P1', @level2type=N'COLUMN',@level2name=N'ArrRecoup_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This is the internal adjustment to round off to next 1 Cent.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpPaidRecoup_P1', @level2type=N'COLUMN',@level2name=N'Rounded_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This is the Recouped Amount after Round Off to next 1 Cent.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpPaidRecoup_P1', @level2type=N'COLUMN',@level2name=N'RoundedRecoup_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Balance Arrear to be paid.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpPaidRecoup_P1', @level2type=N'COLUMN',@level2name=N'ArrToBePaid_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Total Arrear Paid Month to Date for this Obligation.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpPaidRecoup_P1', @level2type=N'COLUMN',@level2name=N'ArrPaidMtd_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Amount of Arrear recouped Month to Date.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpPaidRecoup_P1', @level2type=N'COLUMN',@level2name=N'ArrRecoupMtd_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Amount Paid for UN Reimbursed Grant.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpPaidRecoup_P1', @level2type=N'COLUMN',@level2name=N'ArrPaidUrg_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Total Arrear Paid Month to Date for this Obligation against UN Reimbursed Grant.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpPaidRecoup_P1', @level2type=N'COLUMN',@level2name=N'ArrPaidMtdUrg_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'This is global temporary table used by RREP screen to calculate the over disbursement details for every receipt that is being reversed' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpPaidRecoup_P1'
GO
