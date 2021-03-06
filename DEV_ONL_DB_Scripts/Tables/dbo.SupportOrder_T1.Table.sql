USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SupportOrder_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SupportOrder_T1', @level2type=N'COLUMN',@level2name=N'Commissioner_ID'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SupportOrder_T1', @level2type=N'COLUMN',@level2name=N'Judge_ID'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SupportOrder_T1', @level2type=N'COLUMN',@level2name=N'SourceOrdered_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SupportOrder_T1', @level2type=N'COLUMN',@level2name=N'DirectPay_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SupportOrder_T1', @level2type=N'COLUMN',@level2name=N'LastNoticeSent_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SupportOrder_T1', @level2type=N'COLUMN',@level2name=N'LastReview_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SupportOrder_T1', @level2type=N'COLUMN',@level2name=N'NextReview_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SupportOrder_T1', @level2type=N'COLUMN',@level2name=N'ReviewRequested_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SupportOrder_T1', @level2type=N'COLUMN',@level2name=N'TypeOrder_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SupportOrder_T1', @level2type=N'COLUMN',@level2name=N'RespondentAttorneyMailed_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SupportOrder_T1', @level2type=N'COLUMN',@level2name=N'PetitionerAttorneyMailed_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SupportOrder_T1', @level2type=N'COLUMN',@level2name=N'RespondentAttorneyMailed_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SupportOrder_T1', @level2type=N'COLUMN',@level2name=N'PetitionerAttorneyMailed_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SupportOrder_T1', @level2type=N'COLUMN',@level2name=N'RespondentAttorneyReceived_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SupportOrder_T1', @level2type=N'COLUMN',@level2name=N'PetitionerAttorneyReceived_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SupportOrder_T1', @level2type=N'COLUMN',@level2name=N'RespondentAttorneyAppeared_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SupportOrder_T1', @level2type=N'COLUMN',@level2name=N'PetitionerAttorneyAppeared_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SupportOrder_T1', @level2type=N'COLUMN',@level2name=N'OrderControl_ID'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SupportOrder_T1', @level2type=N'COLUMN',@level2name=N'StateControl_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SupportOrder_T1', @level2type=N'COLUMN',@level2name=N'StatusControl_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SupportOrder_T1', @level2type=N'COLUMN',@level2name=N'LastIrscReferred_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SupportOrder_T1', @level2type=N'COLUMN',@level2name=N'LastIrscUpdated_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SupportOrder_T1', @level2type=N'COLUMN',@level2name=N'LastIrscReferred_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SupportOrder_T1', @level2type=N'COLUMN',@level2name=N'DescriptionParentingNotes_TEXT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SupportOrder_T1', @level2type=N'COLUMN',@level2name=N'EventGlobalEndSeq_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'3' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SupportOrder_T1', @level2type=N'COLUMN',@level2name=N'EventGlobalBeginSeq_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SupportOrder_T1', @level2type=N'COLUMN',@level2name=N'EndValidity_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SupportOrder_T1', @level2type=N'COLUMN',@level2name=N'BeginValidity_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SupportOrder_T1', @level2type=N'COLUMN',@level2name=N'WorkerUpdate_ID'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SupportOrder_T1', @level2type=N'COLUMN',@level2name=N'DescriptionCoverageOthers_TEXT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SupportOrder_T1', @level2type=N'COLUMN',@level2name=N'CoverageOthers_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SupportOrder_T1', @level2type=N'COLUMN',@level2name=N'CoverageVision_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SupportOrder_T1', @level2type=N'COLUMN',@level2name=N'CoverageDental_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SupportOrder_T1', @level2type=N'COLUMN',@level2name=N'CoverageMental_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SupportOrder_T1', @level2type=N'COLUMN',@level2name=N'CoverageDrug_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SupportOrder_T1', @level2type=N'COLUMN',@level2name=N'CoverageMedical_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SupportOrder_T1', @level2type=N'COLUMN',@level2name=N'OthersMailed_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SupportOrder_T1', @level2type=N'COLUMN',@level2name=N'RespondentMailed_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SupportOrder_T1', @level2type=N'COLUMN',@level2name=N'PetitionerMailed_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SupportOrder_T1', @level2type=N'COLUMN',@level2name=N'OthersMailed_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SupportOrder_T1', @level2type=N'COLUMN',@level2name=N'RespondentMailed_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SupportOrder_T1', @level2type=N'COLUMN',@level2name=N'PetitionerMailed_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SupportOrder_T1', @level2type=N'COLUMN',@level2name=N'OthersReceived_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SupportOrder_T1', @level2type=N'COLUMN',@level2name=N'RespondentReceived_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SupportOrder_T1', @level2type=N'COLUMN',@level2name=N'PetitionerReceived_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SupportOrder_T1', @level2type=N'COLUMN',@level2name=N'OthersAppeared_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SupportOrder_T1', @level2type=N'COLUMN',@level2name=N'RespondentAppeared_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SupportOrder_T1', @level2type=N'COLUMN',@level2name=N'PetitionerAppeared_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SupportOrder_T1', @level2type=N'COLUMN',@level2name=N'NoParentingDays_QNTY'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SupportOrder_T1', @level2type=N'COLUMN',@level2name=N'ParentingTime_PCT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SupportOrder_T1', @level2type=N'COLUMN',@level2name=N'NcpMedical_PCT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SupportOrder_T1', @level2type=N'COLUMN',@level2name=N'CpMedical_PCT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SupportOrder_T1', @level2type=N'COLUMN',@level2name=N'UnreimMedical_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SupportOrder_T1', @level2type=N'COLUMN',@level2name=N'Qdro_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SupportOrder_T1', @level2type=N'COLUMN',@level2name=N'IssuingOrderFips_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SupportOrder_T1', @level2type=N'COLUMN',@level2name=N'CejFips_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SupportOrder_T1', @level2type=N'COLUMN',@level2name=N'CejStatus_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SupportOrder_T1', @level2type=N'COLUMN',@level2name=N'OrderOutOfState_ID'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SupportOrder_T1', @level2type=N'COLUMN',@level2name=N'DescriptionDeviationOthers_TEXT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SupportOrder_T1', @level2type=N'COLUMN',@level2name=N'DeviationReason_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SupportOrder_T1', @level2type=N'COLUMN',@level2name=N'GuidelinesFollowed_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SupportOrder_T1', @level2type=N'COLUMN',@level2name=N'IwoInitiatedBy_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SupportOrder_T1', @level2type=N'COLUMN',@level2name=N'NoIwReason_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SupportOrder_T1', @level2type=N'COLUMN',@level2name=N'Iiwo_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SupportOrder_T1', @level2type=N'COLUMN',@level2name=N'MedicalOnly_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SupportOrder_T1', @level2type=N'COLUMN',@level2name=N'InsOrdered_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SupportOrder_T1', @level2type=N'COLUMN',@level2name=N'StatusOrder_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SupportOrder_T1', @level2type=N'COLUMN',@level2name=N'StatusOrder_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SupportOrder_T1', @level2type=N'COLUMN',@level2name=N'ReasonStatus_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SupportOrder_T1', @level2type=N'COLUMN',@level2name=N'OrderEnd_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SupportOrder_T1', @level2type=N'COLUMN',@level2name=N'OrderEffective_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SupportOrder_T1', @level2type=N'COLUMN',@level2name=N'OrderIssued_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SupportOrder_T1', @level2type=N'COLUMN',@level2name=N'OrderEnt_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SupportOrder_T1', @level2type=N'COLUMN',@level2name=N'File_ID'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SupportOrder_T1', @level2type=N'COLUMN',@level2name=N'Order_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'2' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SupportOrder_T1', @level2type=N'COLUMN',@level2name=N'OrderSeq_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SupportOrder_T1', @level2type=N'COLUMN',@level2name=N'Case_IDNO'

