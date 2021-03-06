USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractStateTaxOffset_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractStateTaxOffset_T1', @level2type=N'COLUMN',@level2name=N'SecondarySsn_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractStateTaxOffset_T1', @level2type=N'COLUMN',@level2name=N'NcpOwed_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractStateTaxOffset_T1', @level2type=N'COLUMN',@level2name=N'SpouseFirst_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractStateTaxOffset_T1', @level2type=N'COLUMN',@level2name=N'FirstNcp_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractStateTaxOffset_T1', @level2type=N'COLUMN',@level2name=N'LastNcp_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractStateTaxOffset_T1', @level2type=N'COLUMN',@level2name=N'NcpSsn_NUMB'

GO
/****** Object:  Table [dbo].[ExtractStateTaxOffset_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[ExtractStateTaxOffset_T1]
GO
/****** Object:  Table [dbo].[ExtractStateTaxOffset_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ExtractStateTaxOffset_T1](
	[NcpSsn_NUMB] [char](9) NOT NULL,
	[LastNcp_NAME] [char](24) NOT NULL,
	[FirstNcp_NAME] [char](12) NOT NULL,
	[SpouseFirst_NAME] [char](12) NOT NULL,
	[NcpOwed_AMNT] [char](9) NOT NULL,
	[SecondarySsn_NUMB] [char](9) NOT NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'NCP social security number' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractStateTaxOffset_T1', @level2type=N'COLUMN',@level2name=N'NcpSsn_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'NCP last name' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractStateTaxOffset_T1', @level2type=N'COLUMN',@level2name=N'LastNcp_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'NCP first name' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractStateTaxOffset_T1', @level2type=N'COLUMN',@level2name=N'FirstNcp_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Spouse first name' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractStateTaxOffset_T1', @level2type=N'COLUMN',@level2name=N'SpouseFirst_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Amount owed by the NCP' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractStateTaxOffset_T1', @level2type=N'COLUMN',@level2name=N'NcpOwed_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Secondary social security number' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractStateTaxOffset_T1', @level2type=N'COLUMN',@level2name=N'SecondarySsn_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'Table to  send delinquent NCPs to DOR for State Tax Offset programs which include tax refund intercept and lottery intercept.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractStateTaxOffset_T1'
GO
