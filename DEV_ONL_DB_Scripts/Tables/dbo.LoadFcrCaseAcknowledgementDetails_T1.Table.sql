USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrCaseAcknowledgementDetails_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrCaseAcknowledgementDetails_T1', @level2type=N'COLUMN',@level2name=N'FileLoad_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrCaseAcknowledgementDetails_T1', @level2type=N'COLUMN',@level2name=N'Process_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrCaseAcknowledgementDetails_T1', @level2type=N'COLUMN',@level2name=N'Error5_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrCaseAcknowledgementDetails_T1', @level2type=N'COLUMN',@level2name=N'Error4_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrCaseAcknowledgementDetails_T1', @level2type=N'COLUMN',@level2name=N'Error3_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrCaseAcknowledgementDetails_T1', @level2type=N'COLUMN',@level2name=N'Error2_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrCaseAcknowledgementDetails_T1', @level2type=N'COLUMN',@level2name=N'Error1_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrCaseAcknowledgementDetails_T1', @level2type=N'COLUMN',@level2name=N'CaseAcknowledgement_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrCaseAcknowledgementDetails_T1', @level2type=N'COLUMN',@level2name=N'Batch_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrCaseAcknowledgementDetails_T1', @level2type=N'COLUMN',@level2name=N'CasePrev_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrCaseAcknowledgementDetails_T1', @level2type=N'COLUMN',@level2name=N'CaseUserField_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrCaseAcknowledgementDetails_T1', @level2type=N'COLUMN',@level2name=N'CountyFips_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrCaseAcknowledgementDetails_T1', @level2type=N'COLUMN',@level2name=N'Order_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrCaseAcknowledgementDetails_T1', @level2type=N'COLUMN',@level2name=N'TypeCase_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrCaseAcknowledgementDetails_T1', @level2type=N'COLUMN',@level2name=N'Case_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrCaseAcknowledgementDetails_T1', @level2type=N'COLUMN',@level2name=N'Action_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrCaseAcknowledgementDetails_T1', @level2type=N'COLUMN',@level2name=N'Rec_ID'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrCaseAcknowledgementDetails_T1', @level2type=N'COLUMN',@level2name=N'Seq_IDNO'

GO
/****** Object:  Table [dbo].[LoadFcrCaseAcknowledgementDetails_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[LoadFcrCaseAcknowledgementDetails_T1]
GO
/****** Object:  Table [dbo].[LoadFcrCaseAcknowledgementDetails_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[LoadFcrCaseAcknowledgementDetails_T1](
	[Seq_IDNO] [numeric](19, 0) IDENTITY(1,1) NOT NULL,
	[Rec_ID] [char](2) NOT NULL,
	[Action_CODE] [char](1) NOT NULL,
	[Case_IDNO] [char](15) NOT NULL,
	[TypeCase_CODE] [char](1) NOT NULL,
	[Order_INDC] [char](1) NOT NULL,
	[CountyFips_CODE] [char](3) NOT NULL,
	[CaseUserField_NUMB] [char](15) NOT NULL,
	[CasePrev_IDNO] [char](15) NOT NULL,
	[Batch_NUMB] [char](6) NOT NULL,
	[CaseAcknowledgement_CODE] [char](5) NOT NULL,
	[Error1_CODE] [char](5) NOT NULL,
	[Error2_CODE] [char](5) NOT NULL,
	[Error3_CODE] [char](5) NOT NULL,
	[Error4_CODE] [char](5) NOT NULL,
	[Error5_CODE] [char](5) NOT NULL,
	[Process_INDC] [char](1) NOT NULL,
	[FileLoad_DATE] [date] NOT NULL,
 CONSTRAINT [LFCAD_I1] PRIMARY KEY CLUSTERED 
(
	[Seq_IDNO] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Specifies the system generated sequence number to maintain uniqueness.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrCaseAcknowledgementDetails_T1', @level2type=N'COLUMN',@level2name=N'Seq_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies record (case) FD.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrCaseAcknowledgementDetails_T1', @level2type=N'COLUMN',@level2name=N'Rec_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'identifies action type code submitted.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrCaseAcknowledgementDetails_T1', @level2type=N'COLUMN',@level2name=N'Action_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'identifies id_case submitted.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrCaseAcknowledgementDetails_T1', @level2type=N'COLUMN',@level2name=N'Case_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'identifies type of code IV-D or NON IV-D.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrCaseAcknowledgementDetails_T1', @level2type=N'COLUMN',@level2name=N'TypeCase_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'identifies child support order existence for the case values (Y/N).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrCaseAcknowledgementDetails_T1', @level2type=N'COLUMN',@level2name=N'Order_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Specify the county office responsible for the case.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrCaseAcknowledgementDetails_T1', @level2type=N'COLUMN',@level2name=N'CountyFips_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'user field.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrCaseAcknowledgementDetails_T1', @level2type=N'COLUMN',@level2name=N'CaseUserField_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Used to change the Case ID for a case previously added to the FCR.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrCaseAcknowledgementDetails_T1', @level2type=N'COLUMN',@level2name=N'CasePrev_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This field will contain the sequential batch number sent by the transmitting state/territory.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrCaseAcknowledgementDetails_T1', @level2type=N'COLUMN',@level2name=N'Batch_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This field will contain a code to indicate if the record was accepted, rejected or is pending.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrCaseAcknowledgementDetails_T1', @level2type=N'COLUMN',@level2name=N'CaseAcknowledgement_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'identifies error code1.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrCaseAcknowledgementDetails_T1', @level2type=N'COLUMN',@level2name=N'Error1_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'identifies error code1.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrCaseAcknowledgementDetails_T1', @level2type=N'COLUMN',@level2name=N'Error2_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'identifies error code1.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrCaseAcknowledgementDetails_T1', @level2type=N'COLUMN',@level2name=N'Error3_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'identifies error code1.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrCaseAcknowledgementDetails_T1', @level2type=N'COLUMN',@level2name=N'Error4_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'identifies error code1.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrCaseAcknowledgementDetails_T1', @level2type=N'COLUMN',@level2name=N'Error5_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates Y if the record is processed otherwise N.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrCaseAcknowledgementDetails_T1', @level2type=N'COLUMN',@level2name=N'Process_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The date on which incoming file from Family court is loaded.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrCaseAcknowledgementDetails_T1', @level2type=N'COLUMN',@level2name=N'FileLoad_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'This table is used to store the Case acknowledgement details from FCR' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrCaseAcknowledgementDetails_T1'
GO
