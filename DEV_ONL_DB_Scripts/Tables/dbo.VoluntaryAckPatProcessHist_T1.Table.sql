USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'VoluntaryAckPatProcessHist_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'VoluntaryAckPatProcessHist_T1', @level2type=N'COLUMN',@level2name=N'MatchPoint_QNTY'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'VoluntaryAckPatProcessHist_T1', @level2type=N'COLUMN',@level2name=N'Update_DTTM'

GO
EXEC sys.sp_dropextendedproperty @name=N'3' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'VoluntaryAckPatProcessHist_T1', @level2type=N'COLUMN',@level2name=N'TransactionEventSeq_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'VoluntaryAckPatProcessHist_T1', @level2type=N'COLUMN',@level2name=N'WorkerUpdate_ID'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'VoluntaryAckPatProcessHist_T1', @level2type=N'COLUMN',@level2name=N'EndValidity_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'VoluntaryAckPatProcessHist_T1', @level2type=N'COLUMN',@level2name=N'BeginValidity_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'VoluntaryAckPatProcessHist_T1', @level2type=N'COLUMN',@level2name=N'Note_TEXT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'VoluntaryAckPatProcessHist_T1', @level2type=N'COLUMN',@level2name=N'MotherAddrExist_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'VoluntaryAckPatProcessHist_T1', @level2type=N'COLUMN',@level2name=N'MotherMemberSsn_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'VoluntaryAckPatProcessHist_T1', @level2type=N'COLUMN',@level2name=N'MotherBirth_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'VoluntaryAckPatProcessHist_T1', @level2type=N'COLUMN',@level2name=N'MotherFirst_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'VoluntaryAckPatProcessHist_T1', @level2type=N'COLUMN',@level2name=N'MotherLast_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'VoluntaryAckPatProcessHist_T1', @level2type=N'COLUMN',@level2name=N'MotherMemberMci_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'VoluntaryAckPatProcessHist_T1', @level2type=N'COLUMN',@level2name=N'FatherAddrExist_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'VoluntaryAckPatProcessHist_T1', @level2type=N'COLUMN',@level2name=N'FatherMemberSsn_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'VoluntaryAckPatProcessHist_T1', @level2type=N'COLUMN',@level2name=N'FatherBirth_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'VoluntaryAckPatProcessHist_T1', @level2type=N'COLUMN',@level2name=N'FatherFirst_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'VoluntaryAckPatProcessHist_T1', @level2type=N'COLUMN',@level2name=N'FatherLast_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'VoluntaryAckPatProcessHist_T1', @level2type=N'COLUMN',@level2name=N'FatherMemberMci_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'VoluntaryAckPatProcessHist_T1', @level2type=N'COLUMN',@level2name=N'ImageLink_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'VoluntaryAckPatProcessHist_T1', @level2type=N'COLUMN',@level2name=N'DataRecordStatus_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'VoluntaryAckPatProcessHist_T1', @level2type=N'COLUMN',@level2name=N'Match_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'VoluntaryAckPatProcessHist_T1', @level2type=N'COLUMN',@level2name=N'FatherSignature_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'VoluntaryAckPatProcessHist_T1', @level2type=N'COLUMN',@level2name=N'MotherSignature_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'VoluntaryAckPatProcessHist_T1', @level2type=N'COLUMN',@level2name=N'DopAttached_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'VoluntaryAckPatProcessHist_T1', @level2type=N'COLUMN',@level2name=N'VapAttached_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'VoluntaryAckPatProcessHist_T1', @level2type=N'COLUMN',@level2name=N'DopPresumedFather_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'VoluntaryAckPatProcessHist_T1', @level2type=N'COLUMN',@level2name=N'VapPresumedFather_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'VoluntaryAckPatProcessHist_T1', @level2type=N'COLUMN',@level2name=N'NoPresumedFather_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'VoluntaryAckPatProcessHist_T1', @level2type=N'COLUMN',@level2name=N'GeneticTest_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'VoluntaryAckPatProcessHist_T1', @level2type=N'COLUMN',@level2name=N'Declaration_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'VoluntaryAckPatProcessHist_T1', @level2type=N'COLUMN',@level2name=N'PlaceOfAck_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'VoluntaryAckPatProcessHist_T1', @level2type=N'COLUMN',@level2name=N'PlaceOfAck_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'VoluntaryAckPatProcessHist_T1', @level2type=N'COLUMN',@level2name=N'ChildBirthCounty_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'VoluntaryAckPatProcessHist_T1', @level2type=N'COLUMN',@level2name=N'ChildBirthCity_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'VoluntaryAckPatProcessHist_T1', @level2type=N'COLUMN',@level2name=N'ChildBirthState_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'VoluntaryAckPatProcessHist_T1', @level2type=N'COLUMN',@level2name=N'ChildMemberSsn_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'VoluntaryAckPatProcessHist_T1', @level2type=N'COLUMN',@level2name=N'ChildBirth_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'VoluntaryAckPatProcessHist_T1', @level2type=N'COLUMN',@level2name=N'ChildFirst_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'VoluntaryAckPatProcessHist_T1', @level2type=N'COLUMN',@level2name=N'ChildLast_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'VoluntaryAckPatProcessHist_T1', @level2type=N'COLUMN',@level2name=N'ChildMemberMci_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'2' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'VoluntaryAckPatProcessHist_T1', @level2type=N'COLUMN',@level2name=N'TypeDocument_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'VoluntaryAckPatProcessHist_T1', @level2type=N'COLUMN',@level2name=N'ChildBirthCertificate_ID'

