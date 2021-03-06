USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractFcNewServiceAddr_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractFcNewServiceAddr_T1', @level2type=N'COLUMN',@level2name=N'ServiceDocFile_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractFcNewServiceAddr_T1', @level2type=N'COLUMN',@level2name=N'DescriptionServiceDirection_TEXT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractFcNewServiceAddr_T1', @level2type=N'COLUMN',@level2name=N'Update_DTTM'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractFcNewServiceAddr_T1', @level2type=N'COLUMN',@level2name=N'Zip_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractFcNewServiceAddr_T1', @level2type=N'COLUMN',@level2name=N'State_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractFcNewServiceAddr_T1', @level2type=N'COLUMN',@level2name=N'City_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractFcNewServiceAddr_T1', @level2type=N'COLUMN',@level2name=N'Line2_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractFcNewServiceAddr_T1', @level2type=N'COLUMN',@level2name=N'Line1_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractFcNewServiceAddr_T1', @level2type=N'COLUMN',@level2name=N'DescriptionIdentifyingMarks_TEXT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractFcNewServiceAddr_T1', @level2type=N'COLUMN',@level2name=N'Birth_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractFcNewServiceAddr_T1', @level2type=N'COLUMN',@level2name=N'MemberSsn_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractFcNewServiceAddr_T1', @level2type=N'COLUMN',@level2name=N'MemberMci_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractFcNewServiceAddr_T1', @level2type=N'COLUMN',@level2name=N'Middle_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractFcNewServiceAddr_T1', @level2type=N'COLUMN',@level2name=N'First_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractFcNewServiceAddr_T1', @level2type=N'COLUMN',@level2name=N'Last_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractFcNewServiceAddr_T1', @level2type=N'COLUMN',@level2name=N'File_ID'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractFcNewServiceAddr_T1', @level2type=N'COLUMN',@level2name=N'Entered_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractFcNewServiceAddr_T1', @level2type=N'COLUMN',@level2name=N'DocReference_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractFcNewServiceAddr_T1', @level2type=N'COLUMN',@level2name=N'MajorIntSeq_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractFcNewServiceAddr_T1', @level2type=N'COLUMN',@level2name=N'Petition_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractFcNewServiceAddr_T1', @level2type=N'COLUMN',@level2name=N'Case_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractFcNewServiceAddr_T1', @level2type=N'COLUMN',@level2name=N'Rec_ID'

GO
/****** Object:  Table [dbo].[ExtractFcNewServiceAddr_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[ExtractFcNewServiceAddr_T1]
GO
/****** Object:  Table [dbo].[ExtractFcNewServiceAddr_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ExtractFcNewServiceAddr_T1](
	[Rec_ID] [char](4) NOT NULL,
	[Case_IDNO] [char](6) NOT NULL,
	[Petition_IDNO] [char](7) NOT NULL,
	[MajorIntSeq_NUMB] [char](2) NOT NULL,
	[DocReference_CODE] [char](4) NOT NULL,
	[Entered_DATE] [char](8) NOT NULL,
	[File_ID] [char](10) NOT NULL,
	[Last_NAME] [char](20) NOT NULL,
	[First_NAME] [char](15) NOT NULL,
	[Middle_NAME] [char](1) NOT NULL,
	[MemberMci_IDNO] [char](10) NOT NULL,
	[MemberSsn_NUMB] [char](9) NOT NULL,
	[Birth_DATE] [char](8) NOT NULL,
	[DescriptionIdentifyingMarks_TEXT] [char](40) NOT NULL,
	[Line1_ADDR] [varchar](50) NOT NULL,
	[Line2_ADDR] [varchar](50) NOT NULL,
	[City_ADDR] [char](28) NOT NULL,
	[State_ADDR] [char](2) NOT NULL,
	[Zip_ADDR] [char](9) NOT NULL,
	[Update_DTTM] [char](8) NOT NULL,
	[DescriptionServiceDirection_TEXT] [varchar](400) NOT NULL,
	[ServiceDocFile_NAME] [char](27) NOT NULL,
	[Create_DTTM] [char](14) NOT NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'NSA Detail record type. Possible value is ‘NSAR’.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractFcNewServiceAddr_T1', @level2type=N'COLUMN',@level2name=N'Rec_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies DECSS case number' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractFcNewServiceAddr_T1', @level2type=N'COLUMN',@level2name=N'Case_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies Family court petition number' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractFcNewServiceAddr_T1', @level2type=N'COLUMN',@level2name=N'Petition_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Family court related sequence number' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractFcNewServiceAddr_T1', @level2type=N'COLUMN',@level2name=N'MajorIntSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Family court petition type under ESTP Activity Chain. Possible values are Petition for Support & Medical - PETN,  Petition for Medical Only - PETN,   ,  Petition for Parentage Determination - PETP  ,  Long Arm Petition - PETL  ,  Voluntary Dismissal of Civil Petition - PETV' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractFcNewServiceAddr_T1', @level2type=N'COLUMN',@level2name=N'DocReference_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Petition action date. The date on which the petition was originally sent to Family Court.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractFcNewServiceAddr_T1', @level2type=N'COLUMN',@level2name=N'Entered_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Family court file number' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractFcNewServiceAddr_T1', @level2type=N'COLUMN',@level2name=N'File_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Member last name' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractFcNewServiceAddr_T1', @level2type=N'COLUMN',@level2name=N'Last_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Member first name' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractFcNewServiceAddr_T1', @level2type=N'COLUMN',@level2name=N'First_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Member middle initial' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractFcNewServiceAddr_T1', @level2type=N'COLUMN',@level2name=N'Middle_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies Member MCI number' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractFcNewServiceAddr_T1', @level2type=N'COLUMN',@level2name=N'MemberMci_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Member Social security number' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractFcNewServiceAddr_T1', @level2type=N'COLUMN',@level2name=N'MemberSsn_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Member date of birth' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractFcNewServiceAddr_T1', @level2type=N'COLUMN',@level2name=N'Birth_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Member marks/scars/tattoos' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractFcNewServiceAddr_T1', @level2type=N'COLUMN',@level2name=N'DescriptionIdentifyingMarks_TEXT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Member address line 1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractFcNewServiceAddr_T1', @level2type=N'COLUMN',@level2name=N'Line1_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Member address line 2' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractFcNewServiceAddr_T1', @level2type=N'COLUMN',@level2name=N'Line2_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Member city address' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractFcNewServiceAddr_T1', @level2type=N'COLUMN',@level2name=N'City_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Member state address' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractFcNewServiceAddr_T1', @level2type=N'COLUMN',@level2name=N'State_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Member zip address' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractFcNewServiceAddr_T1', @level2type=N'COLUMN',@level2name=N'Zip_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Member address update date' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractFcNewServiceAddr_T1', @level2type=N'COLUMN',@level2name=N'Update_DTTM'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Member directions to address' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractFcNewServiceAddr_T1', @level2type=N'COLUMN',@level2name=N'DescriptionServiceDirection_TEXT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Name of the petition document(s) being sent to the SFTP DTI server' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractFcNewServiceAddr_T1', @level2type=N'COLUMN',@level2name=N'ServiceDocFile_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'Table to provide Family Court with New Service Address' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractFcNewServiceAddr_T1'
GO