GO
/****** Object:  Index [SORD_ORDER_I1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP INDEX [SORD_ORDER_I1] ON [dbo].[SupportOrder_T1]
GO
/****** Object:  Index [SORD_DCKT_I1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP INDEX [SORD_DCKT_I1] ON [dbo].[SupportOrder_T1]
GO
/****** Object:  Table [dbo].[SupportOrder_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[SupportOrder_T1]
GO
/****** Object:  Table [dbo].[SupportOrder_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[SupportOrder_T1](
	[Case_IDNO] [numeric](6, 0) NOT NULL,
	[OrderSeq_NUMB] [numeric](2, 0) NOT NULL,
	[Order_IDNO] [numeric](15, 0) NOT NULL,
	[File_ID] [char](10) NOT NULL,
	[OrderEnt_DATE] [date] NOT NULL,
	[OrderIssued_DATE] [date] NOT NULL,
	[OrderEffective_DATE] [date] NOT NULL,
	[OrderEnd_DATE] [date] NOT NULL,
	[ReasonStatus_CODE] [char](2) NOT NULL,
	[StatusOrder_CODE] [char](1) NOT NULL,
	[StatusOrder_DATE] [date] NOT NULL,
	[InsOrdered_CODE] [char](1) NOT NULL,
	[MedicalOnly_INDC] [char](1) NOT NULL,
	[Iiwo_CODE] [char](2) NOT NULL,
	[NoIwReason_CODE] [char](2) NOT NULL,
	[IwoInitiatedBy_CODE] [char](1) NOT NULL,
	[GuidelinesFollowed_INDC] [char](1) NOT NULL,
	[DeviationReason_CODE] [char](2) NOT NULL,
	[DescriptionDeviationOthers_TEXT] [char](30) NOT NULL,
	[OrderOutOfState_ID] [char](15) NOT NULL,
	[CejStatus_CODE] [char](1) NOT NULL,
	[CejFips_CODE] [char](7) NOT NULL,
	[IssuingOrderFips_CODE] [char](7) NOT NULL,
	[Qdro_INDC] [char](1) NOT NULL,
	[UnreimMedical_INDC] [char](1) NOT NULL,
	[CpMedical_PCT] [numeric](5, 2) NOT NULL,
	[NcpMedical_PCT] [numeric](5, 2) NOT NULL,
	[ParentingTime_PCT] [numeric](5, 2) NOT NULL,
	[NoParentingDays_QNTY] [numeric](3, 0) NOT NULL,
	[PetitionerAppeared_INDC] [char](1) NOT NULL,
	[RespondentAppeared_INDC] [char](1) NOT NULL,
	[OthersAppeared_INDC] [char](1) NOT NULL,
	[PetitionerReceived_INDC] [char](1) NOT NULL,
	[RespondentReceived_INDC] [char](1) NOT NULL,
	[OthersReceived_INDC] [char](1) NOT NULL,
	[PetitionerMailed_INDC] [char](1) NOT NULL,
	[RespondentMailed_INDC] [char](1) NOT NULL,
	[OthersMailed_INDC] [char](1) NOT NULL,
	[PetitionerMailed_DATE] [date] NOT NULL,
	[RespondentMailed_DATE] [date] NOT NULL,
	[OthersMailed_DATE] [date] NOT NULL,
	[CoverageMedical_CODE] [char](1) NOT NULL,
	[CoverageDrug_CODE] [char](1) NOT NULL,
	[CoverageMental_CODE] [char](1) NOT NULL,
	[CoverageDental_CODE] [char](1) NOT NULL,
	[CoverageVision_CODE] [char](1) NOT NULL,
	[CoverageOthers_CODE] [char](1) NOT NULL,
	[DescriptionCoverageOthers_TEXT] [char](30) NOT NULL,
	[WorkerUpdate_ID] [char](30) NOT NULL,
	[BeginValidity_DATE] [date] NOT NULL,
	[EndValidity_DATE] [date] NOT NULL,
	[EventGlobalBeginSeq_NUMB] [numeric](19, 0) NOT NULL,
	[EventGlobalEndSeq_NUMB] [numeric](19, 0) NOT NULL,
	[DescriptionParentingNotes_TEXT] [varchar](4000) NOT NULL,
	[LastIrscReferred_DATE] [date] NOT NULL,
	[LastIrscUpdated_DATE] [date] NOT NULL,
	[LastIrscReferred_AMNT] [numeric](11, 2) NOT NULL,
	[StatusControl_CODE] [char](1) NOT NULL,
	[StateControl_CODE] [char](2) NOT NULL,
	[OrderControl_ID] [char](15) NOT NULL,
	[PetitionerAttorneyAppeared_INDC] [char](1) NOT NULL,
	[RespondentAttorneyAppeared_INDC] [char](1) NOT NULL,
	[PetitionerAttorneyReceived_INDC] [char](1) NOT NULL,
	[RespondentAttorneyReceived_INDC] [char](1) NOT NULL,
	[PetitionerAttorneyMailed_INDC] [char](1) NOT NULL,
	[RespondentAttorneyMailed_INDC] [char](1) NOT NULL,
	[PetitionerAttorneyMailed_DATE] [date] NOT NULL,
	[RespondentAttorneyMailed_DATE] [date] NOT NULL,
	[TypeOrder_CODE] [char](1) NOT NULL,
	[ReviewRequested_DATE] [date] NOT NULL,
	[NextReview_DATE] [date] NOT NULL,
	[LastReview_DATE] [date] NOT NULL,
	[LastNoticeSent_DATE] [date] NOT NULL,
	[DirectPay_INDC] [char](1) NOT NULL,
	[SourceOrdered_CODE] [char](1) NOT NULL,
	[Judge_ID] [char](30) NOT NULL,
	[Commissioner_ID] [char](30) NOT NULL,
 CONSTRAINT [SORD_I1] PRIMARY KEY CLUSTERED 
(
	[Case_IDNO] ASC,
	[EventGlobalBeginSeq_NUMB] ASC,
	[OrderSeq_NUMB] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [SORD_DCKT_I1]    Script Date: 4/7/2015 12:53:07 PM ******/