GO
/****** Object:  Table [dbo].[VoluntaryAckPatProcessHist_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[VoluntaryAckPatProcessHist_T1]
GO
/****** Object:  Table [dbo].[VoluntaryAckPatProcessHist_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[VoluntaryAckPatProcessHist_T1](
	[ChildBirthCertificate_ID] [char](7) NOT NULL,
	[TypeDocument_CODE] [char](3) NOT NULL,
	[ChildMemberMci_IDNO] [numeric](10, 0) NOT NULL,
	[ChildLast_NAME] [char](20) NOT NULL,
	[ChildFirst_NAME] [char](16) NOT NULL,
	[ChildBirth_DATE] [date] NOT NULL,
	[ChildMemberSsn_NUMB] [numeric](9, 0) NOT NULL,
	[ChildBirthState_CODE] [char](2) NOT NULL,
	[ChildBirthCity_INDC] [char](1) NOT NULL,
	[ChildBirthCounty_INDC] [char](1) NOT NULL,
	[PlaceOfAck_CODE] [char](3) NOT NULL,
	[PlaceOfAck_NAME] [varchar](50) NOT NULL,
	[Declaration_INDC] [char](1) NOT NULL,
	[GeneticTest_INDC] [char](1) NOT NULL,
	[NoPresumedFather_CODE] [char](1) NOT NULL,
	[VapPresumedFather_CODE] [char](1) NOT NULL,
	[DopPresumedFather_CODE] [char](1) NOT NULL,
	[VapAttached_CODE] [char](1) NOT NULL,
	[DopAttached_CODE] [char](1) NOT NULL,
	[MotherSignature_DATE] [date] NOT NULL,
	[FatherSignature_DATE] [date] NOT NULL,
	[Match_DATE] [date] NOT NULL,
	[DataRecordStatus_CODE] [char](1) NOT NULL,
	[ImageLink_INDC] [char](1) NOT NULL,
	[FatherMemberMci_IDNO] [numeric](10, 0) NOT NULL,
	[FatherLast_NAME] [char](20) NOT NULL,
	[FatherFirst_NAME] [char](16) NOT NULL,
	[FatherBirth_DATE] [date] NOT NULL,
	[FatherMemberSsn_NUMB] [numeric](9, 0) NOT NULL,
	[FatherAddrExist_INDC] [char](1) NOT NULL,
	[MotherMemberMci_IDNO] [numeric](10, 0) NOT NULL,
	[MotherLast_NAME] [char](20) NOT NULL,
	[MotherFirst_NAME] [char](16) NOT NULL,
	[MotherBirth_DATE] [date] NOT NULL,
	[MotherMemberSsn_NUMB] [numeric](9, 0) NOT NULL,
	[MotherAddrExist_INDC] [char](1) NOT NULL,
	[Note_TEXT] [varchar](4000) NOT NULL,
	[BeginValidity_DATE] [date] NOT NULL,
	[EndValidity_DATE] [date] NOT NULL,
	[WorkerUpdate_ID] [char](30) NOT NULL,
	[TransactionEventSeq_NUMB] [numeric](19, 0) NOT NULL,
	[Update_DTTM] [datetime2](7) NOT NULL,
	[MatchPoint_QNTY] [numeric](2, 0) NOT NULL,
 CONSTRAINT [HVAPP_I1] PRIMARY KEY CLUSTERED 
(
	[ChildBirthCertificate_ID] ASC,
	[TypeDocument_CODE] ASC,
	[TransactionEventSeq_NUMB] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
EXEC sys.sp_addextendedproperty @name=N'1', @value=N'Birth Certificate number of the Child.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'VoluntaryAckPatProcessHist_T1', @level2type=N'COLUMN',@level2name=N'ChildBirthCertificate_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'2', @value=N'Document Type of the Voluntary Acknowledgment Process. Values are obtained from REFM (VAPP/DTYP)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'VoluntaryAckPatProcessHist_T1', @level2type=N'COLUMN',@level2name=N'TypeDocument_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the system assigned number to the Member.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'VoluntaryAckPatProcessHist_T1', @level2type=N'COLUMN',@level2name=N'ChildMemberMci_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Last Name of the Child.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'VoluntaryAckPatProcessHist_T1', @level2type=N'COLUMN',@level2name=N'ChildLast_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'First Name of the Child.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'VoluntaryAckPatProcessHist_T1', @level2type=N'COLUMN',@level2name=N'ChildFirst_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Date of Birth of the Child.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'VoluntaryAckPatProcessHist_T1', @level2type=N'COLUMN',@level2name=N'ChildBirth_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Member SSN of the Child.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'VoluntaryAckPatProcessHist_T1', @level2type=N'COLUMN',@level2name=N'ChildMemberSsn_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Birth State of the Child. Values are obtained from REFM (STAT/STAT)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'VoluntaryAckPatProcessHist_T1', @level2type=N'COLUMN',@level2name=N'ChildBirthState_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Birth City of the Child.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'VoluntaryAckPatProcessHist_T1', @level2type=N'COLUMN',@level2name=N'ChildBirthCity_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Birth County of the Child.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'VoluntaryAckPatProcessHist_T1', @level2type=N'COLUMN',@level2name=N'ChildBirthCounty_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Place of Acknowledgment of the child associated. Values are obtained from REFM (VAPP/PLOA)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'VoluntaryAckPatProcessHist_T1', @level2type=N'COLUMN',@level2name=N'PlaceOfAck_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Name of the place of acknowledgment.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'VoluntaryAckPatProcessHist_T1', @level2type=N'COLUMN',@level2name=N'PlaceOfAck_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Declaration under penalty of perjury to show the man is not the biological father of the child. Values are obtained from REFM (YSNO/YSNO)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'VoluntaryAckPatProcessHist_T1', @level2type=N'COLUMN',@level2name=N'Declaration_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates whether the man listed is the biological father of the child. Values are obtained from REFM (YSNO/YSNO)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'VoluntaryAckPatProcessHist_T1', @level2type=N'COLUMN',@level2name=N'GeneticTest_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'No Presumed Father of the child. Possible values are ‘M’ - Mother not married at the time of child birth, ‘N’ - Mother married to is not the father of the child or ‘L’ - No man continuously lived the child' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'VoluntaryAckPatProcessHist_T1', @level2type=N'COLUMN',@level2name=N'NoPresumedFather_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'VAP Presumed Father of the child. Possible values are ‘M’ - Mother was married or ‘N’ - Mother was not married' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'VoluntaryAckPatProcessHist_T1', @level2type=N'COLUMN',@level2name=N'VapPresumedFather_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'DOP Presumed Father of the child. Possible values are ‘M’ - Mother and Father married or ‘N’ - Mother and Father not married' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'VoluntaryAckPatProcessHist_T1', @level2type=N'COLUMN',@level2name=N'DopPresumedFather_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates if there has been a VAP attached in the DECSS Replacement System for a DOP record. Values are obtained from REFM (VAPP/VAPA)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'VoluntaryAckPatProcessHist_T1', @level2type=N'COLUMN',@level2name=N'VapAttached_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates if a DOP is needed for this VAP record. Values are obtained from REFM (VAPP/DOPA)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'VoluntaryAckPatProcessHist_T1', @level2type=N'COLUMN',@level2name=N'DopAttached_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Date when mother signed the VAP/DOP document.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'VoluntaryAckPatProcessHist_T1', @level2type=N'COLUMN',@level2name=N'MotherSignature_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Date when father signed the VAP/DOP document.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'VoluntaryAckPatProcessHist_T1', @level2type=N'COLUMN',@level2name=N'FatherSignature_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The date DACSES Replacement System found a match for the child VAP or DOP record with a DACSES Replacement System member' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'VoluntaryAckPatProcessHist_T1', @level2type=N'COLUMN',@level2name=N'Match_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates if the VAP/DOP data record has been completed or not i.e. whether all required data fields have been recorded. Values are obtained from REFM (VAPP/DSTA)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'VoluntaryAckPatProcessHist_T1', @level2type=N'COLUMN',@level2name=N'DataRecordStatus_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates if an image is associated to VAP/DOP data record. Values are obtained from REFM (YSNO/YSNO)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'VoluntaryAckPatProcessHist_T1', @level2type=N'COLUMN',@level2name=N'ImageLink_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the system assigned number to the Member.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'VoluntaryAckPatProcessHist_T1', @level2type=N'COLUMN',@level2name=N'FatherMemberMci_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Last Name of the Father.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'VoluntaryAckPatProcessHist_T1', @level2type=N'COLUMN',@level2name=N'FatherLast_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'First Name of the Father.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'VoluntaryAckPatProcessHist_T1', @level2type=N'COLUMN',@level2name=N'FatherFirst_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Date of Birth of the Father.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'VoluntaryAckPatProcessHist_T1', @level2type=N'COLUMN',@level2name=N'FatherBirth_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Member SSN of the Father.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'VoluntaryAckPatProcessHist_T1', @level2type=N'COLUMN',@level2name=N'FatherMemberSsn_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Address Line1 where Father lives.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'VoluntaryAckPatProcessHist_T1', @level2type=N'COLUMN',@level2name=N'FatherAddrExist_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the system assigned number to the Member.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'VoluntaryAckPatProcessHist_T1', @level2type=N'COLUMN',@level2name=N'MotherMemberMci_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Last Name of the Mother.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'VoluntaryAckPatProcessHist_T1', @level2type=N'COLUMN',@level2name=N'MotherLast_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'First Name of the Mother.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'VoluntaryAckPatProcessHist_T1', @level2type=N'COLUMN',@level2name=N'MotherFirst_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Date of Birth of the Mother.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'VoluntaryAckPatProcessHist_T1', @level2type=N'COLUMN',@level2name=N'MotherBirth_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Member SSN of the Mother.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'VoluntaryAckPatProcessHist_T1', @level2type=N'COLUMN',@level2name=N'MotherMemberSsn_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Address Line1 where Mother lives.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'VoluntaryAckPatProcessHist_T1', @level2type=N'COLUMN',@level2name=N'MotherAddrExist_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Free form text to enter the notes on the VAP/DOP.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'VoluntaryAckPatProcessHist_T1', @level2type=N'COLUMN',@level2name=N'Note_TEXT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The Effective date from when the Changed Information is valid.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'VoluntaryAckPatProcessHist_T1', @level2type=N'COLUMN',@level2name=N'BeginValidity_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The Effective date up to which the Changed Information is valid.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'VoluntaryAckPatProcessHist_T1', @level2type=N'COLUMN',@level2name=N'EndValidity_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Worker name that performed the last update.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'VoluntaryAckPatProcessHist_T1', @level2type=N'COLUMN',@level2name=N'WorkerUpdate_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'3', @value=N'Unique Sequence Number that will be generated for a Transaction on the Table. This field is used for checking concurrency at the time of online transaction updates.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'VoluntaryAckPatProcessHist_T1', @level2type=N'COLUMN',@level2name=N'TransactionEventSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the effective Date with Time at which this record was inserted / modified in this table.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'VoluntaryAckPatProcessHist_T1', @level2type=N'COLUMN',@level2name=N'Update_DTTM'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Its stores the number of matching criteria between VAPP and DEMO.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'VoluntaryAckPatProcessHist_T1', @level2type=N'COLUMN',@level2name=N'MatchPoint_QNTY'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'Maintain history information on Voluntary Acknowledgment of Paternity (VAP) and Denial of Paternity (DOP) documents' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'VoluntaryAckPatProcessHist_T1'
GO
