USE [DEV_TMS_UI]
GO
/****** Object:  Table [dbo].[tblErrorMessage]    Script Date: 6/3/2015 2:40:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tblErrorMessage](
	[Error_CODE] [char](5) NULL,
	[DescriptionError_TEXT] [varchar](300) NULL,
	[TypeError_CODE] [char](1) NULL,
	[Update_DTTM] [datetime2](7) NULL,
	[WorkerUpdate_ID] [char](30) NULL,
	[BeginValidity_DATE] [date] NULL,
	[TransactionEventSeq_NUMB] [numeric](19, 0) NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
EXEC sys.sp_addextendedproperty @name=N'Error_CODE', @value=N'Error number for the Transaction' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblErrorMessage', @level2type=N'COLUMN',@level2name=N'Error_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'DescriptionError_TEXT', @value=N'Error Description text' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblErrorMessage', @level2type=N'COLUMN',@level2name=N'DescriptionError_TEXT'
GO
EXEC sys.sp_addextendedproperty @name=N'TypeError_CODE', @value=N'Indicates the message code is a error(E) or warning(W) or information(I)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblErrorMessage', @level2type=N'COLUMN',@level2name=N'TypeError_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Update_DTTM', @value=N'date time on whic the Record is modified' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblErrorMessage', @level2type=N'COLUMN',@level2name=N'Update_DTTM'
GO
EXEC sys.sp_addextendedproperty @name=N'WorkerUpdate_ID', @value=N'worker id who is responsible for the Modification of the Record' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblErrorMessage', @level2type=N'COLUMN',@level2name=N'WorkerUpdate_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'BeginValidity_DATE', @value=N'Begin date for the Record, The record is valid from the Date' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblErrorMessage', @level2type=N'COLUMN',@level2name=N'BeginValidity_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'TransactionEventSeq_NUMB', @value=N'Sequence number for the particular transaction' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblErrorMessage', @level2type=N'COLUMN',@level2name=N'TransactionEventSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'tblErrorMessage', @value=N'It contains the error messages and error type for the transaction' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblErrorMessage'
GO
