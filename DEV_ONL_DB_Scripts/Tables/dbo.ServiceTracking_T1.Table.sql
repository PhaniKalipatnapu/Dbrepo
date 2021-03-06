USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ServiceTracking_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ServiceTracking_T1', @level2type=N'COLUMN',@level2name=N'ServiceCountry_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ServiceTracking_T1', @level2type=N'COLUMN',@level2name=N'TransactionEventSeq_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ServiceTracking_T1', @level2type=N'COLUMN',@level2name=N'Update_DTTM'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ServiceTracking_T1', @level2type=N'COLUMN',@level2name=N'WorkerUpdate_ID'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ServiceTracking_T1', @level2type=N'COLUMN',@level2name=N'EndValidity_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ServiceTracking_T1', @level2type=N'COLUMN',@level2name=N'BeginValidity_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ServiceTracking_T1', @level2type=N'COLUMN',@level2name=N'ServiceNotes_TEXT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ServiceTracking_T1', @level2type=N'COLUMN',@level2name=N'ServiceZip_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ServiceTracking_T1', @level2type=N'COLUMN',@level2name=N'ServiceState_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ServiceTracking_T1', @level2type=N'COLUMN',@level2name=N'ServiceCity_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ServiceTracking_T1', @level2type=N'COLUMN',@level2name=N'ServiceLine2_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ServiceTracking_T1', @level2type=N'COLUMN',@level2name=N'ServiceLine1_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ServiceTracking_T1', @level2type=N'COLUMN',@level2name=N'ServiceAttn_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ServiceTracking_T1', @level2type=N'COLUMN',@level2name=N'Service_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ServiceTracking_T1', @level2type=N'COLUMN',@level2name=N'ProcessServer_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ServiceTracking_T1', @level2type=N'COLUMN',@level2name=N'ServiceFailureReason_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ServiceTracking_T1', @level2type=N'COLUMN',@level2name=N'ServiceResult_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ServiceTracking_T1', @level2type=N'COLUMN',@level2name=N'ServiceMethod_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ServiceTracking_T1', @level2type=N'COLUMN',@level2name=N'Petition_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ServiceTracking_T1', @level2type=N'COLUMN',@level2name=N'MinorIntSeq_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ServiceTracking_T1', @level2type=N'COLUMN',@level2name=N'MajorIntSeq_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ServiceTracking_T1', @level2type=N'COLUMN',@level2name=N'File_ID'

GO
EXEC sys.sp_dropextendedproperty @name=N'1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ServiceTracking_T1', @level2type=N'COLUMN',@level2name=N'Case_IDNO'

