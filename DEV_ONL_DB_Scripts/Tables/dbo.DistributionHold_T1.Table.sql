USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DistributionHold_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DistributionHold_T1', @level2type=N'COLUMN',@level2name=N'EndValidity_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DistributionHold_T1', @level2type=N'COLUMN',@level2name=N'BeginValidity_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DistributionHold_T1', @level2type=N'COLUMN',@level2name=N'EventGlobalEndSeq_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'4' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DistributionHold_T1', @level2type=N'COLUMN',@level2name=N'EventGlobalBeginSeq_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DistributionHold_T1', @level2type=N'COLUMN',@level2name=N'Sequence_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DistributionHold_T1', @level2type=N'COLUMN',@level2name=N'Expiration_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DistributionHold_T1', @level2type=N'COLUMN',@level2name=N'Effective_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DistributionHold_T1', @level2type=N'COLUMN',@level2name=N'ReasonHold_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'3' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DistributionHold_T1', @level2type=N'COLUMN',@level2name=N'SourceHold_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'2' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DistributionHold_T1', @level2type=N'COLUMN',@level2name=N'TypeHold_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DistributionHold_T1', @level2type=N'COLUMN',@level2name=N'CasePayorMCI_IDNO'

GO
/****** Object:  Table [dbo].[DistributionHold_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[DistributionHold_T1]
GO
/****** Object:  Table [dbo].[DistributionHold_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[DistributionHold_T1](
	[CasePayorMCI_IDNO] [numeric](10, 0) NOT NULL,
	[TypeHold_CODE] [char](1) NOT NULL,
	[SourceHold_CODE] [char](2) NOT NULL,
	[ReasonHold_CODE] [char](4) NOT NULL,
	[Effective_DATE] [date] NOT NULL,
	[Expiration_DATE] [date] NOT NULL,
	[Sequence_NUMB] [numeric](11, 0) NOT NULL,
	[EventGlobalBeginSeq_NUMB] [numeric](19, 0) NOT NULL,
	[EventGlobalEndSeq_NUMB] [numeric](19, 0) NOT NULL,
	[BeginValidity_DATE] [date] NOT NULL,
	[EndValidity_DATE] [date] NOT NULL,
 CONSTRAINT [DISH_I1] PRIMARY KEY CLUSTERED 
(
	[CasePayorMCI_IDNO] ASC,
	[EventGlobalBeginSeq_NUMB] ASC,
	[SourceHold_CODE] ASC,
	[TypeHold_CODE] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
EXEC sys.sp_addextendedproperty @name=N'1', @value=N'This will store the value of either Case ID or the Payor ID depending upon the cd_type_hold.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DistributionHold_T1', @level2type=N'COLUMN',@level2name=N'CasePayorMCI_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'2', @value=N'The type of hold. Values are obtained from REFM (DHLD/TYPH).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DistributionHold_T1', @level2type=N'COLUMN',@level2name=N'TypeHold_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'3', @value=N'If a Hold instruction is set for a given case or payor on a particular receipt source, then the receipt source value is stored. If an Instruction is set on all pay sources, then the value is DH. Possible values will be  determined in the subsequent technical design.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DistributionHold_T1', @level2type=N'COLUMN',@level2name=N'SourceHold_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This will store a reason code for setting a hold. The values are available in the UCAT table. All Manual NCP holds are the Codes starting with possible values - MNxx.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DistributionHold_T1', @level2type=N'COLUMN',@level2name=N'ReasonHold_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This is the effective date on which the hold is put into effect.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DistributionHold_T1', @level2type=N'COLUMN',@level2name=N'Effective_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This is the date on which the hold is set to expire.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DistributionHold_T1', @level2type=N'COLUMN',@level2name=N'Expiration_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This is an internal sequence field to determine the no. of iterations this hold is modified or extended.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DistributionHold_T1', @level2type=N'COLUMN',@level2name=N'Sequence_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'4', @value=N'The Global Event Sequence number for the corresponding DT_BEG_VALIDITY.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DistributionHold_T1', @level2type=N'COLUMN',@level2name=N'EventGlobalBeginSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The Global Event Sequence number for the corresponding DT_END_VALIDITY. This should be zero when the corresponding DT_END_VALIDITY is a high date.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DistributionHold_T1', @level2type=N'COLUMN',@level2name=N'EventGlobalEndSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The Effective date from when the Changed Information will be  Valid.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DistributionHold_T1', @level2type=N'COLUMN',@level2name=N'BeginValidity_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The  Effective date up to which the Changed Information will be  Valid.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DistributionHold_T1', @level2type=N'COLUMN',@level2name=N'EndValidity_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'This table stores the manual distribution hold instruction for a Payor or Case ID entered  by the user from HLDI screen. This table stores valid records as well as history records which follows the temporal model structure.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DistributionHold_T1'
GO
