USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefScreenFunctions_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefScreenFunctions_T1', @level2type=N'COLUMN',@level2name=N'DescriptionScreenFunction_TEXT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefScreenFunctions_T1', @level2type=N'COLUMN',@level2name=N'NoPosition_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefScreenFunctions_T1', @level2type=N'COLUMN',@level2name=N'WorkerUpdate_ID'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefScreenFunctions_T1', @level2type=N'COLUMN',@level2name=N'Update_DTTM'

GO
EXEC sys.sp_dropextendedproperty @name=N'3' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefScreenFunctions_T1', @level2type=N'COLUMN',@level2name=N'TransactionEventSeq_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefScreenFunctions_T1', @level2type=N'COLUMN',@level2name=N'EndValidity_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefScreenFunctions_T1', @level2type=N'COLUMN',@level2name=N'BeginValidity_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefScreenFunctions_T1', @level2type=N'COLUMN',@level2name=N'AccessModify_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefScreenFunctions_T1', @level2type=N'COLUMN',@level2name=N'AccessView_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefScreenFunctions_T1', @level2type=N'COLUMN',@level2name=N'AccessDelete_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefScreenFunctions_T1', @level2type=N'COLUMN',@level2name=N'AccessAdd_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefScreenFunctions_T1', @level2type=N'COLUMN',@level2name=N'ScreenFunction_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'2' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefScreenFunctions_T1', @level2type=N'COLUMN',@level2name=N'ScreenFunction_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefScreenFunctions_T1', @level2type=N'COLUMN',@level2name=N'Screen_ID'

GO
/****** Object:  Table [dbo].[RefScreenFunctions_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[RefScreenFunctions_T1]
GO
/****** Object:  Table [dbo].[RefScreenFunctions_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[RefScreenFunctions_T1](
	[Screen_ID] [char](4) NOT NULL,
	[ScreenFunction_CODE] [char](10) NOT NULL,
	[ScreenFunction_NAME] [varchar](100) NOT NULL,
	[AccessAdd_INDC] [char](1) NOT NULL,
	[AccessDelete_INDC] [char](1) NOT NULL,
	[AccessView_INDC] [char](1) NOT NULL,
	[AccessModify_INDC] [char](1) NOT NULL,
	[BeginValidity_DATE] [date] NOT NULL,
	[EndValidity_DATE] [date] NOT NULL,
	[TransactionEventSeq_NUMB] [numeric](19, 0) NOT NULL,
	[Update_DTTM] [datetime2](7) NOT NULL,
	[WorkerUpdate_ID] [char](30) NOT NULL,
	[NoPosition_IDNO] [numeric](3, 0) NOT NULL,
	[DescriptionScreenFunction_TEXT] [varchar](4000) NOT NULL,
 CONSTRAINT [SCFN_I1] PRIMARY KEY CLUSTERED 
(
	[Screen_ID] ASC,
	[ScreenFunction_CODE] ASC,
	[TransactionEventSeq_NUMB] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
EXEC sys.sp_addextendedproperty @name=N'1', @value=N'Unique Identification code of each screen.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefScreenFunctions_T1', @level2type=N'COLUMN',@level2name=N'Screen_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'2', @value=N'Holds data about the individual Functionality of the screen. This column defines the abbreviated code for the text provided in column ScreenFunction_NAME.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefScreenFunctions_T1', @level2type=N'COLUMN',@level2name=N'ScreenFunction_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The name of the screen function that will be  available for display in UI.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefScreenFunctions_T1', @level2type=N'COLUMN',@level2name=N'ScreenFunction_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicator field which says whether that particular role has the add privilege on the particular screen for the particular functionality. Values are obtained from REFM (YSNO/YSNO).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefScreenFunctions_T1', @level2type=N'COLUMN',@level2name=N'AccessAdd_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicator field which tells whether that particular role has the delete privilege on the particular screen for the particular functionality. Values are obtained from REFM (YSNO/YSNO).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefScreenFunctions_T1', @level2type=N'COLUMN',@level2name=N'AccessDelete_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicator field which tells whether that particular role has the view privilege on the particular screen for the particular functionality. Values are obtained from REFM (YSNO/YSNO).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefScreenFunctions_T1', @level2type=N'COLUMN',@level2name=N'AccessView_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicator field which tells whether that particular role has the update privilege on the particular screen for the particular functionality. Values are obtained from REFM (YSNO/YSNO).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefScreenFunctions_T1', @level2type=N'COLUMN',@level2name=N'AccessModify_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The Effective date from when the Changed Information is Valid.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefScreenFunctions_T1', @level2type=N'COLUMN',@level2name=N'BeginValidity_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The Effective date up to which the Changed Information will be  Valid.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefScreenFunctions_T1', @level2type=N'COLUMN',@level2name=N'EndValidity_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'3', @value=N'Unique Sequence Number that will be  generated for a given Transaction on the Table. This field is used for checking concurrency at the time of online transaction updates.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefScreenFunctions_T1', @level2type=N'COLUMN',@level2name=N'TransactionEventSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the effective Date with Time at which this record was inserted / modified in this table.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefScreenFunctions_T1', @level2type=N'COLUMN',@level2name=N'Update_DTTM'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the worker ID who created/modified this record.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefScreenFunctions_T1', @level2type=N'COLUMN',@level2name=N'WorkerUpdate_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the number position function that is displayed in UI.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefScreenFunctions_T1', @level2type=N'COLUMN',@level2name=N'NoPosition_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Description about the screen function.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefScreenFunctions_T1', @level2type=N'COLUMN',@level2name=N'DescriptionScreenFunction_TEXT'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'This is a reference table to store the screen function and its access information for each screen. This table stores valid records as well as history records which follows the temporal model structure' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefScreenFunctions_T1'
GO
