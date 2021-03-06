USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpRrepWelfare_P1'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpRrepWelfare_P1', @level2type=N'COLUMN',@level2name=N'LtdRecoupFc_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpRrepWelfare_P1', @level2type=N'COLUMN',@level2name=N'MtdRecoupFc_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpRrepWelfare_P1', @level2type=N'COLUMN',@level2name=N'LtdRecoupTanf_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpRrepWelfare_P1', @level2type=N'COLUMN',@level2name=N'MtdRecoupTanf_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpRrepWelfare_P1', @level2type=N'COLUMN',@level2name=N'WelfareYearMonth_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpRrepWelfare_P1', @level2type=N'COLUMN',@level2name=N'CaseWelfare_IDNO'

GO
/****** Object:  Table [dbo].[TmpRrepWelfare_P1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[TmpRrepWelfare_P1]
GO
/****** Object:  Table [dbo].[TmpRrepWelfare_P1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TmpRrepWelfare_P1](
	[CaseWelfare_IDNO] [numeric](10, 0) NOT NULL,
	[WelfareYearMonth_NUMB] [numeric](6, 0) NOT NULL,
	[MtdRecoupTanf_AMNT] [numeric](11, 2) NOT NULL,
	[LtdRecoupTanf_AMNT] [numeric](11, 2) NOT NULL,
	[MtdRecoupFc_AMNT] [numeric](11, 2) NOT NULL,
	[LtdRecoupFc_AMNT] [numeric](11, 2) NOT NULL
) ON [PRIMARY]

GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Welfare Case ID, Created at CP level when any one dependant of the CP is in welfare program.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpRrepWelfare_P1', @level2type=N'COLUMN',@level2name=N'CaseWelfare_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The Month and year of transaction that record related to.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpRrepWelfare_P1', @level2type=N'COLUMN',@level2name=N'WelfareYearMonth_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Amount Month to Date Recouped against current Assistance Case.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpRrepWelfare_P1', @level2type=N'COLUMN',@level2name=N'MtdRecoupTanf_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Amount Life to Date Recouped against current Assistance Case.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpRrepWelfare_P1', @level2type=N'COLUMN',@level2name=N'LtdRecoupTanf_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Amount Month to Date Recouped against FOSTER care on a welfare case.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpRrepWelfare_P1', @level2type=N'COLUMN',@level2name=N'MtdRecoupFc_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Amount Life to Date Recouped against FOSTER care on a welfare case.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpRrepWelfare_P1', @level2type=N'COLUMN',@level2name=N'LtdRecoupFc_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'This is global temporary table that is used by RREP screen to calcuate the welfare amount to be reversed for a receipt' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpRrepWelfare_P1'
GO
