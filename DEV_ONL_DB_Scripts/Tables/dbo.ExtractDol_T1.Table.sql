USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractDol_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractDol_T1', @level2type=N'COLUMN',@level2name=N'PaymentType_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractDol_T1', @level2type=N'COLUMN',@level2name=N'TotalPeriodic_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractDol_T1', @level2type=N'COLUMN',@level2name=N'MemberSsn_NUMB'

GO
/****** Object:  Table [dbo].[ExtractDol_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[ExtractDol_T1]
GO
/****** Object:  Table [dbo].[ExtractDol_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ExtractDol_T1](
	[MemberSsn_NUMB] [char](9) NOT NULL,
	[TotalPeriodic_AMNT] [char](10) NOT NULL,
	[PaymentType_CODE] [char](4) NOT NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Member SSN' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractDol_T1', @level2type=N'COLUMN',@level2name=N'MemberSsn_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This field specifies the obligation amount to be collected for a given time period.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractDol_T1', @level2type=N'COLUMN',@level2name=N'TotalPeriodic_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Assign value Wage or Regp depending on the source of the receipt. ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractDol_T1', @level2type=N'COLUMN',@level2name=N'PaymentType_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'Extracts all the NCP''s who are eligible for unemployment income withholding and creates an output file to be sent out to Division of Labor (DOL).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractDol_T1'
GO
