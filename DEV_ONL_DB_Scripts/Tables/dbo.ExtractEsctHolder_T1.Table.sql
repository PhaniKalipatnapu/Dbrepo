USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractEsctHolder_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractEsctHolder_T1', @level2type=N'COLUMN',@level2name=N'Fax_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractEsctHolder_T1', @level2type=N'COLUMN',@level2name=N'State_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractEsctHolder_T1', @level2type=N'COLUMN',@level2name=N'City_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractEsctHolder_T1', @level2type=N'COLUMN',@level2name=N'OtherParty_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractEsctHolder_T1', @level2type=N'COLUMN',@level2name=N'Fein_IDNO'

GO
/****** Object:  Table [dbo].[ExtractEsctHolder_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[ExtractEsctHolder_T1]
GO
/****** Object:  Table [dbo].[ExtractEsctHolder_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ExtractEsctHolder_T1](
	[Fein_IDNO] [char](9) NOT NULL,
	[OtherParty_NAME] [char](40) NOT NULL,
	[City_ADDR] [char](30) NOT NULL,
	[State_ADDR] [char](20) NOT NULL,
	[Fax_NUMB] [char](7) NOT NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Federal Identification Number of the Other Party.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractEsctHolder_T1', @level2type=N'COLUMN',@level2name=N'Fein_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the Name of the Other Party.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractEsctHolder_T1', @level2type=N'COLUMN',@level2name=N'OtherParty_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Other Party Residing City.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractEsctHolder_T1', @level2type=N'COLUMN',@level2name=N'City_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Other Party Residing State. Values are obtained from REFM (STAT/STAT).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractEsctHolder_T1', @level2type=N'COLUMN',@level2name=N'State_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Other Party Fax Number.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractEsctHolder_T1', @level2type=N'COLUMN',@level2name=N'Fax_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'This staging table stores the company details. This table is used in BATCH_FIN_EXT_ESCHEATMENT package.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractEsctHolder_T1'
GO
