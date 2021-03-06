USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcOrderDetails_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'NULL' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcOrderDetails_T1', @level2type=N'COLUMN',@level2name=N'OrderStatus_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'NULL' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcOrderDetails_T1', @level2type=N'COLUMN',@level2name=N'Process_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'NULL' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcOrderDetails_T1', @level2type=N'COLUMN',@level2name=N'FileLoad_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'NULL' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcOrderDetails_T1', @level2type=N'COLUMN',@level2name=N'Detailed_TEXT'

GO
EXEC sys.sp_dropextendedproperty @name=N'NULL' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcOrderDetails_T1', @level2type=N'COLUMN',@level2name=N'OtherAmountPurpose_TEXT'

GO
EXEC sys.sp_dropextendedproperty @name=N'NULL' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcOrderDetails_T1', @level2type=N'COLUMN',@level2name=N'Other_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'NULL' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcOrderDetails_T1', @level2type=N'COLUMN',@level2name=N'RelatedPetition_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'NULL' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcOrderDetails_T1', @level2type=N'COLUMN',@level2name=N'SpousalBalance_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'NULL' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcOrderDetails_T1', @level2type=N'COLUMN',@level2name=N'MedicalBalance_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'NULL' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcOrderDetails_T1', @level2type=N'COLUMN',@level2name=N'GeneticTestBalance_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'NULL' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcOrderDetails_T1', @level2type=N'COLUMN',@level2name=N'Approved_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'NULL' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcOrderDetails_T1', @level2type=N'COLUMN',@level2name=N'ApprovedBy_ID'

GO
EXEC sys.sp_dropextendedproperty @name=N'NULL' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcOrderDetails_T1', @level2type=N'COLUMN',@level2name=N'OutOfStateAgency_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'NULL' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcOrderDetails_T1', @level2type=N'COLUMN',@level2name=N'CreditEffective_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'NULL' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcOrderDetails_T1', @level2type=N'COLUMN',@level2name=N'BalanceAsOf_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'NULL' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcOrderDetails_T1', @level2type=N'COLUMN',@level2name=N'ArrearsEffective_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'NULL' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcOrderDetails_T1', @level2type=N'COLUMN',@level2name=N'ObligationEffective_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'NULL' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcOrderDetails_T1', @level2type=N'COLUMN',@level2name=N'TotalCredit_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'NULL' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcOrderDetails_T1', @level2type=N'COLUMN',@level2name=N'ArrearsBalance_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'NULL' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcOrderDetails_T1', @level2type=N'COLUMN',@level2name=N'TotalObligation_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'NULL' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcOrderDetails_T1', @level2type=N'COLUMN',@level2name=N'GeneticTest_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'NULL' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcOrderDetails_T1', @level2type=N'COLUMN',@level2name=N'SpousalSupport_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'NULL' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcOrderDetails_T1', @level2type=N'COLUMN',@level2name=N'MedicalSupport_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'NULL' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcOrderDetails_T1', @level2type=N'COLUMN',@level2name=N'Arrears_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'NULL' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcOrderDetails_T1', @level2type=N'COLUMN',@level2name=N'CurrentSupport_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'NULL' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcOrderDetails_T1', @level2type=N'COLUMN',@level2name=N'CountyEmployerProgram_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'NULL' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcOrderDetails_T1', @level2type=N'COLUMN',@level2name=N'CalculationDeviation_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'NULL' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcOrderDetails_T1', @level2type=N'COLUMN',@level2name=N'HealthInsurance_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'NULL' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcOrderDetails_T1', @level2type=N'COLUMN',@level2name=N'DocCommit_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'NULL' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcOrderDetails_T1', @level2type=N'COLUMN',@level2name=N'Arrears_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'NULL' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcOrderDetails_T1', @level2type=N'COLUMN',@level2name=N'Credit_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'NULL' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcOrderDetails_T1', @level2type=N'COLUMN',@level2name=N'EmployerProgam_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'NULL' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcOrderDetails_T1', @level2type=N'COLUMN',@level2name=N'Contempt_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'NULL' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcOrderDetails_T1', @level2type=N'COLUMN',@level2name=N'Payment_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'NULL' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcOrderDetails_T1', @level2type=N'COLUMN',@level2name=N'WageAttachment_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'NULL' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcOrderDetails_T1', @level2type=N'COLUMN',@level2name=N'IvdCase_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'NULL' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcOrderDetails_T1', @level2type=N'COLUMN',@level2name=N'DefaultOrder_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'NULL' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcOrderDetails_T1', @level2type=N'COLUMN',@level2name=N'PermanentOrder_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'NULL' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcOrderDetails_T1', @level2type=N'COLUMN',@level2name=N'Form_ID'

