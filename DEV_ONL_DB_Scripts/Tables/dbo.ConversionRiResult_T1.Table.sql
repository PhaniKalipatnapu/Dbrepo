USE [DEV_ONL_DB]
GO
ALTER TABLE [dbo].[ConversionRiResult_T1] DROP CONSTRAINT [DF__Conversio__Creat__72E55105]
GO
/****** Object:  Index [ConversionRiResult_T12]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP INDEX [ConversionRiResult_T12] ON [dbo].[ConversionRiResult_T1]
GO
/****** Object:  Index [ConversionRiResult_T11]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP INDEX [ConversionRiResult_T11] ON [dbo].[ConversionRiResult_T1]
GO
/****** Object:  Table [dbo].[ConversionRiResult_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[ConversionRiResult_T1]
GO
/****** Object:  Table [dbo].[ConversionRiResult_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ConversionRiResult_T1](
	[DescriptionError_TEXT] [varchar](4000) NULL,
	[FunctionalArea_TEXT] [varchar](500) NULL,
	[Table_NAME] [char](30) NULL,
	[EntityType_TEXT] [varchar](500) NULL,
	[Entity_ID] [varchar](450) NULL,
	[ErrorCount_QNTY] [numeric](18, 0) NULL,
	[Error_Severity_Code] [char](1) NOT NULL,
	[Create_DTTM] [datetime] NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [ConversionRiResult_T11]    Script Date: 4/7/2015 12:53:07 PM ******/
CREATE NONCLUSTERED INDEX [ConversionRiResult_T11] ON [dbo].[ConversionRiResult_T1]
(
	[DescriptionError_TEXT] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [ConversionRiResult_T12]    Script Date: 4/7/2015 12:53:07 PM ******/
CREATE NONCLUSTERED INDEX [ConversionRiResult_T12] ON [dbo].[ConversionRiResult_T1]
(
	[Entity_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ConversionRiResult_T1] ADD  DEFAULT (getdate()) FOR [Create_DTTM]
GO
