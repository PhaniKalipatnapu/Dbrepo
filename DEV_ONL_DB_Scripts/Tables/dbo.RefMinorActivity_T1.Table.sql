USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefMinorActivity_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefMinorActivity_T1', @level2type=N'COLUMN',@level2name=N'CaseJournal_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefMinorActivity_T1', @level2type=N'COLUMN',@level2name=N'BusinessDays_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefMinorActivity_T1', @level2type=N'COLUMN',@level2name=N'ScreenFunction_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'2' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefMinorActivity_T1', @level2type=N'COLUMN',@level2name=N'TransactionEventSeq_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefMinorActivity_T1', @level2type=N'COLUMN',@level2name=N'Update_DTTM'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefMinorActivity_T1', @level2type=N'COLUMN',@level2name=N'WorkerUpdate_ID'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefMinorActivity_T1', @level2type=N'COLUMN',@level2name=N'EndValidity_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefMinorActivity_T1', @level2type=N'COLUMN',@level2name=N'BeginValidity_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefMinorActivity_T1', @level2type=N'COLUMN',@level2name=N'TypeLocation2_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefMinorActivity_T1', @level2type=N'COLUMN',@level2name=N'TypeLocation1_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefMinorActivity_T1', @level2type=N'COLUMN',@level2name=N'MemberCombinations_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefMinorActivity_T1', @level2type=N'COLUMN',@level2name=N'DayAlertWarn_QNTY'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefMinorActivity_T1', @level2type=N'COLUMN',@level2name=N'Element_ID'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefMinorActivity_T1', @level2type=N'COLUMN',@level2name=N'ActionAlert_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefMinorActivity_T1', @level2type=N'COLUMN',@level2name=N'DayToComplete_QNTY'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefMinorActivity_T1', @level2type=N'COLUMN',@level2name=N'DescriptionActivity_TEXT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefMinorActivity_T1', @level2type=N'COLUMN',@level2name=N'TypeActivity_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefMinorActivity_T1', @level2type=N'COLUMN',@level2name=N'ActivityMinor_CODE'

GO
/****** Object:  Table [dbo].[RefMinorActivity_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[RefMinorActivity_T1]
GO
/****** Object:  Table [dbo].[RefMinorActivity_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[RefMinorActivity_T1](
	[ActivityMinor_CODE] [char](5) NOT NULL,
	[TypeActivity_CODE] [char](1) NOT NULL,
	[DescriptionActivity_TEXT] [varchar](75) NOT NULL,
	[DayToComplete_QNTY] [numeric](3, 0) NOT NULL,
	[ActionAlert_CODE] [char](1) NOT NULL,
	[Element_ID] [char](10) NOT NULL,
	[DayAlertWarn_QNTY] [numeric](3, 0) NOT NULL,
	[MemberCombinations_CODE] [char](1) NOT NULL,
	[TypeLocation1_CODE] [char](1) NOT NULL,
	[TypeLocation2_CODE] [char](1) NOT NULL,
	[BeginValidity_DATE] [date] NOT NULL,
	[EndValidity_DATE] [date] NOT NULL,
	[WorkerUpdate_ID] [char](30) NOT NULL,
	[Update_DTTM] [datetime2](7) NOT NULL,
	[TransactionEventSeq_NUMB] [numeric](19, 0) NOT NULL,
	[ScreenFunction_CODE] [char](10) NOT NULL,
	[BusinessDays_INDC] [char](1) NOT NULL,
	[CaseJournal_INDC] [char](1) NOT NULL,
 CONSTRAINT [AMNR_I1] PRIMARY KEY CLUSTERED 
(
	[ActivityMinor_CODE] ASC,
	[TransactionEventSeq_NUMB] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
EXEC sys.sp_addextendedproperty @name=N'1', @value=N'The Code within the system for the Minor Activity. Possible values are limited by values in AMNR table.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefMinorActivity_T1', @level2type=N'COLUMN',@level2name=N'ActivityMinor_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Code which represents the Type of Activity. Values are obtained from REFM (ACTP/ACTP)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefMinorActivity_T1', @level2type=N'COLUMN',@level2name=N'TypeActivity_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The description for the Minor Activity.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefMinorActivity_T1', @level2type=N'COLUMN',@level2name=N'DescriptionActivity_TEXT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The number which represents duration after which the Minor Activity has to be updated.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefMinorActivity_T1', @level2type=N'COLUMN',@level2name=N'DayToComplete_QNTY'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This indicates whether this activity is an action alert or not. If it is not an action alert, then it is informational. Values are obtained from REFM (ACTV/ATYP)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefMinorActivity_T1', @level2type=N'COLUMN',@level2name=N'ActionAlert_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The system given ID for the Minor Activity for use in Alert Management System.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefMinorActivity_T1', @level2type=N'COLUMN',@level2name=N'Element_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The number which represents the duration before which the Alert has to be shown for Minor Activity.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefMinorActivity_T1', @level2type=N'COLUMN',@level2name=N'DayAlertWarn_QNTY'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The code which represents the Case Members who are the participants of the Appointment. Values are obtained from REFM (SCMB/SCMB)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefMinorActivity_T1', @level2type=N'COLUMN',@level2name=N'MemberCombinations_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The Primary Location type where the Appointment has to be conducted. Values are obtained from REFM (SLTP/SLTP)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefMinorActivity_T1', @level2type=N'COLUMN',@level2name=N'TypeLocation1_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The secondary Location type where the Appointment has to be conducted. Values are obtained from REFM (SLTP/SLTP)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefMinorActivity_T1', @level2type=N'COLUMN',@level2name=N'TypeLocation2_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The Effective date from when the Changed Information is Valid.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefMinorActivity_T1', @level2type=N'COLUMN',@level2name=N'BeginValidity_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The Effective date up to which the Changed Information is Valid.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefMinorActivity_T1', @level2type=N'COLUMN',@level2name=N'EndValidity_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the worker ID who created/modified this record.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefMinorActivity_T1', @level2type=N'COLUMN',@level2name=N'WorkerUpdate_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the effective Date with Time at which this record was inserted / modified in this table.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefMinorActivity_T1', @level2type=N'COLUMN',@level2name=N'Update_DTTM'
GO
EXEC sys.sp_addextendedproperty @name=N'2', @value=N'Unique Sequence Number that will be generated for a Transaction on the Table. This field is used for checking concurrency at the time of online transaction updates.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefMinorActivity_T1', @level2type=N'COLUMN',@level2name=N'TransactionEventSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Holds data about the individual Functionality of the screen. Possible values are limited by values in SCFN.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefMinorActivity_T1', @level2type=N'COLUMN',@level2name=N'ScreenFunction_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This column is used to indicate whether the duration specified after which the Minor Activity has to be updated is business days or calendar days. Values are obtained from REFM (YSNO/YSNO)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefMinorActivity_T1', @level2type=N'COLUMN',@level2name=N'BusinessDays_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This column indicates whether the specified minor activity needs to be inserted into Case Journal or Minor Activity Diary. Values are obtained from REFM (YSNO/YSNO).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefMinorActivity_T1', @level2type=N'COLUMN',@level2name=N'CaseJournal_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'This table stores the attributes for all the minor activities from all the sub-systems. This table stores valid records as well as history records which follows the temporal model structure.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefMinorActivity_T1'
GO