GO
EXEC sys.sp_dropextendedproperty @name=N'NULL' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcOrderDetails_T1', @level2type=N'COLUMN',@level2name=N'ObligorMci_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'NULL' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcOrderDetails_T1', @level2type=N'COLUMN',@level2name=N'ObligeeMCI_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'NULL' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcOrderDetails_T1', @level2type=N'COLUMN',@level2name=N'Hearing_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'NULL' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcOrderDetails_T1', @level2type=N'COLUMN',@level2name=N'HearingOfficer_ID'

GO
EXEC sys.sp_dropextendedproperty @name=N'NULL' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcOrderDetails_T1', @level2type=N'COLUMN',@level2name=N'SupportOrder_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'NULL' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcOrderDetails_T1', @level2type=N'COLUMN',@level2name=N'FamilyCourtFile_ID'

GO
EXEC sys.sp_dropextendedproperty @name=N'NULL' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcOrderDetails_T1', @level2type=N'COLUMN',@level2name=N'PetitionAction_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'NULL' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcOrderDetails_T1', @level2type=N'COLUMN',@level2name=N'PetitionType_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'NULL' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcOrderDetails_T1', @level2type=N'COLUMN',@level2name=N'Case_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'NULL' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcOrderDetails_T1', @level2type=N'COLUMN',@level2name=N'PetitionSequence_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'NULL' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcOrderDetails_T1', @level2type=N'COLUMN',@level2name=N'Petition_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'NULL' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcOrderDetails_T1', @level2type=N'COLUMN',@level2name=N'Rec_ID'

GO
EXEC sys.sp_dropextendedproperty @name=N'1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcOrderDetails_T1', @level2type=N'COLUMN',@level2name=N'Seq_IDNO'

