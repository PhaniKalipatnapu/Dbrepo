USE [DEV_ONL_DB]
GO
ALTER TABLE [dbo].[ConversionRefmPossibleValueResultLog_T1] DROP CONSTRAINT [DF__Conversio__Creat__05F82579]
GO
/****** Object:  Table [dbo].[ConversionRefmPossibleValueResultLog_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[ConversionRefmPossibleValueResultLog_T1]
GO
/****** Object:  Table [dbo].[ConversionRefmPossibleValueResultLog_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ConversionRefmPossibleValueResultLog_T1](
	[Conversion_DATE] [date] NULL,
	[ExecutedQuery_TEXT] [varchar](4000) NULL,
	[Status_Code] [char](1) NULL,
	[Create_DTTM] [datetime] NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[ConversionRefmPossibleValueResultLog_T1] ADD  DEFAULT (getdate()) FOR [Create_DTTM]
GO
