USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DocumentMaintenance_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DocumentMaintenance_T1', @level2type=N'COLUMN',@level2name=N'MinorIntSeq_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DocumentMaintenance_T1', @level2type=N'COLUMN',@level2name=N'MajorIntSeq_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DocumentMaintenance_T1', @level2type=N'COLUMN',@level2name=N'Order_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DocumentMaintenance_T1', @level2type=N'COLUMN',@level2name=N'Petition_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'7' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DocumentMaintenance_T1', @level2type=N'COLUMN',@level2name=N'Respondent_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'6' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DocumentMaintenance_T1', @level2type=N'COLUMN',@level2name=N'Petitioner_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DocumentMaintenance_T1', @level2type=N'COLUMN',@level2name=N'ApprovedBy_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DocumentMaintenance_T1', @level2type=N'COLUMN',@level2name=N'FdemDisplay_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'8' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DocumentMaintenance_T1', @level2type=N'COLUMN',@level2name=N'TransactionEventSeq_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DocumentMaintenance_T1', @level2type=N'COLUMN',@level2name=N'Update_DTTM'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DocumentMaintenance_T1', @level2type=N'COLUMN',@level2name=N'WorkerUpdate_ID'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DocumentMaintenance_T1', @level2type=N'COLUMN',@level2name=N'EndValidity_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DocumentMaintenance_T1', @level2type=N'COLUMN',@level2name=N'BeginValidity_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'5' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DocumentMaintenance_T1', @level2type=N'COLUMN',@level2name=N'Filed_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DocumentMaintenance_T1', @level2type=N'COLUMN',@level2name=N'SourceDoc_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'3' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DocumentMaintenance_T1', @level2type=N'COLUMN',@level2name=N'TypeDoc_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DocumentMaintenance_T1', @level2type=N'COLUMN',@level2name=N'DocReference_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'2' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DocumentMaintenance_T1', @level2type=N'COLUMN',@level2name=N'File_ID'

GO
EXEC sys.sp_dropextendedproperty @name=N'1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DocumentMaintenance_T1', @level2type=N'COLUMN',@level2name=N'Case_IDNO'

GO
/****** Object:  Table [dbo].[DocumentMaintenance_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[DocumentMaintenance_T1]
GO
/****** Object:  Table [dbo].[DocumentMaintenance_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[DocumentMaintenance_T1](
	[Case_IDNO] [numeric](6, 0) NOT NULL,
	[File_ID] [char](10) NOT NULL,
	[DocReference_CODE] [char](4) NOT NULL,
	[TypeDoc_CODE] [char](1) NOT NULL,
	[SourceDoc_CODE] [char](1) NOT NULL,
	[Filed_DATE] [date] NOT NULL,
	[BeginValidity_DATE] [date] NOT NULL,
	[EndValidity_DATE] [date] NOT NULL,
	[WorkerUpdate_ID] [char](30) NOT NULL,
	[Update_DTTM] [datetime2](7) NOT NULL,
	[TransactionEventSeq_NUMB] [numeric](19, 0) NOT NULL,
	[FdemDisplay_INDC] [char](1) NOT NULL,
	[ApprovedBy_CODE] [char](4) NOT NULL,
	[Petitioner_IDNO] [numeric](10, 0) NOT NULL,
	[Respondent_IDNO] [numeric](10, 0) NOT NULL,
	[Petition_IDNO] [numeric](7, 0) NOT NULL,
	[Order_IDNO] [numeric](15, 0) NOT NULL,
	[MajorIntSeq_NUMB] [numeric](5, 0) NOT NULL,
	[MinorIntSeq_NUMB] [numeric](5, 0) NOT NULL,
 CONSTRAINT [FDEM_I1] PRIMARY KEY CLUSTERED 
(
	[Case_IDNO] ASC,
	[File_ID] ASC,
	[Filed_DATE] ASC,
	[Petitioner_IDNO] ASC,
	[Respondent_IDNO] ASC,
	[TransactionEventSeq_NUMB] ASC,
	[TypeDoc_CODE] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
EXEC sys.sp_addextendedproperty @name=N'1', @value=N'Unique ID generated for the DACSES Case.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DocumentMaintenance_T1', @level2type=N'COLUMN',@level2name=N'Case_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'2', @value=N'Unique ID generated by system for the File.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DocumentMaintenance_T1', @level2type=N'COLUMN',@level2name=N'File_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Motion/Petition reference type generated by system for the document. Values are obtained from REFM (FMIS/FDOC).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DocumentMaintenance_T1', @level2type=N'COLUMN',@level2name=N'DocReference_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'3', @value=N'Document type code indicates whether it''s related to interim, miscellaneous, motions or order type. Values are obtained from REFM (FDEM/DTYP).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DocumentMaintenance_T1', @level2type=N'COLUMN',@level2name=N'TypeDoc_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Code that indicates the document source. Values are obtained from REFM (FDEM/DSRC).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DocumentMaintenance_T1', @level2type=N'COLUMN',@level2name=N'SourceDoc_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'5', @value=N'Date when the document is filed.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DocumentMaintenance_T1', @level2type=N'COLUMN',@level2name=N'Filed_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The Effective date from when the Changed Information is Valid.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DocumentMaintenance_T1', @level2type=N'COLUMN',@level2name=N'BeginValidity_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The Effective date up to which the Changed Information is Valid.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DocumentMaintenance_T1', @level2type=N'COLUMN',@level2name=N'EndValidity_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the worker ID who created/modified this record.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DocumentMaintenance_T1', @level2type=N'COLUMN',@level2name=N'WorkerUpdate_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the effective Date with Time at which this record was inserted / modified in this table.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DocumentMaintenance_T1', @level2type=N'COLUMN',@level2name=N'Update_DTTM'
GO
EXEC sys.sp_addextendedproperty @name=N'8', @value=N'Unique Sequence Number that will be  generated for a Transaction on the Table. This field is used for checking concurrency at the time of online transaction updates.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DocumentMaintenance_T1', @level2type=N'COLUMN',@level2name=N'TransactionEventSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates whether the worker can view the document.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DocumentMaintenance_T1', @level2type=N'COLUMN',@level2name=N'FdemDisplay_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the commissioner or judge who approved the order.  Values are obtained from REFM(FMIS/APBY).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DocumentMaintenance_T1', @level2type=N'COLUMN',@level2name=N'ApprovedBy_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'6', @value=N'MCI or OTHP ID that filed the non-DACSES generated document with the court.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DocumentMaintenance_T1', @level2type=N'COLUMN',@level2name=N'Petitioner_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'7', @value=N'MCI or OTHP ID of the non-filing party' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DocumentMaintenance_T1', @level2type=N'COLUMN',@level2name=N'Respondent_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies Family court petition number' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DocumentMaintenance_T1', @level2type=N'COLUMN',@level2name=N'Petition_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The order ID refers to the local identification assigned to this order.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DocumentMaintenance_T1', @level2type=N'COLUMN',@level2name=N'Order_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The system generated sequence number for the Remedy and Case / Order combination.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DocumentMaintenance_T1', @level2type=N'COLUMN',@level2name=N'MajorIntSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The system generated number for the Remedy and Case ID combination' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DocumentMaintenance_T1', @level2type=N'COLUMN',@level2name=N'MinorIntSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'This Table stores the Document that is generated outside of DACSES. This table stores valid records as well as history records which follows the temporal model structure.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DocumentMaintenance_T1'
GO
