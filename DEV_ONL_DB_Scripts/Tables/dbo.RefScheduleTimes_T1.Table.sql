USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefScheduleTimes_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefScheduleTimes_T1', @level2type=N'COLUMN',@level2name=N'SchdTime_DTTM'

GO
/****** Object:  Table [dbo].[RefScheduleTimes_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[RefScheduleTimes_T1]
GO
/****** Object:  Table [dbo].[RefScheduleTimes_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RefScheduleTimes_T1](
	[SchdTime_DTTM] [datetime2](7) NOT NULL,
 CONSTRAINT [STMS_I1] PRIMARY KEY CLUSTERED 
(
	[SchdTime_DTTM] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

GO
EXEC sys.sp_addextendedproperty @name=N'1', @value=N'The default slot timings which will be used in displaying Day view.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefScheduleTimes_T1', @level2type=N'COLUMN',@level2name=N'SchdTime_DTTM'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'This is a reference table that stores the time slots for a given business day, which is then used for scheduling appointments. This table stores valid records as well as history records which follows the temporal model structure.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefScheduleTimes_T1'
GO
