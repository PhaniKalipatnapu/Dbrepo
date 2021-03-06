USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadTransHeaderBlocks_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadTransHeaderBlocks_T1', @level2type=N'COLUMN',@level2name=N'Process_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadTransHeaderBlocks_T1', @level2type=N'COLUMN',@level2name=N'RejectReason_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadTransHeaderBlocks_T1', @level2type=N'COLUMN',@level2name=N'Received_DTTM'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadTransHeaderBlocks_T1', @level2type=N'COLUMN',@level2name=N'ErrorReason_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadTransHeaderBlocks_T1', @level2type=N'COLUMN',@level2name=N'End_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadTransHeaderBlocks_T1', @level2type=N'COLUMN',@level2name=N'Order_QNTY'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadTransHeaderBlocks_T1', @level2type=N'COLUMN',@level2name=N'Attachments_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadTransHeaderBlocks_T1', @level2type=N'COLUMN',@level2name=N'ActionResolution_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadTransHeaderBlocks_T1', @level2type=N'COLUMN',@level2name=N'Transaction_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadTransHeaderBlocks_T1', @level2type=N'COLUMN',@level2name=N'AttachDue_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadTransHeaderBlocks_T1', @level2type=N'COLUMN',@level2name=N'Received_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadTransHeaderBlocks_T1', @level2type=N'COLUMN',@level2name=N'TranStatus_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadTransHeaderBlocks_T1', @level2type=N'COLUMN',@level2name=N'Stored_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadTransHeaderBlocks_T1', @level2type=N'COLUMN',@level2name=N'Case_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadTransHeaderBlocks_T1', @level2type=N'COLUMN',@level2name=N'Reason_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadTransHeaderBlocks_T1', @level2type=N'COLUMN',@level2name=N'Action_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadTransHeaderBlocks_T1', @level2type=N'COLUMN',@level2name=N'Function_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadTransHeaderBlocks_T1', @level2type=N'COLUMN',@level2name=N'IVDOutOfStateOfficeFips_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadTransHeaderBlocks_T1', @level2type=N'COLUMN',@level2name=N'IVDOutOfStateCountyFips_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadTransHeaderBlocks_T1', @level2type=N'COLUMN',@level2name=N'IVDOutOfStateFips_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadTransHeaderBlocks_T1', @level2type=N'COLUMN',@level2name=N'OfficeFips_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadTransHeaderBlocks_T1', @level2type=N'COLUMN',@level2name=N'CountyFips_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadTransHeaderBlocks_T1', @level2type=N'COLUMN',@level2name=N'StateFips_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadTransHeaderBlocks_T1', @level2type=N'COLUMN',@level2name=N'TransHeader_IDNO'

