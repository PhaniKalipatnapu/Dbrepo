USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractTransHeaderBlocks_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractTransHeaderBlocks_T1', @level2type=N'COLUMN',@level2name=N'ExchangeMode_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractTransHeaderBlocks_T1', @level2type=N'COLUMN',@level2name=N'Transaction_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractTransHeaderBlocks_T1', @level2type=N'COLUMN',@level2name=N'RejectReason_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractTransHeaderBlocks_T1', @level2type=N'COLUMN',@level2name=N'Received_DTTM'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractTransHeaderBlocks_T1', @level2type=N'COLUMN',@level2name=N'ErrorReason_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractTransHeaderBlocks_T1', @level2type=N'COLUMN',@level2name=N'CsenetVersion_ID'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractTransHeaderBlocks_T1', @level2type=N'COLUMN',@level2name=N'End_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractTransHeaderBlocks_T1', @level2type=N'COLUMN',@level2name=N'Info_QNTY'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractTransHeaderBlocks_T1', @level2type=N'COLUMN',@level2name=N'Collection_QNTY'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractTransHeaderBlocks_T1', @level2type=N'COLUMN',@level2name=N'Order_QNTY'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractTransHeaderBlocks_T1', @level2type=N'COLUMN',@level2name=N'Participant_QNTY'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractTransHeaderBlocks_T1', @level2type=N'COLUMN',@level2name=N'NcpLoc_QNTY'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractTransHeaderBlocks_T1', @level2type=N'COLUMN',@level2name=N'Ncp_QNTY'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractTransHeaderBlocks_T1', @level2type=N'COLUMN',@level2name=N'CaseData_QNTY'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractTransHeaderBlocks_T1', @level2type=N'COLUMN',@level2name=N'Attachments_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractTransHeaderBlocks_T1', @level2type=N'COLUMN',@level2name=N'ActionResolution_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractTransHeaderBlocks_T1', @level2type=N'COLUMN',@level2name=N'Transaction_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractTransHeaderBlocks_T1', @level2type=N'COLUMN',@level2name=N'WorkerUpdate_ID'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractTransHeaderBlocks_T1', @level2type=N'COLUMN',@level2name=N'Overdue_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractTransHeaderBlocks_T1', @level2type=N'COLUMN',@level2name=N'Response_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractTransHeaderBlocks_T1', @level2type=N'COLUMN',@level2name=N'Due_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractTransHeaderBlocks_T1', @level2type=N'COLUMN',@level2name=N'TimeSent_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractTransHeaderBlocks_T1', @level2type=N'COLUMN',@level2name=N'InterstateFrmsPrint_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractTransHeaderBlocks_T1', @level2type=N'COLUMN',@level2name=N'ProcComplete_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractTransHeaderBlocks_T1', @level2type=N'COLUMN',@level2name=N'SntToStHost_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractTransHeaderBlocks_T1', @level2type=N'COLUMN',@level2name=N'AttachDue_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractTransHeaderBlocks_T1', @level2type=N'COLUMN',@level2name=N'TranStatus_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractTransHeaderBlocks_T1', @level2type=N'COLUMN',@level2name=N'Case_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractTransHeaderBlocks_T1', @level2type=N'COLUMN',@level2name=N'Reason_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractTransHeaderBlocks_T1', @level2type=N'COLUMN',@level2name=N'Action_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractTransHeaderBlocks_T1', @level2type=N'COLUMN',@level2name=N'Function_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractTransHeaderBlocks_T1', @level2type=N'COLUMN',@level2name=N'CsenetTran_ID'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractTransHeaderBlocks_T1', @level2type=N'COLUMN',@level2name=N'IVDOutOfStateOfficeFips_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractTransHeaderBlocks_T1', @level2type=N'COLUMN',@level2name=N'IVDOutOfStateCountyFips_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractTransHeaderBlocks_T1', @level2type=N'COLUMN',@level2name=N'IVDOutOfStateFips_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractTransHeaderBlocks_T1', @level2type=N'COLUMN',@level2name=N'IVDOutOfStateCase_ID'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractTransHeaderBlocks_T1', @level2type=N'COLUMN',@level2name=N'OfficeFips_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractTransHeaderBlocks_T1', @level2type=N'COLUMN',@level2name=N'CountyFips_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractTransHeaderBlocks_T1', @level2type=N'COLUMN',@level2name=N'StateFips_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractTransHeaderBlocks_T1', @level2type=N'COLUMN',@level2name=N'IoDirection_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractTransHeaderBlocks_T1', @level2type=N'COLUMN',@level2name=N'Message_ID'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractTransHeaderBlocks_T1', @level2type=N'COLUMN',@level2name=N'TransHeader_IDNO'

