/****** Object:  Table [tblServesCategory]    Script Date: 5/28/2015 10:15:26 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [tblServesCategory](
	[Organization_ID] [varchar](8) NOT NULL,
	[Service_ID] [varchar](8) NOT NULL,
	[Serves_IDNO] [int] NOT NULL,
	[BeginValidity_DATE] [date] NOT NULL,
	[TransactionEventSeq_NUMB] [numeric](19, 0) NULL,
	[Update_DTTM] [datetime2](7) NULL,
	[WorkerUpdate_ID] [varchar](8) NULL,
 CONSTRAINT [PK_tblServesCategory] PRIMARY KEY CLUSTERED 
(
	[Organization_ID] ASC,
	[Service_ID] ASC,
	[Serves_IDNO] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [tblServesCategory]  WITH CHECK ADD  CONSTRAINT [FK_tblServesCategory_Organization_ID] FOREIGN KEY([Organization_ID])
REFERENCES [tblOrganization] ([Organization_ID])
GO
ALTER TABLE [tblServesCategory] CHECK CONSTRAINT [FK_tblServesCategory_Organization_ID]
GO
ALTER TABLE [tblServesCategory]  WITH CHECK ADD  CONSTRAINT [FK_tblServesCategory_Serves_IDNO] FOREIGN KEY([Serves_IDNO])
REFERENCES [tblServesMaster] ([Serves_IDNO])
GO
ALTER TABLE [tblServesCategory] CHECK CONSTRAINT [FK_tblServesCategory_Serves_IDNO]
GO
ALTER TABLE [tblServesCategory]  WITH CHECK ADD  CONSTRAINT [FK_tblServesCategory_Service_ID] FOREIGN KEY([Service_ID])
REFERENCES [tblServiceMaster] ([Service_ID])
GO
ALTER TABLE [tblServesCategory] CHECK CONSTRAINT [FK_tblServesCategory_Service_ID]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Unique id for the particular Organization, Organization Starts with "ORG", Example "ORG00001"' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblServesCategory', @level2type=N'COLUMN',@level2name=N'Organization_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Unique id for the corresponding services' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblServesCategory', @level2type=N'COLUMN',@level2name=N'Service_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'It contains the unique number for the Serves' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblServesCategory', @level2type=N'COLUMN',@level2name=N'Serves_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Begin date for the Record, The record is valid from the Date' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblServesCategory', @level2type=N'COLUMN',@level2name=N'BeginValidity_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Sequence number for the particular transaction' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblServesCategory', @level2type=N'COLUMN',@level2name=N'TransactionEventSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'date time on whic the Record is modified' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblServesCategory', @level2type=N'COLUMN',@level2name=N'Update_DTTM'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'worker id who is responsible for the Modification of the Record' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblServesCategory', @level2type=N'COLUMN',@level2name=N'WorkerUpdate_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'It contains the information for the Serves for the Service' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblServesCategory'
GO
