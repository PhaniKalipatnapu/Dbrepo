USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefStateCode_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefStateCode_T1', @level2type=N'COLUMN',@level2name=N'StateFips_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefStateCode_T1', @level2type=N'COLUMN',@level2name=N'State_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefStateCode_T1', @level2type=N'COLUMN',@level2name=N'State_CODE'

GO
/****** Object:  Table [dbo].[RefStateCode_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[RefStateCode_T1]
GO
/****** Object:  Table [dbo].[RefStateCode_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[RefStateCode_T1](
	[State_CODE] [char](2) NOT NULL,
	[State_NAME] [varchar](60) NOT NULL,
	[StateFips_CODE] [char](2) NOT NULL,
 CONSTRAINT [STAT_I1] PRIMARY KEY CLUSTERED 
(
	[StateFips_CODE] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the state code. This is a reference table' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefStateCode_T1', @level2type=N'COLUMN',@level2name=N'State_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the state name.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefStateCode_T1', @level2type=N'COLUMN',@level2name=N'State_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'1', @value=N'FIPS State codes to be referenced for intergovernmental case locations.  Values are obtained from REFM (FIPS/STCD)  ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefStateCode_T1', @level2type=N'COLUMN',@level2name=N'StateFips_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'This is a reference table to store the cross reference information of the state codes and state FIPS code with the names.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefStateCode_T1'
GO