GO
/****** Object:  Table [dbo].[ExtractTransHeaderBlocks_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[ExtractTransHeaderBlocks_T1]
GO
/****** Object:  Table [dbo].[ExtractTransHeaderBlocks_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ExtractTransHeaderBlocks_T1](
	[TransHeader_IDNO] [char](12) NOT NULL,
	[Message_ID] [char](11) NOT NULL,
	[IoDirection_CODE] [char](1) NOT NULL,
	[StateFips_CODE] [char](2) NOT NULL,
	[CountyFips_CODE] [char](3) NOT NULL,
	[OfficeFips_CODE] [char](2) NOT NULL,
	[IVDOutOfStateCase_ID] [char](15) NOT NULL,
	[IVDOutOfStateFips_CODE] [char](2) NOT NULL,
	[IVDOutOfStateCountyFips_CODE] [char](3) NOT NULL,
	[IVDOutOfStateOfficeFips_CODE] [char](2) NOT NULL,
	[CsenetTran_ID] [char](10) NOT NULL,
	[Function_CODE] [char](3) NOT NULL,
	[Action_CODE] [char](1) NOT NULL,
	[Reason_CODE] [char](5) NOT NULL,
	[Case_IDNO] [char](11) NOT NULL,
	[TranStatus_CODE] [char](2) NOT NULL,
	[AttachDue_DATE] [date] NOT NULL,
	[SntToStHost_CODE] [char](1) NOT NULL,
	[ProcComplete_CODE] [char](1) NOT NULL,
	[InterstateFrmsPrint_CODE] [char](1) NOT NULL,
	[TimeSent_DATE] [date] NOT NULL,
	[Due_DATE] [date] NOT NULL,
	[Response_DATE] [date] NOT NULL,
	[Overdue_CODE] [char](1) NOT NULL,
	[WorkerUpdate_ID] [char](30) NOT NULL,
	[Transaction_DATE] [date] NOT NULL,
	[ActionResolution_DATE] [date] NOT NULL,
	[Attachments_INDC] [char](1) NOT NULL,
	[CaseData_QNTY] [char](1) NOT NULL,
	[Ncp_QNTY] [char](1) NOT NULL,
	[NcpLoc_QNTY] [char](1) NOT NULL,
	[Participant_QNTY] [char](1) NOT NULL,
	[Order_QNTY] [char](1) NOT NULL,
	[Collection_QNTY] [char](1) NOT NULL,
	[Info_QNTY] [char](1) NOT NULL,
	[End_DATE] [date] NOT NULL,
	[CsenetVersion_ID] [char](3) NOT NULL,
	[ErrorReason_CODE] [char](2) NOT NULL,
	[Received_DTTM] [datetime2](7) NOT NULL,
	[RejectReason_CODE] [char](5) NOT NULL,
	[Transaction_IDNO] [char](12) NOT NULL,
	[ExchangeMode_CODE] [char](1) NOT NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'A unique ID generated by the system to indicate the record. This is the key value by which the record will be  identified.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractTransHeaderBlocks_T1', @level2type=N'COLUMN',@level2name=N'TransHeader_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Message ID.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractTransHeaderBlocks_T1', @level2type=N'COLUMN',@level2name=N'Message_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'IN/OUT transaction Direction.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractTransHeaderBlocks_T1', @level2type=N'COLUMN',@level2name=N'IoDirection_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The Local-FIPS-State must contain valid FIPS codes.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractTransHeaderBlocks_T1', @level2type=N'COLUMN',@level2name=N'StateFips_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'County FIPS Code.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractTransHeaderBlocks_T1', @level2type=N'COLUMN',@level2name=N'CountyFips_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The value of the Local-FIPS-Sub portion of the FIPS code will not be edited.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractTransHeaderBlocks_T1', @level2type=N'COLUMN',@level2name=N'OfficeFips_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The Case ID used by the sending jurisdiction with which you are communicating.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractTransHeaderBlocks_T1', @level2type=N'COLUMN',@level2name=N'IVDOutOfStateCase_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'State FIPS for the state with which you are communicating.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractTransHeaderBlocks_T1', @level2type=N'COLUMN',@level2name=N'IVDOutOfStateFips_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'County FIPS for the state with which you are communicating.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractTransHeaderBlocks_T1', @level2type=N'COLUMN',@level2name=N'IVDOutOfStateCountyFips_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The value of the Local-FIPS-Sub portion of the FIPS code will not be edited.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractTransHeaderBlocks_T1', @level2type=N'COLUMN',@level2name=N'IVDOutOfStateOfficeFips_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Transaction ID.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractTransHeaderBlocks_T1', @level2type=N'COLUMN',@level2name=N'CsenetTran_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Function Code.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractTransHeaderBlocks_T1', @level2type=N'COLUMN',@level2name=N'Function_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Action Code.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractTransHeaderBlocks_T1', @level2type=N'COLUMN',@level2name=N'Action_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Reason Code.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractTransHeaderBlocks_T1', @level2type=N'COLUMN',@level2name=N'Reason_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'DACSES Case Id.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractTransHeaderBlocks_T1', @level2type=N'COLUMN',@level2name=N'Case_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Transaction Type.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractTransHeaderBlocks_T1', @level2type=N'COLUMN',@level2name=N'TranStatus_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Attachment Due Date.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractTransHeaderBlocks_T1', @level2type=N'COLUMN',@level2name=N'AttachDue_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This field is reserved for a future version. For the current version, it is blank-filled.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractTransHeaderBlocks_T1', @level2type=N'COLUMN',@level2name=N'SntToStHost_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This field is reserved for a future version. For the current version, it is blank-filled.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractTransHeaderBlocks_T1', @level2type=N'COLUMN',@level2name=N'ProcComplete_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicator for Interstate  forms Printed.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractTransHeaderBlocks_T1', @level2type=N'COLUMN',@level2name=N'InterstateFrmsPrint_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Sent Time and date.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractTransHeaderBlocks_T1', @level2type=N'COLUMN',@level2name=N'TimeSent_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Due Date.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractTransHeaderBlocks_T1', @level2type=N'COLUMN',@level2name=N'Due_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Response Date.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractTransHeaderBlocks_T1', @level2type=N'COLUMN',@level2name=N'Response_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Overdue Indicator.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractTransHeaderBlocks_T1', @level2type=N'COLUMN',@level2name=N'Overdue_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the worker ID who created/modified this record.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractTransHeaderBlocks_T1', @level2type=N'COLUMN',@level2name=N'WorkerUpdate_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Transaction Date.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractTransHeaderBlocks_T1', @level2type=N'COLUMN',@level2name=N'Transaction_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Action Resolution Date.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractTransHeaderBlocks_T1', @level2type=N'COLUMN',@level2name=N'ActionResolution_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Attachment Indicator.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractTransHeaderBlocks_T1', @level2type=N'COLUMN',@level2name=N'Attachments_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Case Data Block Indicator Number.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractTransHeaderBlocks_T1', @level2type=N'COLUMN',@level2name=N'CaseData_QNTY'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'NCP Data Block Indicator Number.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractTransHeaderBlocks_T1', @level2type=N'COLUMN',@level2name=N'Ncp_QNTY'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'NCP Location Indicator Number.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractTransHeaderBlocks_T1', @level2type=N'COLUMN',@level2name=N'NcpLoc_QNTY'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Participant Indicator Number.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractTransHeaderBlocks_T1', @level2type=N'COLUMN',@level2name=N'Participant_QNTY'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Order Block Indicator Number.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractTransHeaderBlocks_T1', @level2type=N'COLUMN',@level2name=N'Order_QNTY'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Collection block indicator Number.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractTransHeaderBlocks_T1', @level2type=N'COLUMN',@level2name=N'Collection_QNTY'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Information Block Indicator number.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractTransHeaderBlocks_T1', @level2type=N'COLUMN',@level2name=N'Info_QNTY'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'End Date.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractTransHeaderBlocks_T1', @level2type=N'COLUMN',@level2name=N'End_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'CSENET Version.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractTransHeaderBlocks_T1', @level2type=N'COLUMN',@level2name=N'CsenetVersion_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Error Reason Code.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractTransHeaderBlocks_T1', @level2type=N'COLUMN',@level2name=N'ErrorReason_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Received Date.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractTransHeaderBlocks_T1', @level2type=N'COLUMN',@level2name=N'Received_DTTM'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Reject Reason.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractTransHeaderBlocks_T1', @level2type=N'COLUMN',@level2name=N'RejectReason_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Transaction Number.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractTransHeaderBlocks_T1', @level2type=N'COLUMN',@level2name=N'Transaction_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Exchange mode indicator.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractTransHeaderBlocks_T1', @level2type=N'COLUMN',@level2name=N'ExchangeMode_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'This is a staging table to hold data for Main Header Data Block and carry out validations for outbound CSENET transaction' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractTransHeaderBlocks_T1'
GO