CREATE NONCLUSTERED INDEX [SORD_DCKT_I1] ON [dbo].[SupportOrder_T1]
(
	[File_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [SORD_ORDER_I1]    Script Date: 4/7/2015 12:53:07 PM ******/
CREATE NONCLUSTERED INDEX [SORD_ORDER_I1] ON [dbo].[SupportOrder_T1]
(
	[Order_IDNO] ASC,
	[EndValidity_DATE] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
EXEC sys.sp_addextendedproperty @name=N'1', @value=N'Case ID of the CASE to which the Support Order is created.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SupportOrder_T1', @level2type=N'COLUMN',@level2name=N'Case_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'2', @value=N'This is a system generated internal order sequence number created for a support order for a given case.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SupportOrder_T1', @level2type=N'COLUMN',@level2name=N'OrderSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifier assigned to Support Order.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SupportOrder_T1', @level2type=N'COLUMN',@level2name=N'Order_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the File Number assigned for the Case.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SupportOrder_T1', @level2type=N'COLUMN',@level2name=N'File_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Date in which the order been entered.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SupportOrder_T1', @level2type=N'COLUMN',@level2name=N'OrderEnt_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the date in which the support order was issued.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SupportOrder_T1', @level2type=N'COLUMN',@level2name=N'OrderIssued_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Date from which the order in effective.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SupportOrder_T1', @level2type=N'COLUMN',@level2name=N'OrderEffective_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Date in which Support Order ends. Will Default to 12/31/2099.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SupportOrder_T1', @level2type=N'COLUMN',@level2name=N'OrderEnd_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The reason for the status of the order. Values to be determined in subsequent Technical Design.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SupportOrder_T1', @level2type=N'COLUMN',@level2name=N'ReasonStatus_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The current status of the order. Values are obtained from REFM (SORD/INSC)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SupportOrder_T1', @level2type=N'COLUMN',@level2name=N'StatusOrder_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the date when the order status was updated last.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SupportOrder_T1', @level2type=N'COLUMN',@level2name=N'StatusOrder_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates if insurance is ordered on this order. Values are obtained from REFM (SORD/INSO).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SupportOrder_T1', @level2type=N'COLUMN',@level2name=N'InsOrdered_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the order is only for medical support obligation. Values are obtained from REFM (YSNO/YSNO).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SupportOrder_T1', @level2type=N'COLUMN',@level2name=N'MedicalOnly_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Code indicating that an immediate income withholding is provided for in the support order. Values are obtained from REFM (SORD/IWOR).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SupportOrder_T1', @level2type=N'COLUMN',@level2name=N'Iiwo_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Specifies the reason for no income withholding on the order. Values to be determined in subsequent Technical Design.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SupportOrder_T1', @level2type=N'COLUMN',@level2name=N'NoIwReason_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates where the income withholding was initiated from. Values are obtained from REFM (SORD/IWOR)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SupportOrder_T1', @level2type=N'COLUMN',@level2name=N'IwoInitiatedBy_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This field indicates whether or not guidelines were used while calculating the support order. Y - Guidelines were used N - Guidelines were not used.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SupportOrder_T1', @level2type=N'COLUMN',@level2name=N'GuidelinesFollowed_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Interstate, Private Attorney. Values are obtained from REFM (DEVT/DEVT). Column may be dropped in the subsequent technical design after review.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SupportOrder_T1', @level2type=N'COLUMN',@level2name=N'DeviationReason_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the description for the deviation, if a reason code of others was selected. Column may be dropped in the subsequent technical design after review.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SupportOrder_T1', @level2type=N'COLUMN',@level2name=N'DescriptionDeviationOthers_TEXT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifier assigned to Out of State Support Order.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SupportOrder_T1', @level2type=N'COLUMN',@level2name=N'OrderOutOfState_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The status of the Control-Enforcement-Jurisdiction order. Values are obtained from REFM (SORD/CEJS).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SupportOrder_T1', @level2type=N'COLUMN',@level2name=N'CejStatus_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The control enforcement jurisdiction State FIPS of the case. Possible values are limited by values in FIPS table.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SupportOrder_T1', @level2type=N'COLUMN',@level2name=N'CejFips_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The FIPS code of the state where the order was issued. Values are obtained from REFM (STAT/STAT).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SupportOrder_T1', @level2type=N'COLUMN',@level2name=N'IssuingOrderFips_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates if QDRO (Qualified Domestic Relation Order) /EDRO (Eligible Domestic Relations Order) is Ordered.  Values are obtained from REFM (YSNO/YSNO).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SupportOrder_T1', @level2type=N'COLUMN',@level2name=N'Qdro_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates if the order includes Un-reimbursed medical. Values are obtained from REFM (YSNO/YSNO).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SupportOrder_T1', @level2type=N'COLUMN',@level2name=N'UnreimMedical_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The cost Percentage Medical test to be charged on CP.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SupportOrder_T1', @level2type=N'COLUMN',@level2name=N'CpMedical_PCT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The cost Percentage Medical test to be charged on NCP.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SupportOrder_T1', @level2type=N'COLUMN',@level2name=N'NcpMedical_PCT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the parenting-time as percentage specified in the judgment.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SupportOrder_T1', @level2type=N'COLUMN',@level2name=N'ParentingTime_PCT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the parenting-time as number of days specified in the judgment.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SupportOrder_T1', @level2type=N'COLUMN',@level2name=N'NoParentingDays_QNTY'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates if the plaintiff for this case/order appeared to the court or not. Values are obtained from REFM (YSNO/YSNO).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SupportOrder_T1', @level2type=N'COLUMN',@level2name=N'PetitionerAppeared_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates if the defendant for this case/order appeared to the court or not. Values are obtained from REFM (YSNO/YSNO).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SupportOrder_T1', @level2type=N'COLUMN',@level2name=N'RespondentAppeared_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates if others for this Case/order appeared to the court or not. Values are obtained from REFM (YSNO/YSNO).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SupportOrder_T1', @level2type=N'COLUMN',@level2name=N'OthersAppeared_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates if the Plaintiff for this Case/Order received the paper copy of the Order or not. Values are obtained from REFM (YSNO/YSNO).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SupportOrder_T1', @level2type=N'COLUMN',@level2name=N'PetitionerReceived_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates if the Defendant for this Case/Order received the paper copy of the Order or not. Values are obtained from REFM (YSNO/YSNO).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SupportOrder_T1', @level2type=N'COLUMN',@level2name=N'RespondentReceived_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates if others for this Case/Order received the paper copy of the Order or not. Values are obtained from REFM (YSNO/YSNO).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SupportOrder_T1', @level2type=N'COLUMN',@level2name=N'OthersReceived_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates if the Order was sent in mail to the Plaintiff for this case/order or not. Values are obtained from REFM (YSNO/YSNO).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SupportOrder_T1', @level2type=N'COLUMN',@level2name=N'PetitionerMailed_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates if the Order was sent in mail to the Defendant for this case/order or not. Values are obtained from REFM (YSNO/YSNO).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SupportOrder_T1', @level2type=N'COLUMN',@level2name=N'RespondentMailed_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates if the Order was sent in mail to others for this case/order or not. Values are obtained from REFM (YSNO/YSNO).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SupportOrder_T1', @level2type=N'COLUMN',@level2name=N'OthersMailed_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'If the court order was sent in mail, then capture the date sent for Plaintiff.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SupportOrder_T1', @level2type=N'COLUMN',@level2name=N'PetitionerMailed_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'If the court order was sent in mail, then capture the date sent for Defendant.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SupportOrder_T1', @level2type=N'COLUMN',@level2name=N'RespondentMailed_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'If the court order was sent in mail, then capture the date sent for others.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SupportOrder_T1', @level2type=N'COLUMN',@level2name=N'OthersMailed_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates if Medical coverage is provided to the dependants on this Order. Values are retrieved from REFM (SORD/INSC).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SupportOrder_T1', @level2type=N'COLUMN',@level2name=N'CoverageMedical_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates if Drug coverage is provided to the dependants on this Order. This will store as to who is providing the coverage, whether CP, NCP, Both or None. Possible values are C - CP, A - NCP, B - Both and N - None.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SupportOrder_T1', @level2type=N'COLUMN',@level2name=N'CoverageDrug_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates if Mental Health coverage is provided to the dependants on this Order. This will store as to who is providing the coverage, whether CP, NCP, Both or None. Possible values are C - CP, A - NCP, B - Both and N - None.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SupportOrder_T1', @level2type=N'COLUMN',@level2name=N'CoverageMental_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates if Dental coverage is provided to the dependants on this Order. Values are retrieved from REFM (SORD/INSC).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SupportOrder_T1', @level2type=N'COLUMN',@level2name=N'CoverageDental_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates if Vision coverage is provided to the dependants on this Order. This will store as to who is providing the coverage, whether CP, NCP, Both or None.  Possible values are C - CP, A - NCP, B - Both and N - None.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SupportOrder_T1', @level2type=N'COLUMN',@level2name=N'CoverageVision_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates if there is any other coverage that is provided to the dependants on this Order. This will store as to who is providing the coverage, whether CP, NCP, Both or None. Possible values are C - CP, A - NCP, B - Both and N - None.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SupportOrder_T1', @level2type=N'COLUMN',@level2name=N'CoverageOthers_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Provide a description of the coverage that is provided other than the above types.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SupportOrder_T1', @level2type=N'COLUMN',@level2name=N'DescriptionCoverageOthers_TEXT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the worker ID who created/modified this record.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SupportOrder_T1', @level2type=N'COLUMN',@level2name=N'WorkerUpdate_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The Effective date from when the Changed Information is Valid.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SupportOrder_T1', @level2type=N'COLUMN',@level2name=N'BeginValidity_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The Effective date up to which the Changed Information is Valid.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SupportOrder_T1', @level2type=N'COLUMN',@level2name=N'EndValidity_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'3', @value=N'The Global Event Sequence number for the corresponding BeginValidity_DATE.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SupportOrder_T1', @level2type=N'COLUMN',@level2name=N'EventGlobalBeginSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The Global Event Sequence number for the corresponding EndValidity_DATE. This should be zero when the corresponding EndValidity_DATE is a high date.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SupportOrder_T1', @level2type=N'COLUMN',@level2name=N'EventGlobalEndSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This column stores the current parenting notes for an order in the SORD_V1 table.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SupportOrder_T1', @level2type=N'COLUMN',@level2name=N'DescriptionParentingNotes_TEXT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Date, manually entered by the worker upon notification that the IRS has accepted the application for their collection services.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SupportOrder_T1', @level2type=N'COLUMN',@level2name=N'LastIrscReferred_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The system is required to send a Notice of Update to the ACF Regional Office on cases referred for IRS Full Collection services, at least once every six months. A Notice of Update is also sent when specific case conditions change.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SupportOrder_T1', @level2type=N'COLUMN',@level2name=N'LastIrscUpdated_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The total eligible arrears included in the Application for IRS Full Collection. The amount is updated in the Notice of Update, sent at least once every six months. The value of the Arrears Amount Last Referred field will change periodically.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SupportOrder_T1', @level2type=N'COLUMN',@level2name=N'LastIrscReferred_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Defines the Controlling Order Status. Values are retrieved from REFM (CTRL/STAT).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SupportOrder_T1', @level2type=N'COLUMN',@level2name=N'StatusControl_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Defines the State code for the Controlling Order. Values are retrieved from REFM (STAT/STAT).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SupportOrder_T1', @level2type=N'COLUMN',@level2name=N'StateControl_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Defines the Order ID for the Controlling Order.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SupportOrder_T1', @level2type=N'COLUMN',@level2name=N'OrderControl_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates if the Attorney of Plaintiff for this case/order appeared to the court or not. Values are obtained from REFM (YSNO/YSNO).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SupportOrder_T1', @level2type=N'COLUMN',@level2name=N'PetitionerAttorneyAppeared_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates if the Attorney of Defendant for this case/order appeared to the court or not. Values are obtained from REFM (YSNO/YSNO).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SupportOrder_T1', @level2type=N'COLUMN',@level2name=N'RespondentAttorneyAppeared_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates if the Attorney of Plaintiff for this Case/Order received the paper copy of the Order or not. Values are obtained from REFM (YSNO/YSNO).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SupportOrder_T1', @level2type=N'COLUMN',@level2name=N'PetitionerAttorneyReceived_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates if the Attorney of Defendant for this Case/Order received the paper copy of the Order or not. Values are obtained from REFM (YSNO/YSNO).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SupportOrder_T1', @level2type=N'COLUMN',@level2name=N'RespondentAttorneyReceived_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates if the Order was sent in mail to the Attorney of Plaintiff for this case/order or not. Values are obtained from REFM (YSNO/YSNO).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SupportOrder_T1', @level2type=N'COLUMN',@level2name=N'PetitionerAttorneyMailed_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates if the Order was sent in mail to the Attorney of Defendant for this case/order or not. Values are obtained from REFM (YSNO/YSNO).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SupportOrder_T1', @level2type=N'COLUMN',@level2name=N'RespondentAttorneyMailed_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'If the court order was sent in mail, then capture the date sent for Attorney of Plaintiff.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SupportOrder_T1', @level2type=N'COLUMN',@level2name=N'PetitionerAttorneyMailed_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'If the court order was sent in mail, then capture the date sent for Attorney of Defendant.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SupportOrder_T1', @level2type=N'COLUMN',@level2name=N'RespondentAttorneyMailed_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the order type code. Values are retrieved from REFM (SORD/ORDT).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SupportOrder_T1', @level2type=N'COLUMN',@level2name=N'TypeOrder_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the date when the review is requested.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SupportOrder_T1', @level2type=N'COLUMN',@level2name=N'ReviewRequested_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the date when the next review will be  done.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SupportOrder_T1', @level2type=N'COLUMN',@level2name=N'NextReview_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the date when the last review was done.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SupportOrder_T1', @level2type=N'COLUMN',@level2name=N'LastReview_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the date when the last notice was sent.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SupportOrder_T1', @level2type=N'COLUMN',@level2name=N'LastNoticeSent_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Can be paid directly, like NON-IVD. Exempt from Enforcement. Values are obtained from REFM (YSNO/YSNO).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SupportOrder_T1', @level2type=N'COLUMN',@level2name=N'DirectPay_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the type of order for the case. Values are retrieved from REFM (SORD/ORDB).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SupportOrder_T1', @level2type=N'COLUMN',@level2name=N'SourceOrdered_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the unique ID of Judge.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SupportOrder_T1', @level2type=N'COLUMN',@level2name=N'Judge_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the unique ID of the Hearing Officer' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SupportOrder_T1', @level2type=N'COLUMN',@level2name=N'Commissioner_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'This table stores the Support order details for a Case ID. It will have the Court order information for a NCP for the defendant.  This table stores valid records as well as history records which follows the temporal model structure.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SupportOrder_T1'
GO
