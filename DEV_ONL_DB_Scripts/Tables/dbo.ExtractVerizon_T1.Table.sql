USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractVerizon_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractVerizon_T1', @level2type=N'COLUMN',@level2name=N'MemberSsn_NUMB'

GO
/****** Object:  Table [dbo].[ExtractVerizon_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[ExtractVerizon_T1]
GO
/****** Object:  Table [dbo].[ExtractVerizon_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ExtractVerizon_T1](
	[MemberSsn_NUMB] [char](9) NOT NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Non custodial parent  SSN  number.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractVerizon_T1', @level2type=N'COLUMN',@level2name=N'MemberSsn_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'This process extracts DACSES NCPs data to create Locate requests to verizon wireless.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractVerizon_T1'
GO