GO
/****** Object:  Table [dbo].[LoadFcOrderDetails_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[LoadFcOrderDetails_T1]
GO
/****** Object:  Table [dbo].[LoadFcOrderDetails_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[LoadFcOrderDetails_T1](
	[Seq_IDNO] [numeric](19, 0) IDENTITY(1,1) NOT NULL,
	[Rec_ID] [char](4) NOT NULL,
	[Petition_IDNO] [char](7) NOT NULL,
	[PetitionSequence_IDNO] [char](2) NOT NULL,
	[Case_IDNO] [char](6) NOT NULL,
	[PetitionType_CODE] [char](4) NOT NULL,
	[PetitionAction_DATE] [char](8) NOT NULL,
	[FamilyCourtFile_ID] [char](10) NOT NULL,
	[SupportOrder_IDNO] [char](7) NOT NULL,
	[HearingOfficer_ID] [char](8) NOT NULL,
	[Hearing_DATE] [char](8) NOT NULL,
	[ObligeeMCI_IDNO] [char](10) NOT NULL,
	[ObligorMci_IDNO] [char](10) NOT NULL,
	[Form_ID] [char](3) NOT NULL,
	[PermanentOrder_INDC] [char](1) NOT NULL,
	[DefaultOrder_INDC] [char](1) NOT NULL,
	[IvdCase_INDC] [char](1) NOT NULL,
	[WageAttachment_INDC] [char](1) NOT NULL,
	[Payment_INDC] [char](1) NOT NULL,
	[Contempt_INDC] [char](1) NOT NULL,
	[EmployerProgam_INDC] [char](1) NOT NULL,
	[Credit_CODE] [char](1) NOT NULL,
	[Arrears_CODE] [char](1) NOT NULL,
	[DocCommit_CODE] [char](1) NOT NULL,
	[HealthInsurance_CODE] [char](1) NOT NULL,
	[CalculationDeviation_CODE] [char](2) NOT NULL,
	[CountyEmployerProgram_IDNO] [char](3) NOT NULL,
	[CurrentSupport_AMNT] [char](9) NOT NULL,
	[Arrears_AMNT] [char](9) NOT NULL,
	[MedicalSupport_AMNT] [char](9) NOT NULL,
	[SpousalSupport_AMNT] [char](9) NOT NULL,
	[GeneticTest_AMNT] [char](9) NOT NULL,
	[TotalObligation_AMNT] [char](10) NOT NULL,
	[ArrearsBalance_AMNT] [char](9) NOT NULL,
	[TotalCredit_AMNT] [char](9) NOT NULL,
	[ObligationEffective_DATE] [char](8) NOT NULL,
	[ArrearsEffective_DATE] [char](8) NOT NULL,
	[BalanceAsOf_DATE] [char](8) NOT NULL,
	[CreditEffective_DATE] [char](8) NOT NULL,
	[OutOfStateAgency_IDNO] [char](12) NOT NULL,
	[ApprovedBy_ID] [char](7) NOT NULL,
	[Approved_DATE] [char](8) NOT NULL,
	[GeneticTestBalance_AMNT] [char](9) NOT NULL,
	[MedicalBalance_AMNT] [char](9) NOT NULL,
	[SpousalBalance_AMNT] [char](9) NOT NULL,
	[RelatedPetition_IDNO] [char](7) NOT NULL,
	[Other_AMNT] [char](9) NOT NULL,
	[OtherAmountPurpose_TEXT] [char](40) NOT NULL,
	[Detailed_TEXT] [varchar](4000) NOT NULL,
	[FileLoad_DATE] [date] NOT NULL,
	[Process_INDC] [char](1) NOT NULL,
	[OrderStatus_CODE] [char](1) NOT NULL,
 CONSTRAINT [LFORD_I1] PRIMARY KEY CLUSTERED 
(
	[Seq_IDNO] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
EXEC sys.sp_addextendedproperty @name=N'1', @value=N'This is a unique number to uniquely identify a record.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcOrderDetails_T1', @level2type=N'COLUMN',@level2name=N'Seq_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'NULL', @value=N'Petition disposition type.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcOrderDetails_T1', @level2type=N'COLUMN',@level2name=N'Rec_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'NULL', @value=N'Identifies unique petition number assigned by the family court' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcOrderDetails_T1', @level2type=N'COLUMN',@level2name=N'Petition_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'NULL', @value=N'Identifies Family Court related sequence number' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcOrderDetails_T1', @level2type=N'COLUMN',@level2name=N'PetitionSequence_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'NULL', @value=N'Identifies unique ID generated for the DECSS Case.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcOrderDetails_T1', @level2type=N'COLUMN',@level2name=N'Case_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'NULL', @value=N'Petition type request filed on the family court.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcOrderDetails_T1', @level2type=N'COLUMN',@level2name=N'PetitionType_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'NULL', @value=N'Petition action date' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcOrderDetails_T1', @level2type=N'COLUMN',@level2name=N'PetitionAction_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'NULL', @value=N'Family court file identification' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcOrderDetails_T1', @level2type=N'COLUMN',@level2name=N'FamilyCourtFile_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'NULL', @value=N'Identifies Support order number generated by family court' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcOrderDetails_T1', @level2type=N'COLUMN',@level2name=N'SupportOrder_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'NULL', @value=N'Hearing officer ID' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcOrderDetails_T1', @level2type=N'COLUMN',@level2name=N'HearingOfficer_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'NULL', @value=N'Hearing date' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcOrderDetails_T1', @level2type=N'COLUMN',@level2name=N'Hearing_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'NULL', @value=N'Identifies MCI number of CP' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcOrderDetails_T1', @level2type=N'COLUMN',@level2name=N'ObligeeMCI_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'NULL', @value=N'Identifies MCI number of NCP' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcOrderDetails_T1', @level2type=N'COLUMN',@level2name=N'ObligorMci_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'NULL', @value=N'Type of order form used' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcOrderDetails_T1', @level2type=N'COLUMN',@level2name=N'Form_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'NULL', @value=N'Indicates Permanent order.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcOrderDetails_T1', @level2type=N'COLUMN',@level2name=N'PermanentOrder_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'NULL', @value=N'Indicates default order.  ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcOrderDetails_T1', @level2type=N'COLUMN',@level2name=N'DefaultOrder_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'NULL', @value=N'Indicates IV-D case or not.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcOrderDetails_T1', @level2type=N'COLUMN',@level2name=N'IvdCase_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'NULL', @value=N'Indicates wage attachment included in the order or not.  ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcOrderDetails_T1', @level2type=N'COLUMN',@level2name=N'WageAttachment_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'NULL', @value=N'Indicates Pay to DCSE or CP.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcOrderDetails_T1', @level2type=N'COLUMN',@level2name=N'Payment_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'NULL', @value=N'Indicates Contempt or not contempt.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcOrderDetails_T1', @level2type=N'COLUMN',@level2name=N'Contempt_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'NULL', @value=N'Indicates Employer 90 day Program has been ordered or not.  ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcOrderDetails_T1', @level2type=N'COLUMN',@level2name=N'EmployerProgam_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'NULL', @value=N'Applies to total credit amount.  ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcOrderDetails_T1', @level2type=N'COLUMN',@level2name=N'Credit_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'NULL', @value=N'Applies to Total Arrears Amount.  ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcOrderDetails_T1', @level2type=N'COLUMN',@level2name=N'Arrears_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'NULL', @value=N'Indicates whether the NCP is committed to the Department of Corrections.  ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcOrderDetails_T1', @level2type=N'COLUMN',@level2name=N'DocCommit_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'NULL', @value=N'Medical Ordered indicator.  ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcOrderDetails_T1', @level2type=N'COLUMN',@level2name=N'HealthInsurance_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'NULL', @value=N'Guidelines deviated indicator.  ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcOrderDetails_T1', @level2type=N'COLUMN',@level2name=N'CalculationDeviation_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'NULL', @value=N'County of the Employer Program.  ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcOrderDetails_T1', @level2type=N'COLUMN',@level2name=N'CountyEmployerProgram_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'NULL', @value=N'Current monthly support that was ordered' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcOrderDetails_T1', @level2type=N'COLUMN',@level2name=N'CurrentSupport_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'NULL', @value=N'Current monthly arrears payment amount that was ordered' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcOrderDetails_T1', @level2type=N'COLUMN',@level2name=N'Arrears_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'NULL', @value=N'Current monthly medical support payment amount that was ordered' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcOrderDetails_T1', @level2type=N'COLUMN',@level2name=N'MedicalSupport_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'NULL', @value=N'Current monthly spousal support amount that was ordered' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcOrderDetails_T1', @level2type=N'COLUMN',@level2name=N'SpousalSupport_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'NULL', @value=N'Current monthly genetic test amount that was ordered to be applied to the cost of the genetic test amount' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcOrderDetails_T1', @level2type=N'COLUMN',@level2name=N'GeneticTest_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'NULL', @value=N'Total monthly support obligation amount (the sum of the current, arrears, medical, spousal, genetic test, and other amounts ordered)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcOrderDetails_T1', @level2type=N'COLUMN',@level2name=N'TotalObligation_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'NULL', @value=N'Arrears balance as of the balance-as-of-date' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcOrderDetails_T1', @level2type=N'COLUMN',@level2name=N'ArrearsBalance_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'NULL', @value=N'Total Credited amount for the NCP' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcOrderDetails_T1', @level2type=N'COLUMN',@level2name=N'TotalCredit_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'NULL', @value=N'Obligation effective date' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcOrderDetails_T1', @level2type=N'COLUMN',@level2name=N'ObligationEffective_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'NULL', @value=N'Arrears payback effective date' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcOrderDetails_T1', @level2type=N'COLUMN',@level2name=N'ArrearsEffective_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'NULL', @value=N'Date on which the balance amounts were calculated' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcOrderDetails_T1', @level2type=N'COLUMN',@level2name=N'BalanceAsOf_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'NULL', @value=N'Date on which the total credit amount was calculated and became effective' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcOrderDetails_T1', @level2type=N'COLUMN',@level2name=N'CreditEffective_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'NULL', @value=N'Out of state agency number' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcOrderDetails_T1', @level2type=N'COLUMN',@level2name=N'OutOfStateAgency_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'NULL', @value=N'User ID of the Judge, Master, or Commissioner that approved the Support Order' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcOrderDetails_T1', @level2type=N'COLUMN',@level2name=N'ApprovedBy_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'NULL', @value=N'Date the Judge, Master, Commissioner approved the order' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcOrderDetails_T1', @level2type=N'COLUMN',@level2name=N'Approved_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'NULL', @value=N'Balance owed against the cost of genetic testing' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcOrderDetails_T1', @level2type=N'COLUMN',@level2name=N'GeneticTestBalance_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'NULL', @value=N'Balance owed against the cost of the child’s Medical expenses' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcOrderDetails_T1', @level2type=N'COLUMN',@level2name=N'MedicalBalance_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'NULL', @value=N'Balance owed for Spousal expenses' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcOrderDetails_T1', @level2type=N'COLUMN',@level2name=N'SpousalBalance_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'NULL', @value=N'Petition related to the petition that underlies the support order' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcOrderDetails_T1', @level2type=N'COLUMN',@level2name=N'RelatedPetition_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'NULL', @value=N'Monthly amount ordered to be paid for the purpose stated on the other-amount-for field' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcOrderDetails_T1', @level2type=N'COLUMN',@level2name=N'Other_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'NULL', @value=N'Purpose for which the other amount was ordered. Text field relates to corresponding other-amt1 field' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcOrderDetails_T1', @level2type=N'COLUMN',@level2name=N'OtherAmountPurpose_TEXT'
GO
EXEC sys.sp_addextendedproperty @name=N'NULL', @value=N'Free form notes description added to the court order' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcOrderDetails_T1', @level2type=N'COLUMN',@level2name=N'Detailed_TEXT'
GO
EXEC sys.sp_addextendedproperty @name=N'NULL', @value=N'Date file was loaded into the table' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcOrderDetails_T1', @level2type=N'COLUMN',@level2name=N'FileLoad_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'NULL', @value=N'Indicates the record was processed or not.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcOrderDetails_T1', @level2type=N'COLUMN',@level2name=N'Process_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'NULL', @value=N'The status of the order.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcOrderDetails_T1', @level2type=N'COLUMN',@level2name=N'OrderStatus_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'This table is used to load the order information received from the family court order batch' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcOrderDetails_T1'
GO
