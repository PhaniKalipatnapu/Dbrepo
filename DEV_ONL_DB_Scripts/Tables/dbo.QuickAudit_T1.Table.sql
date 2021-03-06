USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'QuickAudit_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'QuickAudit_T1', @level2type=N'COLUMN',@level2name=N'QuickSeq_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'QuickAudit_T1', @level2type=N'COLUMN',@level2name=N'DescriptionError_TEXT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'QuickAudit_T1', @level2type=N'COLUMN',@level2name=N'End_DTTM'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'QuickAudit_T1', @level2type=N'COLUMN',@level2name=N'Start_DTTM'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'QuickAudit_T1', @level2type=N'COLUMN',@level2name=N'To_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'QuickAudit_T1', @level2type=N'COLUMN',@level2name=N'From_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'QuickAudit_T1', @level2type=N'COLUMN',@level2name=N'Case_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'QuickAudit_T1', @level2type=N'COLUMN',@level2name=N'OtherPartyCase_ID'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'QuickAudit_T1', @level2type=N'COLUMN',@level2name=N'IVDOutOfState_ID'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'QuickAudit_T1', @level2type=N'COLUMN',@level2name=N'IVDOutOfStateUid_TEXT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'QuickAudit_T1', @level2type=N'COLUMN',@level2name=N'OtherPartyFips_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'QuickAudit_T1', @level2type=N'COLUMN',@level2name=N'IVDOutOfStateWorker_ID'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'QuickAudit_T1', @level2type=N'COLUMN',@level2name=N'ReqServer_ID'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'QuickAudit_T1', @level2type=N'COLUMN',@level2name=N'TypeRequest_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'QuickAudit_T1', @level2type=N'COLUMN',@level2name=N'Request_DATE'

GO
/****** Object:  Table [dbo].[QuickAudit_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[QuickAudit_T1]
GO
/****** Object:  Table [dbo].[QuickAudit_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[QuickAudit_T1](
	[Request_DATE] [date] NOT NULL,
	[TypeRequest_CODE] [varchar](100) NOT NULL,
	[ReqServer_ID] [char](20) NOT NULL,
	[IVDOutOfStateWorker_ID] [varchar](50) NOT NULL,
	[OtherPartyFips_CODE] [char](7) NOT NULL,
	[IVDOutOfStateUid_TEXT] [varchar](100) NOT NULL,
	[IVDOutOfState_ID] [char](3) NOT NULL,
	[OtherPartyCase_ID] [char](15) NOT NULL,
	[Case_IDNO] [numeric](6, 0) NOT NULL,
	[From_DATE] [date] NOT NULL,
	[To_DATE] [date] NOT NULL,
	[Start_DTTM] [datetime2](7) NOT NULL,
	[End_DTTM] [datetime2](7) NOT NULL,
	[DescriptionError_TEXT] [varchar](200) NOT NULL,
	[QuickSeq_NUMB] [numeric](19, 0) IDENTITY(1,1) NOT NULL,
 CONSTRAINT [QADT_I1] PRIMARY KEY CLUSTERED 
(
	[QuickSeq_NUMB] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the quick information request date.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'QuickAudit_T1', @level2type=N'COLUMN',@level2name=N'Request_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the type of information requested from other state like Contact Information,Financial Information, case information etc.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'QuickAudit_T1', @level2type=N'COLUMN',@level2name=N'TypeRequest_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the system identifier for other state.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'QuickAudit_T1', @level2type=N'COLUMN',@level2name=N'ReqServer_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the server user identifier for the other state worker.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'QuickAudit_T1', @level2type=N'COLUMN',@level2name=N'IVDOutOfStateWorker_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the other state case information.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'QuickAudit_T1', @level2type=N'COLUMN',@level2name=N'OtherPartyFips_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the state generated idenfier.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'QuickAudit_T1', @level2type=N'COLUMN',@level2name=N'IVDOutOfStateUid_TEXT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the requesting state code.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'QuickAudit_T1', @level2type=N'COLUMN',@level2name=N'IVDOutOfState_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the other state case id.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'QuickAudit_T1', @level2type=N'COLUMN',@level2name=N'OtherPartyCase_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the DACSES case id requested from other state.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'QuickAudit_T1', @level2type=N'COLUMN',@level2name=N'Case_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the starting date of the date range for which the audit information is requested.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'QuickAudit_T1', @level2type=N'COLUMN',@level2name=N'From_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the ending date of the date range for which the audit information is requested.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'QuickAudit_T1', @level2type=N'COLUMN',@level2name=N'To_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the the quick web service process starting time for the given request.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'QuickAudit_T1', @level2type=N'COLUMN',@level2name=N'Start_DTTM'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the ending time of the process requested.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'QuickAudit_T1', @level2type=N'COLUMN',@level2name=N'End_DTTM'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the error description if any.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'QuickAudit_T1', @level2type=N'COLUMN',@level2name=N'DescriptionError_TEXT'
GO
EXEC sys.sp_addextendedproperty @name=N'1', @value=N'Unique Sequence Number that will be generated for any given Transaction on the Table.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'QuickAudit_T1', @level2type=N'COLUMN',@level2name=N'QuickSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'This table is used to store the incoming information for the quick web service for auditing purpose.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'QuickAudit_T1'
GO