GO
/****** Object:  Table [dbo].[ServiceTracking_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[ServiceTracking_T1]
GO
/****** Object:  Table [dbo].[ServiceTracking_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ServiceTracking_T1](
	[Case_IDNO] [numeric](6, 0) NOT NULL,
	[File_ID] [char](10) NOT NULL,
	[MajorIntSeq_NUMB] [numeric](5, 0) NOT NULL,
	[MinorIntSeq_NUMB] [numeric](5, 0) NOT NULL,
	[Petition_IDNO] [numeric](7, 0) NOT NULL,
	[ServiceMethod_CODE] [char](1) NOT NULL,
	[ServiceResult_CODE] [char](1) NOT NULL,
	[ServiceFailureReason_CODE] [char](1) NOT NULL,
	[ProcessServer_DATE] [date] NOT NULL,
	[Service_DATE] [date] NOT NULL,
	[ServiceAttn_ADDR] [char](40) NOT NULL,
	[ServiceLine1_ADDR] [varchar](50) NOT NULL,
	[ServiceLine2_ADDR] [varchar](50) NOT NULL,
	[ServiceCity_ADDR] [char](28) NOT NULL,
	[ServiceState_ADDR] [char](2) NOT NULL,
	[ServiceZip_ADDR] [char](15) NOT NULL,
	[ServiceNotes_TEXT] [varchar](1000) NOT NULL,
	[BeginValidity_DATE] [date] NOT NULL,
	[EndValidity_DATE] [date] NOT NULL,
	[WorkerUpdate_ID] [char](30) NOT NULL,
	[Update_DTTM] [datetime2](7) NOT NULL,
	[TransactionEventSeq_NUMB] [numeric](19, 0) NOT NULL,
	[ServiceCountry_ADDR] [char](2) NOT NULL,
 CONSTRAINT [FSRT_I1] PRIMARY KEY CLUSTERED 
(
	[Case_IDNO] ASC,
	[Petition_IDNO] ASC,
	[MajorIntSeq_NUMB] ASC,
	[MinorIntSeq_NUMB] ASC,
	[TransactionEventSeq_NUMB] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
EXEC sys.sp_addextendedproperty @name=N'1', @value=N'Unique ID generated for the DACSES Case.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ServiceTracking_T1', @level2type=N'COLUMN',@level2name=N'Case_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Unique ID generated by system for the File.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ServiceTracking_T1', @level2type=N'COLUMN',@level2name=N'File_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The system generated sequence number for the Remedy and Case / Order combination.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ServiceTracking_T1', @level2type=N'COLUMN',@level2name=N'MajorIntSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The system generated number for every new Minor Activity within the same Major Activity Sequence.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ServiceTracking_T1', @level2type=N'COLUMN',@level2name=N'MinorIntSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Unique petition number assigned by the family court' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ServiceTracking_T1', @level2type=N'COLUMN',@level2name=N'Petition_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the Family Court service method. Possible values are   ''A’ – Affidavit of Appearance,  ‘C’ – Certified Mail,  ‘H’ – Hand Delivered in Court,  ‘L’ – Sent Long Arm,  ‘N’ – In Local Newspaper,  ‘P’ – Personal Service,• ‘M’ – Regular Mail,   ‘R’ – Registered Mail, ‘S’ – Attorney PR FIL,    ‘B’ – Certified and Publications,    ‘V’ – Await Response on Verified Notice,  ‘X’ – Service not sent.     ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ServiceTracking_T1', @level2type=N'COLUMN',@level2name=N'ServiceMethod_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the Family Court services. Possible values are   ''P'' - positive , ''N'' - Negative.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ServiceTracking_T1', @level2type=N'COLUMN',@level2name=N'ServiceResult_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the Family Court service failure reason codes.  Possible values are ''N'' - NCP is evading, ''U'' - NCP is unknown at address, ''H'' - service address is unoccupied, ''M'' - NCP moved, No forwarding address  ''I'' - NCP in jail, ''D'' - NCP deceased.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ServiceTracking_T1', @level2type=N'COLUMN',@level2name=N'ServiceFailureReason_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'To store petition action filed date or worker can update the date for subsequent attempts on service' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ServiceTracking_T1', @level2type=N'COLUMN',@level2name=N'ProcessServer_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'To store the family court service date on the petition' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ServiceTracking_T1', @level2type=N'COLUMN',@level2name=N'Service_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the Name to whom the Letter is directed to.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ServiceTracking_T1', @level2type=N'COLUMN',@level2name=N'ServiceAttn_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the participants First Line of the Street Address.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ServiceTracking_T1', @level2type=N'COLUMN',@level2name=N'ServiceLine1_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the Participants Second Line of the Street Address.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ServiceTracking_T1', @level2type=N'COLUMN',@level2name=N'ServiceLine2_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the Participants Residing City.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ServiceTracking_T1', @level2type=N'COLUMN',@level2name=N'ServiceCity_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the Participants Residing State.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ServiceTracking_T1', @level2type=N'COLUMN',@level2name=N'ServiceState_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the Participants Residing Zip Code.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ServiceTracking_T1', @level2type=N'COLUMN',@level2name=N'ServiceZip_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates any other comments about the Address of the Member.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ServiceTracking_T1', @level2type=N'COLUMN',@level2name=N'ServiceNotes_TEXT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The information in any record is Valid only between the dates BeginValidity_DATE and EndValidity_DATE. When any information is changed, then a new record is inserted with changed   information and the BeginValidity_DATE is the date from when the change will be  effective. EndValidity_DATE of the old record should have the BeginValidity_DATE of the new record.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ServiceTracking_T1', @level2type=N'COLUMN',@level2name=N'BeginValidity_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The information in any record is Valid only between the dates BeginValidity_DATE and EndValidity_DATE. When any information is changed, then a new record is inserted with changed  information and the BeginValidity_DATE is the date from when the change will be  effective. BeginValidity_DATE of the old record should have the BeginValidity_DATE of the new record. EndValidity_DATE of the new record should have a high date (12/31/9999).              ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ServiceTracking_T1', @level2type=N'COLUMN',@level2name=N'EndValidity_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the worker ID who created/modified this record.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ServiceTracking_T1', @level2type=N'COLUMN',@level2name=N'WorkerUpdate_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the effective Date with Time at which this record was inserted / modified in this table.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ServiceTracking_T1', @level2type=N'COLUMN',@level2name=N'Update_DTTM'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Unique Sequence Number that will be  generated for any given transaction on the Table. This field is used for checking concurrency at the time of online transaction updates.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ServiceTracking_T1', @level2type=N'COLUMN',@level2name=N'TransactionEventSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Country code. Possible values are obtained from REFM (CTRY/CTRY)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ServiceTracking_T1', @level2type=N'COLUMN',@level2name=N'ServiceCountry_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'Stores petition service tracking information' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ServiceTracking_T1'
GO
