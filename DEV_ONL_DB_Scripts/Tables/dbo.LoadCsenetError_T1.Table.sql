USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadCsenetError_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadCsenetError_T1', @level2type=N'COLUMN',@level2name=N'Process_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadCsenetError_T1', @level2type=N'COLUMN',@level2name=N'Run_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadCsenetError_T1', @level2type=N'COLUMN',@level2name=N'ErrorMessage_TEXT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadCsenetError_T1', @level2type=N'COLUMN',@level2name=N'TransactionSerial_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadCsenetError_T1', @level2type=N'COLUMN',@level2name=N'Error_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadCsenetError_T1', @level2type=N'COLUMN',@level2name=N'Transaction_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadCsenetError_T1', @level2type=N'COLUMN',@level2name=N'ActionResolution_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadCsenetError_T1', @level2type=N'COLUMN',@level2name=N'Reason_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadCsenetError_T1', @level2type=N'COLUMN',@level2name=N'Function_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadCsenetError_T1', @level2type=N'COLUMN',@level2name=N'Action_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadCsenetError_T1', @level2type=N'COLUMN',@level2name=N'IVDOutOfStateCase_ID'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadCsenetError_T1', @level2type=N'COLUMN',@level2name=N'Case_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadCsenetError_T1', @level2type=N'COLUMN',@level2name=N'IVDOutOfStateFips_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadCsenetError_T1', @level2type=N'COLUMN',@level2name=N'InStateFips_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadCsenetError_T1', @level2type=N'COLUMN',@level2name=N'Sequence_NUMB'

GO
/****** Object:  Table [dbo].[LoadCsenetError_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[LoadCsenetError_T1]
GO
/****** Object:  Table [dbo].[LoadCsenetError_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING OFF
GO
CREATE TABLE [dbo].[LoadCsenetError_T1](
	[Seq_IDNO] [numeric](19, 0) IDENTITY(1,1) NOT NULL,
	[Sequence_NUMB] [char](6) NOT NULL,
	[InStateFips_CODE] [char](7) NOT NULL,
	[IVDOutOfStateFips_CODE] [char](7) NOT NULL,
	[Case_IDNO] [char](15) NOT NULL,
	[IVDOutOfStateCase_ID] [char](15) NOT NULL,
	[Action_CODE] [char](1) NOT NULL,
	[Function_CODE] [char](3) NOT NULL,
	[Reason_CODE] [char](5) NOT NULL,
	[ActionResolution_DATE] [char](8) NOT NULL,
	[Transaction_DATE] [char](8) NOT NULL,
	[Error_CODE] [char](4) NOT NULL,
	[TransactionSerial_NUMB] [char](12) NOT NULL,
	[ErrorMessage_TEXT] [varchar](41) NOT NULL,
	[Run_DATE] [date] NOT NULL,
	[FileLoad_DATE] [date] NOT NULL
) ON [PRIMARY]
SET ANSI_PADDING ON
ALTER TABLE [dbo].[LoadCsenetError_T1] ADD [Process_INDC] [char](1) NOT NULL
 CONSTRAINT [LCSER_I1] PRIMARY KEY CLUSTERED 
(
	[Seq_IDNO] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Sequential number assigned to the error by the CSENet 2000 application.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadCsenetError_T1', @level2type=N'COLUMN',@level2name=N'Sequence_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Seven-digit Federal Information Processing Standard (FIPS) state code that originated the transaction.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadCsenetError_T1', @level2type=N'COLUMN',@level2name=N'InStateFips_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Seven-digit FIPS state code that will receive the transaction.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadCsenetError_T1', @level2type=N'COLUMN',@level2name=N'IVDOutOfStateFips_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies originating state''s Case ID on the transaction that entered.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadCsenetError_T1', @level2type=N'COLUMN',@level2name=N'Case_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies other state''s Case ID on the transaction that entered.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadCsenetError_T1', @level2type=N'COLUMN',@level2name=N'IVDOutOfStateCase_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Action codes e.g., Request, Acknowledgment, etc. from the original transaction.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadCsenetError_T1', @level2type=N'COLUMN',@level2name=N'Action_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'CSENet function. Functional code.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadCsenetError_T1', @level2type=N'COLUMN',@level2name=N'Function_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'CSENet Reason Code.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadCsenetError_T1', @level2type=N'COLUMN',@level2name=N'Reason_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The action resolution date from the transaction header of CSENET transactions.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadCsenetError_T1', @level2type=N'COLUMN',@level2name=N'ActionResolution_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Values are obtained from the Transaction Date field in the header for the record that received the error.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadCsenetError_T1', @level2type=N'COLUMN',@level2name=N'Transaction_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Error Code transmitted back by CSENET Hub.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadCsenetError_T1', @level2type=N'COLUMN',@level2name=N'Error_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Serial number of the invalid transaction.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadCsenetError_T1', @level2type=N'COLUMN',@level2name=N'TransactionSerial_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Description of the error.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadCsenetError_T1', @level2type=N'COLUMN',@level2name=N'ErrorMessage_TEXT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Run date of the Batch.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadCsenetError_T1', @level2type=N'COLUMN',@level2name=N'Run_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates whether the process already ran or not.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadCsenetError_T1', @level2type=N'COLUMN',@level2name=N'Process_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'This is the Load Table to hold CSENet Errors' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadCsenetError_T1'
GO
