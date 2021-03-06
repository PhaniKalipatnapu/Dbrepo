USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EiwoTracking_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EiwoTracking_T1', @level2type=N'COLUMN',@level2name=N'XmlExtEiwo_TEXT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EiwoTracking_T1', @level2type=N'COLUMN',@level2name=N'Resend_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EiwoTracking_T1', @level2type=N'COLUMN',@level2name=N'ReceivedResult_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EiwoTracking_T1', @level2type=N'COLUMN',@level2name=N'MultipleError_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EiwoTracking_T1', @level2type=N'COLUMN',@level2name=N'SecondError_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EiwoTracking_T1', @level2type=N'COLUMN',@level2name=N'FirstError_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EiwoTracking_T1', @level2type=N'COLUMN',@level2name=N'ReceivedAcknowledgement_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EiwoTracking_T1', @level2type=N'COLUMN',@level2name=N'DescriptionLumpSumPay_TEXT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EiwoTracking_T1', @level2type=N'COLUMN',@level2name=N'LumpSumPay_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EiwoTracking_T1', @level2type=N'COLUMN',@level2name=N'LumpSumPay_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EiwoTracking_T1', @level2type=N'COLUMN',@level2name=N'FinalPay_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EiwoTracking_T1', @level2type=N'COLUMN',@level2name=N'FinalPayment_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EiwoTracking_T1', @level2type=N'COLUMN',@level2name=N'Termination_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EiwoTracking_T1', @level2type=N'COLUMN',@level2name=N'RejReason_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EiwoTracking_T1', @level2type=N'COLUMN',@level2name=N'Disp_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EiwoTracking_T1', @level2type=N'COLUMN',@level2name=N'NcpSsn_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EiwoTracking_T1', @level2type=N'COLUMN',@level2name=N'Order_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EiwoTracking_T1', @level2type=N'COLUMN',@level2name=N'DocTrackNo_TEXT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EiwoTracking_T1', @level2type=N'COLUMN',@level2name=N'Fein_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EiwoTracking_T1', @level2type=N'COLUMN',@level2name=N'ReasonStatus_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EiwoTracking_T1', @level2type=N'COLUMN',@level2name=N'ActivityMinor_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EiwoTracking_T1', @level2type=N'COLUMN',@level2name=N'Status_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EiwoTracking_T1', @level2type=N'COLUMN',@level2name=N'Entered_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EiwoTracking_T1', @level2type=N'COLUMN',@level2name=N'IwSent_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EiwoTracking_T1', @level2type=N'COLUMN',@level2name=N'TypeOthpSource_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EiwoTracking_T1', @level2type=N'COLUMN',@level2name=N'OthpSource_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EiwoTracking_T1', @level2type=N'COLUMN',@level2name=N'MemberMci_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EiwoTracking_T1', @level2type=N'COLUMN',@level2name=N'MinorIntSeq_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EiwoTracking_T1', @level2type=N'COLUMN',@level2name=N'MajorIntSeq_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EiwoTracking_T1', @level2type=N'COLUMN',@level2name=N'OrderSeq_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EiwoTracking_T1', @level2type=N'COLUMN',@level2name=N'Case_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EiwoTracking_T1', @level2type=N'COLUMN',@level2name=N'DocumentAction_CODE'

GO
/****** Object:  Index [EIWT_NO_DOC_TRACK_I1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP INDEX [EIWT_NO_DOC_TRACK_I1] ON [dbo].[EiwoTracking_T1]
GO
/****** Object:  Table [dbo].[EiwoTracking_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[EiwoTracking_T1]
GO
/****** Object:  Table [dbo].[EiwoTracking_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[EiwoTracking_T1](
	[DocumentAction_CODE] [char](3) NOT NULL,
	[Case_IDNO] [numeric](6, 0) NOT NULL,
	[OrderSeq_NUMB] [numeric](2, 0) NOT NULL,
	[MajorIntSeq_NUMB] [numeric](5, 0) NOT NULL,
	[MinorIntSeq_NUMB] [numeric](5, 0) NOT NULL,
	[MemberMci_IDNO] [numeric](10, 0) NOT NULL,
	[OthpSource_IDNO] [numeric](9, 0) NOT NULL,
	[TypeOthpSource_CODE] [char](1) NOT NULL,
	[IwSent_DATE] [date] NOT NULL,
	[Entered_DATE] [date] NOT NULL,
	[Status_DATE] [date] NOT NULL,
	[ActivityMinor_CODE] [char](5) NOT NULL,
	[ReasonStatus_CODE] [char](2) NOT NULL,
	[Fein_IDNO] [numeric](9, 0) NOT NULL,
	[DocTrackNo_TEXT] [char](30) NOT NULL,
	[Order_IDNO] [numeric](15, 0) NOT NULL,
	[NcpSsn_NUMB] [numeric](9, 0) NOT NULL,
	[Disp_CODE] [char](2) NOT NULL,
	[RejReason_CODE] [char](3) NOT NULL,
	[Termination_DATE] [date] NOT NULL,
	[FinalPayment_DATE] [date] NOT NULL,
	[FinalPay_AMNT] [numeric](11, 2) NOT NULL,
	[LumpSumPay_DATE] [date] NOT NULL,
	[LumpSumPay_AMNT] [numeric](11, 2) NOT NULL,
	[DescriptionLumpSumPay_TEXT] [char](35) NOT NULL,
	[ReceivedAcknowledgement_DATE] [date] NOT NULL,
	[FirstError_NAME] [char](16) NOT NULL,
	[SecondError_NAME] [char](32) NOT NULL,
	[MultipleError_CODE] [char](1) NOT NULL,
	[ReceivedResult_DATE] [date] NOT NULL,
	[Resend_INDC] [char](1) NOT NULL,
	[XmlExtEiwo_TEXT] [varchar](max) NOT NULL,
 CONSTRAINT [EIWT_I1] PRIMARY KEY CLUSTERED 
(
	[Case_IDNO] ASC,
	[IwSent_DATE] ASC,
	[OthpSource_IDNO] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [EIWT_NO_DOC_TRACK_I1]    Script Date: 4/7/2015 12:53:07 PM ******/
