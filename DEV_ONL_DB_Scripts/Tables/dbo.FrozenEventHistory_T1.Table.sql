USE [DEV_ONL_DB]
GO
/****** Object:  Table [dbo].[FrozenEventHistory_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[FrozenEventHistory_T1]
GO
/****** Object:  Table [dbo].[FrozenEventHistory_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[FrozenEventHistory_T1](
	[Case_IDNO] [numeric](6, 0) NOT NULL,
	[EventSeq_IDNO] [numeric](6, 0) NOT NULL,
	[Initiation_DATE] [date] NOT NULL,
	[EventTitleDescription_TEXT] [char](35) NOT NULL,
	[InitiatingWorker_ID] [char](4) NOT NULL,
	[ResponsibleWorker_ID] [char](4) NOT NULL,
	[EventType_CODE] [char](4) NOT NULL,
	[Disposition_CODE] [char](4) NOT NULL,
	[EventCompletion_DATE] [date] NOT NULL,
	[EventCompletion_DTTM] [datetime2](7) NOT NULL,
	[EventNotes_TEXT] [varchar](2000) NOT NULL,
 CONSTRAINT [FEVTH_I1] PRIMARY KEY CLUSTERED 
(
	[Case_IDNO] ASC,
	[EventSeq_IDNO] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [FROZEN]
) ON [FROZEN]

GO
SET ANSI_PADDING OFF
GO
