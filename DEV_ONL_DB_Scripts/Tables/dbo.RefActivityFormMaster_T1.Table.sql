USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefActivityFormMaster_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefActivityFormMaster_T1', @level2type=N'COLUMN',@level2name=N'Mask_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefActivityFormMaster_T1', @level2type=N'COLUMN',@level2name=N'PrintMethod_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'8' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefActivityFormMaster_T1', @level2type=N'COLUMN',@level2name=N'TypeService_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefActivityFormMaster_T1', @level2type=N'COLUMN',@level2name=N'RecipientSeq_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'7' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefActivityFormMaster_T1', @level2type=N'COLUMN',@level2name=N'Recipient_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefActivityFormMaster_T1', @level2type=N'COLUMN',@level2name=N'NoticeOrder_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'5' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefActivityFormMaster_T1', @level2type=N'COLUMN',@level2name=N'ActivityMinorNext_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'4' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefActivityFormMaster_T1', @level2type=N'COLUMN',@level2name=N'ActivityMajorNext_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'3' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefActivityFormMaster_T1', @level2type=N'COLUMN',@level2name=N'Reason_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefActivityFormMaster_T1', @level2type=N'COLUMN',@level2name=N'ActivityMajor_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefActivityFormMaster_T1', @level2type=N'COLUMN',@level2name=N'TypeEditNotice_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefActivityFormMaster_T1', @level2type=N'COLUMN',@level2name=N'ApprovalRequired_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'9' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefActivityFormMaster_T1', @level2type=N'COLUMN',@level2name=N'TransactionEventSeq_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefActivityFormMaster_T1', @level2type=N'COLUMN',@level2name=N'Update_DTTM'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefActivityFormMaster_T1', @level2type=N'COLUMN',@level2name=N'WorkerUpdate_ID'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefActivityFormMaster_T1', @level2type=N'COLUMN',@level2name=N'EndValidity_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefActivityFormMaster_T1', @level2type=N'COLUMN',@level2name=N'BeginValidity_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'6' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefActivityFormMaster_T1', @level2type=N'COLUMN',@level2name=N'Notice_ID'

GO
EXEC sys.sp_dropextendedproperty @name=N'2' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefActivityFormMaster_T1', @level2type=N'COLUMN',@level2name=N'ActivityMinor_CODE'