CREATE NONCLUSTERED INDEX [EIWT_NO_DOC_TRACK_I1] ON [dbo].[EiwoTracking_T1]
(
	[DocTrackNo_TEXT] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the type of IWO document. Possible values are AMD - Amended LUM - Lump Sum ORG - Original TRM - Termination.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EiwoTracking_T1', @level2type=N'COLUMN',@level2name=N'DocumentAction_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the Case ID associated with the record.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EiwoTracking_T1', @level2type=N'COLUMN',@level2name=N'Case_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This is a system generated Internal order sequence number created for a support order for a given case. Each SEQ_ORDER corresponds to a Support Order from the SUPPORT_ORDER table for a given Case ID.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EiwoTracking_T1', @level2type=N'COLUMN',@level2name=N'OrderSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N' The system generated number for every new Minor Activity within the same SEQ_MAJOR_INT. It?s the occurrence of this major activity' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EiwoTracking_T1', @level2type=N'COLUMN',@level2name=N'MajorIntSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N' The system generated number for the Remedy and Case ID combination' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EiwoTracking_T1', @level2type=N'COLUMN',@level2name=N'MinorIntSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Unique ID Assigned to the Member.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EiwoTracking_T1', @level2type=N'COLUMN',@level2name=N'MemberMci_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The Source ID (Other Party ID) where the Remedy is being enforced.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EiwoTracking_T1', @level2type=N'COLUMN',@level2name=N'OthpSource_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The Source Type of the Source ID.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EiwoTracking_T1', @level2type=N'COLUMN',@level2name=N'TypeOthpSource_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The date on which e-IWO sent to the Portal.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EiwoTracking_T1', @level2type=N'COLUMN',@level2name=N'IwSent_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The date on which the Remedy has been Initiated.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EiwoTracking_T1', @level2type=N'COLUMN',@level2name=N'Entered_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The date on which the Remedy has been updated.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EiwoTracking_T1', @level2type=N'COLUMN',@level2name=N'Status_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The Code with in the system for the Minor Activity.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EiwoTracking_T1', @level2type=N'COLUMN',@level2name=N'ActivityMinor_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates whether a record was accepted or rejected by the employer.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EiwoTracking_T1', @level2type=N'COLUMN',@level2name=N'ReasonStatus_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Employer/withholder''s FEIN.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EiwoTracking_T1', @level2type=N'COLUMN',@level2name=N'Fein_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'A number assigned by the entity sending the document that uniquely identifies the document.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EiwoTracking_T1', @level2type=N'COLUMN',@level2name=N'DocTrackNo_TEXT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'A unique identifier that is associated with a specific child support obligation within a case.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EiwoTracking_T1', @level2type=N'COLUMN',@level2name=N'Order_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'NCP Social Security number.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EiwoTracking_T1', @level2type=N'COLUMN',@level2name=N'NcpSsn_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates whether a record was accepted or rejected by the employer.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EiwoTracking_T1', @level2type=N'COLUMN',@level2name=N'Disp_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The reason an e-IWO record was rejected by an employer.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EiwoTracking_T1', @level2type=N'COLUMN',@level2name=N'RejReason_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Date that an employee left or was terminated by an employer.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EiwoTracking_T1', @level2type=N'COLUMN',@level2name=N'Termination_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Date of the final payment sent to the SDU.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EiwoTracking_T1', @level2type=N'COLUMN',@level2name=N'FinalPayment_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Amount of the final payment sent to the SDU.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EiwoTracking_T1', @level2type=N'COLUMN',@level2name=N'FinalPay_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The date an employer anticipates that a Lump Sum Payment will be disbursed to an employee.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EiwoTracking_T1', @level2type=N'COLUMN',@level2name=N'LumpSumPay_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'An amount the employer intends to issue as a Lump Sum Payment to the employee.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EiwoTracking_T1', @level2type=N'COLUMN',@level2name=N'LumpSumPay_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The type of Lump Sum Payment that will be disbursed to an employee.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EiwoTracking_T1', @level2type=N'COLUMN',@level2name=N'DescriptionLumpSumPay_TEXT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The date on which state received the acknowledgement from the Portal.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EiwoTracking_T1', @level2type=N'COLUMN',@level2name=N'ReceivedAcknowledgement_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Name of the first field that did not pass the e-IWO edits.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EiwoTracking_T1', @level2type=N'COLUMN',@level2name=N'FirstError_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Name of the second field that did not pass the e-IWO edits.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EiwoTracking_T1', @level2type=N'COLUMN',@level2name=N'SecondError_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates that a record has more than two errors.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EiwoTracking_T1', @level2type=N'COLUMN',@level2name=N'MultipleError_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The date on which state received the result from the Portal.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EiwoTracking_T1', @level2type=N'COLUMN',@level2name=N'ReceivedResult_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates Y if this income withholding has to be resent to Employer otherwise N.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EiwoTracking_T1', @level2type=N'COLUMN',@level2name=N'Resend_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the information sent in the EIWO extract file for this record.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EiwoTracking_T1', @level2type=N'COLUMN',@level2name=N'XmlExtEiwo_TEXT'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'This table is used in BATCH_ENF_GEN_EIWO and BATCH_ENF_EIWO_UPDATES Packages to track the e-IWO.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EiwoTracking_T1'
GO
