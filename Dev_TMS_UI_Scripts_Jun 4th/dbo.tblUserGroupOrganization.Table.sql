/****** Object:  Table [tblUserGroupOrganization]    Script Date: 5/28/2015 10:15:26 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [tblUserGroupOrganization](
	[User_ID] [varchar](8) NOT NULL,
	[Group_ID] [varchar](8) NOT NULL,
	[Organization_ID] [varchar](8) NOT NULL,
	[BeginValidity_DATE] [date] NULL,
	[TransactionEventSeq_NUMB] [numeric](19, 0) NULL,
	[Update_DTTM] [datetime2](7) NULL,
	[WorkerUpdate_ID] [varchar](8) NULL,
 CONSTRAINT [PK_tblUserGroupOrganization] PRIMARY KEY CLUSTERED 
(
	[User_ID] ASC,
	[Group_ID] ASC,
	[Organization_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [tblUserGroupOrganization]  WITH CHECK ADD  CONSTRAINT [FK_tblUserGroupOrganization_Group_ID] FOREIGN KEY([Group_ID])
REFERENCES [tblGroup] ([Group_ID])
GO
ALTER TABLE [tblUserGroupOrganization] CHECK CONSTRAINT [FK_tblUserGroupOrganization_Group_ID]
GO
ALTER TABLE [tblUserGroupOrganization]  WITH CHECK ADD  CONSTRAINT [FK_tblUserGroupOrganization_Organization_ID] FOREIGN KEY([Organization_ID])
REFERENCES [tblOrganization] ([Organization_ID])
GO
ALTER TABLE [tblUserGroupOrganization] CHECK CONSTRAINT [FK_tblUserGroupOrganization_Organization_ID]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Unique id for the user, User Id Starts with "U", Example "U0000001"' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblUserGroupOrganization', @level2type=N'COLUMN',@level2name=N'User_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'It contains the unique id for the group, Group ID will start wits "GRP" example "GRP00001"' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblUserGroupOrganization', @level2type=N'COLUMN',@level2name=N'Group_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Unique id for the particular Organization, Organization Starts with "ORG", Example "ORG00001"' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblUserGroupOrganization', @level2type=N'COLUMN',@level2name=N'Organization_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Begin date for the Record, The record is valid from the Date' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblUserGroupOrganization', @level2type=N'COLUMN',@level2name=N'BeginValidity_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Sequence number for the particular transaction' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblUserGroupOrganization', @level2type=N'COLUMN',@level2name=N'TransactionEventSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'date time on whic the Record is modified' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblUserGroupOrganization', @level2type=N'COLUMN',@level2name=N'Update_DTTM'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'worker id who is responsible for the Modification of the Record' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblUserGroupOrganization', @level2type=N'COLUMN',@level2name=N'WorkerUpdate_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'It contains the information about the user group for the corresponding organization' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblUserGroupOrganization'
GO
