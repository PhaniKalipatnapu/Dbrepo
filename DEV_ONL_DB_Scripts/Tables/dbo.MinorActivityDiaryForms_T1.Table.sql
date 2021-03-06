USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MinorActivityDiaryForms_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'6' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MinorActivityDiaryForms_T1', @level2type=N'COLUMN',@level2name=N'Barcode_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MinorActivityDiaryForms_T1', @level2type=N'COLUMN',@level2name=N'WorkerRqst_ID'

GO
EXEC sys.sp_dropextendedproperty @name=N'3' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MinorActivityDiaryForms_T1', @level2type=N'COLUMN',@level2name=N'Recipient_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'2' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MinorActivityDiaryForms_T1', @level2type=N'COLUMN',@level2name=N'Notice_ID'

GO
EXEC sys.sp_dropextendedproperty @name=N'1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MinorActivityDiaryForms_T1', @level2type=N'COLUMN',@level2name=N'Topic_IDNO'

GO
/****** Object:  Index [FORM_BARCODE_I1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP INDEX [FORM_BARCODE_I1] ON [dbo].[MinorActivityDiaryForms_T1]
GO
/****** Object:  Table [dbo].[MinorActivityDiaryForms_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[MinorActivityDiaryForms_T1]
GO
/****** Object:  Table [dbo].[MinorActivityDiaryForms_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[MinorActivityDiaryForms_T1](
	[Topic_IDNO] [numeric](10, 0) NOT NULL,
	[Notice_ID] [char](8) NOT NULL,
	[Recipient_CODE] [char](2) NOT NULL,
	[WorkerRqst_ID] [char](30) NOT NULL,
	[Barcode_NUMB] [numeric](12, 0) NOT NULL,
 CONSTRAINT [FORM_I1] PRIMARY KEY CLUSTERED 
(
	[Topic_IDNO] ASC,
	[Notice_ID] ASC,
	[Recipient_CODE] ASC,
	[Barcode_NUMB] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Index [FORM_BARCODE_I1]    Script Date: 4/7/2015 12:53:07 PM ******/
CREATE NONCLUSTERED INDEX [FORM_BARCODE_I1] ON [dbo].[MinorActivityDiaryForms_T1]
(
	[Barcode_NUMB] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
EXEC sys.sp_addextendedproperty @name=N'1', @value=N'Unique ID created by the system while inserting an Activity in DMNR_V1.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MinorActivityDiaryForms_T1', @level2type=N'COLUMN',@level2name=N'Topic_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'2', @value=N'Unique ID given for each notice.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MinorActivityDiaryForms_T1', @level2type=N'COLUMN',@level2name=N'Notice_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'3', @value=N'Code given for each recipient. Values are retrieved from REFM (RECP, RECP).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MinorActivityDiaryForms_T1', @level2type=N'COLUMN',@level2name=N'Recipient_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The worker who has requested the notice generation.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MinorActivityDiaryForms_T1', @level2type=N'COLUMN',@level2name=N'WorkerRqst_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'6', @value=N'Unique ID created by the system while each notice was generated.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MinorActivityDiaryForms_T1', @level2type=N'COLUMN',@level2name=N'Barcode_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'This table stores the notices that were generated for each minor activity step processed along with the recipients for which the forms were generated.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MinorActivityDiaryForms_T1'
GO
