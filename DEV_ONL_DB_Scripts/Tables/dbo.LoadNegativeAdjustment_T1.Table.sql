USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadNegativeAdjustment_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadNegativeAdjustment_T1', @level2type=N'COLUMN',@level2name=N'Process_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadNegativeAdjustment_T1', @level2type=N'COLUMN',@level2name=N'TaxJoint_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadNegativeAdjustment_T1', @level2type=N'COLUMN',@level2name=N'TaxJoint_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadNegativeAdjustment_T1', @level2type=N'COLUMN',@level2name=N'Tanf_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadNegativeAdjustment_T1', @level2type=N'COLUMN',@level2name=N'Adjust_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadNegativeAdjustment_T1', @level2type=N'COLUMN',@level2name=N'CheckNo_TEXT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadNegativeAdjustment_T1', @level2type=N'COLUMN',@level2name=N'MemberSsn_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadNegativeAdjustment_T1', @level2type=N'COLUMN',@level2name=N'Adjust_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadNegativeAdjustment_T1', @level2type=N'COLUMN',@level2name=N'PayorMCI_IDNO'

GO
/****** Object:  Table [dbo].[LoadNegativeAdjustment_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[LoadNegativeAdjustment_T1]
GO
/****** Object:  Table [dbo].[LoadNegativeAdjustment_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[LoadNegativeAdjustment_T1](
	[Seq_IDNO] [numeric](19, 0) IDENTITY(1,1) NOT NULL,
	[PayorMCI_IDNO] [char](10) NOT NULL,
	[Adjust_AMNT] [char](11) NOT NULL,
	[MemberSsn_NUMB] [char](9) NOT NULL,
	[CheckNo_TEXT] [char](9) NOT NULL,
	[Adjust_DATE] [char](12) NOT NULL,
	[Tanf_CODE] [char](1) NOT NULL,
	[TaxJoint_CODE] [char](1) NOT NULL,
	[TaxJoint_NAME] [char](35) NOT NULL,
	[FileLoad_DATE] [date] NOT NULL,
	[Process_INDC] [char](1) NOT NULL,
 CONSTRAINT [LNADJ_I1] PRIMARY KEY CLUSTERED 
(
	[Seq_IDNO] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Member ID retrieved from VDEMO based on NCP SSN.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadNegativeAdjustment_T1', @level2type=N'COLUMN',@level2name=N'PayorMCI_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Adjustment amount.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadNegativeAdjustment_T1', @level2type=N'COLUMN',@level2name=N'Adjust_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This field contains the Social Security Number that was sent to OCSE by the state and stored on the OCSE Case Master File.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadNegativeAdjustment_T1', @level2type=N'COLUMN',@level2name=N'MemberSsn_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The trace number assigned to a collection by FMS and returned as an identifier with a collection or associated adjustment.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadNegativeAdjustment_T1', @level2type=N'COLUMN',@level2name=N'CheckNo_TEXT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This field contains the year the offset originated that was sent to OCSE on the FMS Weekly Collection Record.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadNegativeAdjustment_T1', @level2type=N'COLUMN',@level2name=N'Adjust_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates IRS intercept is for TANF or Non-TANF.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadNegativeAdjustment_T1', @level2type=N'COLUMN',@level2name=N'Tanf_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indication if the receipt is an intercept of a joint-return. If so, the joint name will be recorded.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadNegativeAdjustment_T1', @level2type=N'COLUMN',@level2name=N'TaxJoint_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the name of the individual named in the joint tax return (other than case participant).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadNegativeAdjustment_T1', @level2type=N'COLUMN',@level2name=N'TaxJoint_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates Y if the record is processed otherwise N.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadNegativeAdjustment_T1', @level2type=N'COLUMN',@level2name=N'Process_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'To load collection data received from IRS. If the Adjustment Amount is greater than zero' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadNegativeAdjustment_T1'
GO
