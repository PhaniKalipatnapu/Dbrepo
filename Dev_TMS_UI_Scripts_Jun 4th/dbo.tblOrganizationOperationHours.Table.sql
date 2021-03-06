USE [DEV_TMS_UI]
GO
/****** Object:  Table [dbo].[tblOrganizationOperationHours]    Script Date: 6/4/2015 11:19:04 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tblOrganizationOperationHours](
	[Operation_IDNO] [int] IDENTITY(1,1) NOT NULL,
	[Location_IDNO] [int] NOT NULL,
	[Organization_ID] [varchar](8) NOT NULL,
	[OperationDay_CODE] [varchar](3) NULL,
	[OperationType_CODE] [varchar](3) NULL,
	[Opening_TIME] [time](7) NULL,
	[Closing_TIME] [time](7) NULL,
	[LunchBreak_INDC] [char](1) NULL,
	[LunchStart_TIME] [time](7) NULL,
	[LunchEnd_TIME] [time](7) NULL,
	[BeginValidity_DATE] [date] NOT NULL,
	[TransactionEventSeq_NUMB] [numeric](19, 0) NOT NULL,
	[Update_DTTM] [datetime2](7) NULL,
	[WorkerUpdate_ID] [varchar](8) NULL,
	[operational_hours] [varchar](255) NULL,
 CONSTRAINT [PK_tblOrganizationOperationHours] PRIMARY KEY CLUSTERED 
(
	[Operation_IDNO] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[tblOrganizationOperationHours]  WITH CHECK ADD  CONSTRAINT [FK_tblOrganizationOperationHours_Location_IDNO] FOREIGN KEY([Location_IDNO])
REFERENCES [dbo].[tblOrganizationLocation] ([Location_IDNO])
GO
ALTER TABLE [dbo].[tblOrganizationOperationHours] CHECK CONSTRAINT [FK_tblOrganizationOperationHours_Location_IDNO]
GO
ALTER TABLE [dbo].[tblOrganizationOperationHours]  WITH CHECK ADD  CONSTRAINT [FK_tblOrganizationOperationHours_Organization_ID] FOREIGN KEY([Organization_ID])
REFERENCES [dbo].[tblOrganization] ([Organization_ID])
GO
ALTER TABLE [dbo].[tblOrganizationOperationHours] CHECK CONSTRAINT [FK_tblOrganizationOperationHours_Organization_ID]
GO
EXEC sys.sp_addextendedproperty @name=N'Operation_IDNO', @value=N'Unique id for user hours entry' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblOrganizationOperationHours', @level2type=N'COLUMN',@level2name=N'Operation_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Location_IDNO', @value=N'Unique id for the organization location ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblOrganizationOperationHours', @level2type=N'COLUMN',@level2name=N'Location_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Organization_ID', @value=N'Unique id for the particular Organization, Organization Starts with "ORG", Example "ORG00001"' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblOrganizationOperationHours', @level2type=N'COLUMN',@level2name=N'Organization_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'OperationDay_CODE', @value=N'It contains the day code for the organization working days... Table_ID:OPER / TableSub_ID:WEEK' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblOrganizationOperationHours', @level2type=N'COLUMN',@level2name=N'OperationDay_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'OperationType_CODE', @value=N'It contains the organization oreration type.. Table_ID:OPER / TableSub_ID:TYPE' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblOrganizationOperationHours', @level2type=N'COLUMN',@level2name=N'OperationType_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'OpeningTime_TIME', @value=N'It contains the opening time for the organization' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblOrganizationOperationHours', @level2type=N'COLUMN',@level2name=N'Opening_TIME'
GO
EXEC sys.sp_addextendedproperty @name=N'ClosingTime_TIME', @value=N'It contains the closing time for the organization' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblOrganizationOperationHours', @level2type=N'COLUMN',@level2name=N'Closing_TIME'
GO
EXEC sys.sp_addextendedproperty @name=N'LunchBreak_INDC', @value=N'It contains the lunch break indication' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblOrganizationOperationHours', @level2type=N'COLUMN',@level2name=N'LunchBreak_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'LunchStart_TIME', @value=N'It contains the lunch break start time' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblOrganizationOperationHours', @level2type=N'COLUMN',@level2name=N'LunchStart_TIME'
GO
EXEC sys.sp_addextendedproperty @name=N'LunchEnd_TIME', @value=N'It contains the lunch break end time' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblOrganizationOperationHours', @level2type=N'COLUMN',@level2name=N'LunchEnd_TIME'
GO
EXEC sys.sp_addextendedproperty @name=N'BeginValidity_DATE', @value=N'Begin date for the Record, The record is valid from the Date' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblOrganizationOperationHours', @level2type=N'COLUMN',@level2name=N'BeginValidity_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'TransactionEventSeq_NUMB', @value=N'Sequence number for the particular transaction' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblOrganizationOperationHours', @level2type=N'COLUMN',@level2name=N'TransactionEventSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Update_DTTM', @value=N'date time on whic the Record is modified' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblOrganizationOperationHours', @level2type=N'COLUMN',@level2name=N'Update_DTTM'
GO
EXEC sys.sp_addextendedproperty @name=N'WorkerUpdate_ID', @value=N'worker id who is responsible for the Modification of the Record' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblOrganizationOperationHours', @level2type=N'COLUMN',@level2name=N'WorkerUpdate_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'tblOrganizationOperationHours', @value=N'It contains the organization working hours details' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblOrganizationOperationHours'
GO
