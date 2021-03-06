USE [DEV_ONL_DB]
GO
/****** Object:  Table [dbo].[RefScreenLookup_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[RefScreenLookup_T1]
GO
/****** Object:  Table [dbo].[RefScreenLookup_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[RefScreenLookup_T1](
	[Screen_ID] [char](4) NOT NULL,
	[Field_NAME] [varchar](70) NOT NULL,
	[DependentValue_TEXT] [char](30) NOT NULL,
	[SystemTable_ID] [varchar](70) NOT NULL,
	[Column_NAME] [varchar](70) NOT NULL,
	[RefType_ID] [char](20) NOT NULL,
	[Table_ID] [char](4) NOT NULL,
	[TableSub_ID] [char](4) NOT NULL,
	[BeginValidity_DATE] [date] NOT NULL,
	[EndValidity_DATE] [date] NOT NULL,
	[TransactionEventSeq_NUMB] [numeric](19, 0) NOT NULL,
	[Update_DTTM] [datetime2](7) NOT NULL,
	[WorkerUpdate_ID] [char](30) NOT NULL,
 CONSTRAINT [RSCL_I1] PRIMARY KEY CLUSTERED 
(
	[Screen_ID] ASC,
	[Field_NAME] ASC,
	[DependentValue_TEXT] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
