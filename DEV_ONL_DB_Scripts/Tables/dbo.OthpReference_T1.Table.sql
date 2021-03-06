USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'OthpReference_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'3' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'OthpReference_T1', @level2type=N'COLUMN',@level2name=N'OtherParty_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'2' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'OthpReference_T1', @level2type=N'COLUMN',@level2name=N'InsCompanyLocation_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'OthpReference_T1', @level2type=N'COLUMN',@level2name=N'InsCompanyCarrier_CODE'

GO
/****** Object:  Table [dbo].[OthpReference_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[OthpReference_T1]
GO
/****** Object:  Table [dbo].[OthpReference_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[OthpReference_T1](
	[InsCompanyCarrier_CODE] [char](5) NOT NULL,
	[InsCompanyLocation_CODE] [char](4) NOT NULL,
	[OtherParty_IDNO] [numeric](9, 0) NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
EXEC sys.sp_addextendedproperty @name=N'1', @value=N'Insurance company carrier code ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'OthpReference_T1', @level2type=N'COLUMN',@level2name=N'InsCompanyCarrier_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'2', @value=N'Insurance company location code' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'OthpReference_T1', @level2type=N'COLUMN',@level2name=N'InsCompanyLocation_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'3', @value=N'Unique System Assigned number for the Other Party.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'OthpReference_T1', @level2type=N'COLUMN',@level2name=N'OtherParty_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'This table will maintain Insurance Company Carrier Code, Insurance Company Location Code, and Insurance Company Other Party ID.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'OthpReference_T1'
GO