GO
/****** Object:  Table [dbo].[RefActivityFormMaster_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[RefActivityFormMaster_T1]
GO
/****** Object:  Table [dbo].[RefActivityFormMaster_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[RefActivityFormMaster_T1](
	[ActivityMinor_CODE] [char](5) NOT NULL,
	[Notice_ID] [char](8) NOT NULL,
	[BeginValidity_DATE] [date] NOT NULL,
	[EndValidity_DATE] [date] NOT NULL,
	[WorkerUpdate_ID] [char](30) NOT NULL,
	[Update_DTTM] [datetime2](7) NOT NULL,
	[TransactionEventSeq_NUMB] [numeric](19, 0) NOT NULL,
	[ApprovalRequired_INDC] [char](1) NOT NULL,
	[TypeEditNotice_CODE] [char](1) NOT NULL,
	[ActivityMajor_CODE] [char](4) NOT NULL,
	[Reason_CODE] [char](2) NOT NULL,
	[ActivityMajorNext_CODE] [char](4) NOT NULL,
	[ActivityMinorNext_CODE] [char](5) NOT NULL,
	[NoticeOrder_NUMB] [numeric](3, 0) NOT NULL,
	[Recipient_CODE] [char](2) NOT NULL,
	[RecipientSeq_NUMB] [numeric](3, 0) NOT NULL,
	[TypeService_CODE] [char](2) NOT NULL,
	[PrintMethod_CODE] [char](2) NOT NULL,
	[Mask_INDC] [char](1) NOT NULL,
 CONSTRAINT [AFMS_I1] PRIMARY KEY CLUSTERED 
(
	[ActivityMajor_CODE] ASC,
	[ActivityMinor_CODE] ASC,
	[Reason_CODE] ASC,
	[ActivityMajorNext_CODE] ASC,
	[ActivityMinorNext_CODE] ASC,
	[Notice_ID] ASC,
	[Recipient_CODE] ASC,
	[TypeService_CODE] ASC,
	[TransactionEventSeq_NUMB] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
EXEC sys.sp_addextendedproperty @name=N'2', @value=N'The Minor Activity for which the form has to be generated. Possible values are limited by values in AMNR table.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefActivityFormMaster_T1', @level2type=N'COLUMN',@level2name=N'ActivityMinor_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'6', @value=N'The code given for the form.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefActivityFormMaster_T1', @level2type=N'COLUMN',@level2name=N'Notice_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The Effective date from when the Changed Information is Valid.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefActivityFormMaster_T1', @level2type=N'COLUMN',@level2name=N'BeginValidity_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The Effective date up to which the Changed Information is Valid.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefActivityFormMaster_T1', @level2type=N'COLUMN',@level2name=N'EndValidity_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the worker ID who created/modified this record.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefActivityFormMaster_T1', @level2type=N'COLUMN',@level2name=N'WorkerUpdate_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the effective Date with Time at which this record was inserted / modified in this table.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefActivityFormMaster_T1', @level2type=N'COLUMN',@level2name=N'Update_DTTM'
GO
EXEC sys.sp_addextendedproperty @name=N'9', @value=N'Unique Sequence Number that will be generated for a Transaction on the Table. This field is used for checking concurrency at the time of online transaction updates.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefActivityFormMaster_T1', @level2type=N'COLUMN',@level2name=N'TransactionEventSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Holds data about whether this Notice is required Approval or not. Values are obtained from REFM (YSNO/YSNO)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefActivityFormMaster_T1', @level2type=N'COLUMN',@level2name=N'ApprovalRequired_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Holds data about who can edit this notice which is in the approval process. Possible values are O - Worker, S - Supervisor, A - Attorney and F - Final.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefActivityFormMaster_T1', @level2type=N'COLUMN',@level2name=N'TypeEditNotice_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'1', @value=N'The Major Activity for which the form has to be generated. Possible values are limited by values in AMJR table.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefActivityFormMaster_T1', @level2type=N'COLUMN',@level2name=N'ActivityMajor_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'3', @value=N'The code which represents the Reason to update the current Minor Activity. Values are obtained from REFM (CPRO/REAS).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefActivityFormMaster_T1', @level2type=N'COLUMN',@level2name=N'Reason_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'4', @value=N'The code of the Major Activity to follow next. Possible values are limited by values in AMJR table.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefActivityFormMaster_T1', @level2type=N'COLUMN',@level2name=N'ActivityMajorNext_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'5', @value=N'The Code of the Next Minor Activity to follow. Possible values are limited by values in AMNR table.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefActivityFormMaster_T1', @level2type=N'COLUMN',@level2name=N'ActivityMinorNext_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This column holds the number which is used while displaying the notices on the screen.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefActivityFormMaster_T1', @level2type=N'COLUMN',@level2name=N'NoticeOrder_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'7', @value=N'Code given for each recipient. Values are obtained from REFM (RECP/RECP)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefActivityFormMaster_T1', @level2type=N'COLUMN',@level2name=N'Recipient_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This column holds the number which is used while displaying the recipients on the screen.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefActivityFormMaster_T1', @level2type=N'COLUMN',@level2name=N'RecipientSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'8', @value=N'Indicates type of mailing service. Values are obtained from REFM (DOCS/SVIP)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefActivityFormMaster_T1', @level2type=N'COLUMN',@level2name=N'TypeService_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates whether the print method is done in a local printer or done centrally through a batch. Values are obtained from REFM (PRNT/MTHD)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefActivityFormMaster_T1', @level2type=N'COLUMN',@level2name=N'PrintMethod_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates whether the confidential data has to be masked (redacted) on the form sent to this recipient, if the case is a Family violence case. Values are obtained from REFM (YSNO/YSNO)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefActivityFormMaster_T1', @level2type=N'COLUMN',@level2name=N'Mask_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'This is a reference table that indicates what notices have to be generated for each minor activity along with additional attributes. This table stores valid records as well as history records which follows the temporal model structure.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefActivityFormMaster_T1'
GO
