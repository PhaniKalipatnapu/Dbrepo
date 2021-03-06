USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CaseReassignmentRequest_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CaseReassignmentRequest_T1', @level2type=N'COLUMN',@level2name=N'Update_DTTM'

GO
EXEC sys.sp_dropextendedproperty @name=N'3' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CaseReassignmentRequest_T1', @level2type=N'COLUMN',@level2name=N'TransactionEventSeq_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CaseReassignmentRequest_T1', @level2type=N'COLUMN',@level2name=N'WorkerUpdate_ID'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CaseReassignmentRequest_T1', @level2type=N'COLUMN',@level2name=N'Processed_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CaseReassignmentRequest_T1', @level2type=N'COLUMN',@level2name=N'WorkerRequest_ID'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CaseReassignmentRequest_T1', @level2type=N'COLUMN',@level2name=N'TypeRequest_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CaseReassignmentRequest_T1', @level2type=N'COLUMN',@level2name=N'Status_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CaseReassignmentRequest_T1', @level2type=N'COLUMN',@level2name=N'NewAlphaRangeTo_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CaseReassignmentRequest_T1', @level2type=N'COLUMN',@level2name=N'NewAlphaRangeFrom_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CaseReassignmentRequest_T1', @level2type=N'COLUMN',@level2name=N'Request_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CaseReassignmentRequest_T1', @level2type=N'COLUMN',@level2name=N'Worker_ID'

GO
EXEC sys.sp_dropextendedproperty @name=N'2' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CaseReassignmentRequest_T1', @level2type=N'COLUMN',@level2name=N'Role_ID'

GO
EXEC sys.sp_dropextendedproperty @name=N'1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CaseReassignmentRequest_T1', @level2type=N'COLUMN',@level2name=N'Office_IDNO'

GO
/****** Object:  Table [dbo].[CaseReassignmentRequest_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[CaseReassignmentRequest_T1]
GO
/****** Object:  Table [dbo].[CaseReassignmentRequest_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[CaseReassignmentRequest_T1](
	[Office_IDNO] [numeric](3, 0) NOT NULL,
	[Role_ID] [char](10) NOT NULL,
	[Worker_ID] [char](30) NOT NULL,
	[Request_DATE] [date] NOT NULL,
	[NewAlphaRangeFrom_CODE] [char](5) NOT NULL,
	[NewAlphaRangeTo_CODE] [char](5) NOT NULL,
	[Status_CODE] [char](1) NOT NULL,
	[TypeRequest_CODE] [char](1) NOT NULL,
	[WorkerRequest_ID] [char](30) NOT NULL,
	[Processed_DATE] [date] NOT NULL,
	[WorkerUpdate_ID] [char](30) NOT NULL,
	[TransactionEventSeq_NUMB] [numeric](19, 0) NOT NULL,
	[Update_DTTM] [datetime2](7) NOT NULL,
 CONSTRAINT [CRAS_I1] PRIMARY KEY CLUSTERED 
(
	[Office_IDNO] ASC,
	[Role_ID] ASC,
	[TransactionEventSeq_NUMB] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
EXEC sys.sp_addextendedproperty @name=N'1', @value=N'Unique ID of the office code where reassignment is requested.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CaseReassignmentRequest_T1', @level2type=N'COLUMN',@level2name=N'Office_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'2', @value=N'Unique ID of the Role selected for reassignment.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CaseReassignmentRequest_T1', @level2type=N'COLUMN',@level2name=N'Role_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Worker ID whose Alpha range is modified in ASMT screen.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CaseReassignmentRequest_T1', @level2type=N'COLUMN',@level2name=N'Worker_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Date on which the case reassignment is requested.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CaseReassignmentRequest_T1', @level2type=N'COLUMN',@level2name=N'Request_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Modified Specific alphabet starting point.  Possible values are between A and Z' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CaseReassignmentRequest_T1', @level2type=N'COLUMN',@level2name=N'NewAlphaRangeFrom_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Modified Specific alphabet ending point. Possible values are between A and Z' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CaseReassignmentRequest_T1', @level2type=N'COLUMN',@level2name=N'NewAlphaRangeTo_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This field is used to identify the status of a member’s address on AHIS. Values are obtained from REFM (CONF/CON1)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CaseReassignmentRequest_T1', @level2type=N'COLUMN',@level2name=N'Status_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'These values are the two checkbox selections in ASMT screen. Possible values are R- Reassignment request for the given role, O-Reassignment request for a given offices.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CaseReassignmentRequest_T1', @level2type=N'COLUMN',@level2name=N'TypeRequest_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Worker who requested the case reassignment.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CaseReassignmentRequest_T1', @level2type=N'COLUMN',@level2name=N'WorkerRequest_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This column will have low date as 01/01/0001 when the request is placed from ASMT screen. It will be updated with the batch effective date when the records are processed by the batch.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CaseReassignmentRequest_T1', @level2type=N'COLUMN',@level2name=N'Processed_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the worker ID who created/modified this record.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CaseReassignmentRequest_T1', @level2type=N'COLUMN',@level2name=N'WorkerUpdate_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'3', @value=N'Unique Sequence Number that will be generated for a Transaction on the Table. This field is used for checking concurrency at the time of online transaction updates.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CaseReassignmentRequest_T1', @level2type=N'COLUMN',@level2name=N'TransactionEventSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the effective Date with Time at which this record was inserted in this table.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CaseReassignmentRequest_T1', @level2type=N'COLUMN',@level2name=N'Update_DTTM'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'This table stores the request information provided through the online screen to perform case re-assignment for a specific Office or Roles. This request table will be used by the Case Re-assignment batch program to process these request and update the case assignments accordingly.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CaseReassignmentRequest_T1'
GO
