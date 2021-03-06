/****** Object:  Table [tblCategoryMaster]    Script Date: 5/28/2015 10:15:26 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [tblCategoryMaster](
	[Category_IDNO] [int] NOT NULL,
	[Descriptor_TEXT] [varchar](510) NOT NULL,
	[ParentCategory_IDNO] [int] NULL,
	[BeginValidity_DATE] [date] NOT NULL,
	[TransactionEventSeq_NUMBB] [numeric](19, 0) NULL,
	[Update_DTTMM] [datetime2](7) NULL,
	[WorkerUpdate_IDD] [varchar](8) NULL,
 CONSTRAINT [PK_tblCategoryMaster] PRIMARY KEY CLUSTERED 
(
	[Category_IDNO] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'It contains the unique number for the category' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblCategoryMaster', @level2type=N'COLUMN',@level2name=N'Category_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'It contains the description text for the service' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblCategoryMaster', @level2type=N'COLUMN',@level2name=N'Descriptor_TEXT'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'It contains the parent category for the service' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblCategoryMaster', @level2type=N'COLUMN',@level2name=N'ParentCategory_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Begin date for the Record, The record is valid from the Date' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblCategoryMaster', @level2type=N'COLUMN',@level2name=N'BeginValidity_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Sequence number for the particular transaction' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblCategoryMaster', @level2type=N'COLUMN',@level2name=N'TransactionEventSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'date time on whic the Record is modified' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblCategoryMaster', @level2type=N'COLUMN',@level2name=N'Update_DTTM'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'worker id who is responsible for the Modification of the Record' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblCategoryMaster', @level2type=N'COLUMN',@level2name=N'WorkerUpdate_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'It contains the information for the Serves, it is a Master Table for Category' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblCategoryMaster'
GO
