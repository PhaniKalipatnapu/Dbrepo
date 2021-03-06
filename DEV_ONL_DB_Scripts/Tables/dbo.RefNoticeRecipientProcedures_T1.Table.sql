USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'COMMENT' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefNoticeRecipientProcedures_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefNoticeRecipientProcedures_T1', @level2type=N'COLUMN',@level2name=N'Update_DTTM'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefNoticeRecipientProcedures_T1', @level2type=N'COLUMN',@level2name=N'WorkerUpdate_ID'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefNoticeRecipientProcedures_T1', @level2type=N'COLUMN',@level2name=N'Procedure_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefNoticeRecipientProcedures_T1', @level2type=N'COLUMN',@level2name=N'Recipient_CODE'

GO
/****** Object:  Table [dbo].[RefNoticeRecipientProcedures_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[RefNoticeRecipientProcedures_T1]
GO
/****** Object:  Table [dbo].[RefNoticeRecipientProcedures_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[RefNoticeRecipientProcedures_T1](
	[Recipient_CODE] [char](2) NOT NULL,
	[Procedure_NAME] [varchar](100) NOT NULL,
	[WorkerUpdate_ID] [char](30) NOT NULL,
	[Update_DTTM] [datetime2](7) NOT NULL,
 CONSTRAINT [NRPM_I1] PRIMARY KEY CLUSTERED 
(
	[Recipient_CODE] ASC,
	[Procedure_NAME] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This is the Recipient_CODE' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefNoticeRecipientProcedures_T1', @level2type=N'COLUMN',@level2name=N'Recipient_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the Procedure Name for each recipient' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefNoticeRecipientProcedures_T1', @level2type=N'COLUMN',@level2name=N'Procedure_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies modified Worker IDNO' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefNoticeRecipientProcedures_T1', @level2type=N'COLUMN',@level2name=N'WorkerUpdate_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies Updated Date' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefNoticeRecipientProcedures_T1', @level2type=N'COLUMN',@level2name=N'Update_DTTM'
GO
EXEC sys.sp_addextendedproperty @name=N'COMMENT', @value=N'This table stores the Recipient_CODE and Corresponding stored procedure to execute dynamically and get the recipient details .' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefNoticeRecipientProcedures_T1'
GO
