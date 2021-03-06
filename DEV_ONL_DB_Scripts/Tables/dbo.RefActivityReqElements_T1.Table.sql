USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefActivityReqElements_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefActivityReqElements_T1', @level2type=N'COLUMN',@level2name=N'WorkerUpdate_ID'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefActivityReqElements_T1', @level2type=N'COLUMN',@level2name=N'Update_DTTM'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefActivityReqElements_T1', @level2type=N'COLUMN',@level2name=N'Required_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefActivityReqElements_T1', @level2type=N'COLUMN',@level2name=N'Procedure_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'5' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefActivityReqElements_T1', @level2type=N'COLUMN',@level2name=N'Element_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefActivityReqElements_T1', @level2type=N'COLUMN',@level2name=N'ActivityMinorNext_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'4' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefActivityReqElements_T1', @level2type=N'COLUMN',@level2name=N'Reason_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'2' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefActivityReqElements_T1', @level2type=N'COLUMN',@level2name=N'ActivityMinor_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'3' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefActivityReqElements_T1', @level2type=N'COLUMN',@level2name=N'ActivityMajor_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefActivityReqElements_T1', @level2type=N'COLUMN',@level2name=N'Notice_ID'

GO
/****** Object:  Table [dbo].[RefActivityReqElements_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[RefActivityReqElements_T1]
GO
/****** Object:  Table [dbo].[RefActivityReqElements_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[RefActivityReqElements_T1](
	[Notice_ID] [char](8) NOT NULL,
	[ActivityMajor_CODE] [char](4) NOT NULL,
	[ActivityMinor_CODE] [char](5) NOT NULL,
	[Reason_CODE] [char](2) NOT NULL,
	[ActivityMinorNext_CODE] [char](5) NOT NULL,
	[Element_NAME] [varchar](100) NOT NULL,
	[Procedure_NAME] [varchar](100) NOT NULL,
	[Required_INDC] [char](1) NOT NULL,
	[Update_DTTM] [datetime2](7) NOT NULL,
	[WorkerUpdate_ID] [char](30) NOT NULL,
 CONSTRAINT [RARE_I1] PRIMARY KEY CLUSTERED 
(
	[Notice_ID] ASC,
	[ActivityMajor_CODE] ASC,
	[ActivityMinor_CODE] ASC,
	[Reason_CODE] ASC,
	[Element_NAME] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
EXEC sys.sp_addextendedproperty @name=N'1', @value=N' Notice ID' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefActivityReqElements_T1', @level2type=N'COLUMN',@level2name=N'Notice_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'3', @value=N'The Code within the system for the Major Activity. Possible values are limited by values in AMJR table.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefActivityReqElements_T1', @level2type=N'COLUMN',@level2name=N'ActivityMajor_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'2', @value=N'The Code within the system for the Minor Activity. Possible values are limited by values in AMNR table.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefActivityReqElements_T1', @level2type=N'COLUMN',@level2name=N'ActivityMinor_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'4', @value=N'Reason Code. Possible values are obtained from REFM (CPRO/REAS)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefActivityReqElements_T1', @level2type=N'COLUMN',@level2name=N'Reason_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The Code of the Next Minor Activity to follow. Possible values are limited by values in AMNR table.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefActivityReqElements_T1', @level2type=N'COLUMN',@level2name=N'ActivityMinorNext_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'5', @value=N'Name of the data elements related to the notices.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefActivityReqElements_T1', @level2type=N'COLUMN',@level2name=N'Element_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Procedure to be executed for the elements that needs value.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefActivityReqElements_T1', @level2type=N'COLUMN',@level2name=N'Procedure_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates whether to add particular element to notice or to delete in that particular step of activity chain. Possible values are obtained from REFM (YSNO/YSNO).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefActivityReqElements_T1', @level2type=N'COLUMN',@level2name=N'Required_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the effective Date with time at which this record was inserted / modified in this table.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefActivityReqElements_T1', @level2type=N'COLUMN',@level2name=N'Update_DTTM'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Worker ID of the worker who created/modified this record.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefActivityReqElements_T1', @level2type=N'COLUMN',@level2name=N'WorkerUpdate_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'This table is used to maintain Schedule notice elements to be added or removed in each step of activity chain.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefActivityReqElements_T1'
GO
