USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'NegativeAdjustmentException_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'NegativeAdjustmentException_T1', @level2type=N'COLUMN',@level2name=N'Received_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'NegativeAdjustmentException_T1', @level2type=N'COLUMN',@level2name=N'TaxJoint_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'NegativeAdjustmentException_T1', @level2type=N'COLUMN',@level2name=N'TaxJoint_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'NegativeAdjustmentException_T1', @level2type=N'COLUMN',@level2name=N'Tanf_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'NegativeAdjustmentException_T1', @level2type=N'COLUMN',@level2name=N'Check_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'NegativeAdjustmentException_T1', @level2type=N'COLUMN',@level2name=N'TopTraceNo_TEXT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'NegativeAdjustmentException_T1', @level2type=N'COLUMN',@level2name=N'MemberSsn_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'NegativeAdjustmentException_T1', @level2type=N'COLUMN',@level2name=N'Adjust_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'NegativeAdjustmentException_T1', @level2type=N'COLUMN',@level2name=N'PayorMCI_IDNO'

GO
/****** Object:  Index [NAEX_DT_RECEIVED_I1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP INDEX [NAEX_DT_RECEIVED_I1] ON [dbo].[NegativeAdjustmentException_T1]
GO
/****** Object:  Table [dbo].[NegativeAdjustmentException_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[NegativeAdjustmentException_T1]
GO
/****** Object:  Table [dbo].[NegativeAdjustmentException_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[NegativeAdjustmentException_T1](
	[PayorMCI_IDNO] [numeric](10, 0) NOT NULL,
	[Adjust_AMNT] [numeric](11, 2) NOT NULL,
	[MemberSsn_NUMB] [numeric](9, 0) NOT NULL,
	[TopTraceNo_TEXT] [char](10) NOT NULL,
	[Check_DATE] [date] NOT NULL,
	[Tanf_CODE] [char](1) NOT NULL,
	[TaxJoint_CODE] [char](1) NOT NULL,
	[TaxJoint_NAME] [char](35) NOT NULL,
	[Received_DATE] [date] NOT NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Index [NAEX_DT_RECEIVED_I1]    Script Date: 4/7/2015 12:53:07 PM ******/
CREATE NONCLUSTERED INDEX [NAEX_DT_RECEIVED_I1] ON [dbo].[NegativeAdjustmentException_T1]
(
	[Received_DATE] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Member ID retrieved from VDEMO based on NCP SSN.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'NegativeAdjustmentException_T1', @level2type=N'COLUMN',@level2name=N'PayorMCI_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Adjustment amount.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'NegativeAdjustmentException_T1', @level2type=N'COLUMN',@level2name=N'Adjust_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This field contains the Social Security Number that was sent to OCSE by the state and stored on the OCSE Case Master File.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'NegativeAdjustmentException_T1', @level2type=N'COLUMN',@level2name=N'MemberSsn_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The trace number assigned to a collection by FMS and returned as an identifier with a collection or associated adjustment.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'NegativeAdjustmentException_T1', @level2type=N'COLUMN',@level2name=N'TopTraceNo_TEXT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This field contains the year the offset originated that was sent to OCSE on the FMS Weekly Collection Record.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'NegativeAdjustmentException_T1', @level2type=N'COLUMN',@level2name=N'Check_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates IRS intercept is for TANF or Non-TANF. Values are obtained from REFM (TANF/TYPE)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'NegativeAdjustmentException_T1', @level2type=N'COLUMN',@level2name=N'Tanf_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indication if the receipt is an intercept of a joint-return. If so, the joint name will be recorded. Values are obtained from REFM (TAXI/ACCT)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'NegativeAdjustmentException_T1', @level2type=N'COLUMN',@level2name=N'TaxJoint_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the name of the individual named in the joint tax return (other than case participant).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'NegativeAdjustmentException_T1', @level2type=N'COLUMN',@level2name=N'TaxJoint_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This field contains the Negative Adjustment data received date.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'NegativeAdjustmentException_T1', @level2type=N'COLUMN',@level2name=N'Received_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'This table is used to store the IRS negative adjustment exception (BATE) data. This table is populated in BATCH_FIN_IRS_NADJ package and it will be used in FINS program to get IRS negative adjustment amount that were recorded as exceptions.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'NegativeAdjustmentException_T1'
GO