GO
/****** Object:  Table [dbo].[LoadTransHeaderBlocks_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[LoadTransHeaderBlocks_T1]
GO
/****** Object:  Table [dbo].[LoadTransHeaderBlocks_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING OFF
GO
CREATE TABLE [dbo].[LoadTransHeaderBlocks_T1](
	[Seq_IDNO] [numeric](19, 0) IDENTITY(1,1) NOT NULL,
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
	[CsenetTran_ID] [char](12) NOT NULL,
	[Function_CODE] [char](3) NOT NULL,
	[Action_CODE] [char](1) NOT NULL,
	[Reason_CODE] [char](5) NOT NULL,
	[Case_IDNO] [char](15) NOT NULL,
	[Stored_DATE] [char](8) NOT NULL
) ON [PRIMARY]
SET ANSI_PADDING ON
ALTER TABLE [dbo].[LoadTransHeaderBlocks_T1] ADD [TranStatus_CODE] [char](2) NOT NULL
SET ANSI_PADDING OFF
ALTER TABLE [dbo].[LoadTransHeaderBlocks_T1] ADD [Received_DATE] [char](8) NOT NULL
ALTER TABLE [dbo].[LoadTransHeaderBlocks_T1] ADD [ReceivedYearMonth_NUMB] [char](6) NOT NULL
ALTER TABLE [dbo].[LoadTransHeaderBlocks_T1] ADD [AttachDue_DATE] [char](8) NOT NULL
ALTER TABLE [dbo].[LoadTransHeaderBlocks_T1] ADD [SntToStHost_CODE] [char](1) NOT NULL
ALTER TABLE [dbo].[LoadTransHeaderBlocks_T1] ADD [ProcComplete_CODE] [char](1) NOT NULL
ALTER TABLE [dbo].[LoadTransHeaderBlocks_T1] ADD [InterstateFrmsPrint_CODE] [char](1) NOT NULL
ALTER TABLE [dbo].[LoadTransHeaderBlocks_T1] ADD [WorkerUpdate_ID] [char](30) NOT NULL
ALTER TABLE [dbo].[LoadTransHeaderBlocks_T1] ADD [Transaction_DATE] [char](8) NOT NULL
ALTER TABLE [dbo].[LoadTransHeaderBlocks_T1] ADD [ActionResolution_DATE] [char](8) NOT NULL
ALTER TABLE [dbo].[LoadTransHeaderBlocks_T1] ADD [Attachments_INDC] [char](1) NOT NULL
ALTER TABLE [dbo].[LoadTransHeaderBlocks_T1] ADD [CaseData_QNTY] [char](1) NOT NULL
ALTER TABLE [dbo].[LoadTransHeaderBlocks_T1] ADD [Ncp_QNTY] [char](1) NOT NULL
ALTER TABLE [dbo].[LoadTransHeaderBlocks_T1] ADD [NcpLoc_QNTY] [char](1) NOT NULL
ALTER TABLE [dbo].[LoadTransHeaderBlocks_T1] ADD [Participant_QNTY] [char](1) NOT NULL
ALTER TABLE [dbo].[LoadTransHeaderBlocks_T1] ADD [Order_QNTY] [char](1) NOT NULL
ALTER TABLE [dbo].[LoadTransHeaderBlocks_T1] ADD [Collection_QNTY] [char](1) NOT NULL
ALTER TABLE [dbo].[LoadTransHeaderBlocks_T1] ADD [Info_QNTY] [char](1) NOT NULL
ALTER TABLE [dbo].[LoadTransHeaderBlocks_T1] ADD [End_DATE] [char](8) NOT NULL
ALTER TABLE [dbo].[LoadTransHeaderBlocks_T1] ADD [CsenetVersion_ID] [char](3) NOT NULL
ALTER TABLE [dbo].[LoadTransHeaderBlocks_T1] ADD [ErrorReason_CODE] [char](2) NOT NULL
ALTER TABLE [dbo].[LoadTransHeaderBlocks_T1] ADD [Received_DTTM] [char](8) NOT NULL
ALTER TABLE [dbo].[LoadTransHeaderBlocks_T1] ADD [RejectReason_CODE] [char](5) NOT NULL
ALTER TABLE [dbo].[LoadTransHeaderBlocks_T1] ADD [FileLoad_DATE] [date] NOT NULL
SET ANSI_PADDING ON
ALTER TABLE [dbo].[LoadTransHeaderBlocks_T1] ADD [Process_INDC] [char](1) NOT NULL
 CONSTRAINT [LTHBL_I1] PRIMARY KEY CLUSTERED 
(
	[Seq_IDNO] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'A unique ID generated by the system to indicate the record. This is the key value by which the record will be identified.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadTransHeaderBlocks_T1', @level2type=N'COLUMN',@level2name=N'TransHeader_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The Local-FIPS-State must contain valid FIPS codes.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadTransHeaderBlocks_T1', @level2type=N'COLUMN',@level2name=N'StateFips_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'County FIPS Code.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadTransHeaderBlocks_T1', @level2type=N'COLUMN',@level2name=N'CountyFips_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The value of the Local-FIPS-Sub portion of the FIPS code will not be edited.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadTransHeaderBlocks_T1', @level2type=N'COLUMN',@level2name=N'OfficeFips_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'State FIPS for the state with which you are communicating.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadTransHeaderBlocks_T1', @level2type=N'COLUMN',@level2name=N'IVDOutOfStateFips_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'County FIPS for the state with which you are communicating.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadTransHeaderBlocks_T1', @level2type=N'COLUMN',@level2name=N'IVDOutOfStateCountyFips_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The value of the Local-FIPS-Sub portion of the FIPS code will not be edited.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadTransHeaderBlocks_T1', @level2type=N'COLUMN',@level2name=N'IVDOutOfStateOfficeFips_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Function Code.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadTransHeaderBlocks_T1', @level2type=N'COLUMN',@level2name=N'Function_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Action Code.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadTransHeaderBlocks_T1', @level2type=N'COLUMN',@level2name=N'Action_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Reason Code.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadTransHeaderBlocks_T1', @level2type=N'COLUMN',@level2name=N'Reason_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'DACSES Case Id.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadTransHeaderBlocks_T1', @level2type=N'COLUMN',@level2name=N'Case_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stored Date.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadTransHeaderBlocks_T1', @level2type=N'COLUMN',@level2name=N'Stored_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Transaction Type.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadTransHeaderBlocks_T1', @level2type=N'COLUMN',@level2name=N'TranStatus_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Received Date.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadTransHeaderBlocks_T1', @level2type=N'COLUMN',@level2name=N'Received_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Attachment Due Date.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadTransHeaderBlocks_T1', @level2type=N'COLUMN',@level2name=N'AttachDue_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Transaction Date.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadTransHeaderBlocks_T1', @level2type=N'COLUMN',@level2name=N'Transaction_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Action Resolution Date.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadTransHeaderBlocks_T1', @level2type=N'COLUMN',@level2name=N'ActionResolution_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Attachment Indicator.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadTransHeaderBlocks_T1', @level2type=N'COLUMN',@level2name=N'Attachments_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Order Block Indicator Number.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadTransHeaderBlocks_T1', @level2type=N'COLUMN',@level2name=N'Order_QNTY'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'End Date.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadTransHeaderBlocks_T1', @level2type=N'COLUMN',@level2name=N'End_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Error Reason Code.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadTransHeaderBlocks_T1', @level2type=N'COLUMN',@level2name=N'ErrorReason_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Received Date.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadTransHeaderBlocks_T1', @level2type=N'COLUMN',@level2name=N'Received_DTTM'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Reject Reason.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadTransHeaderBlocks_T1', @level2type=N'COLUMN',@level2name=N'RejectReason_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates if the record is processed or not.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadTransHeaderBlocks_T1', @level2type=N'COLUMN',@level2name=N'Process_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'This is a staging table to hold data for Main Header Data Block and carry out validations for inbound CSENET transaction' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadTransHeaderBlocks_T1'
GO
