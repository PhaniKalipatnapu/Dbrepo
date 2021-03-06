USE [DEV_ONL_DB]
GO
/****** Object:  Table [dbo].[ObleLSUP13156DetailReport_P1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[ObleLSUP13156DetailReport_P1]
GO
/****** Object:  Table [dbo].[ObleLSUP13156DetailReport_P1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ObleLSUP13156DetailReport_P1](
	[Case_IDNO] [numeric](6, 0) NOT NULL,
	[OrderSeq_NUMB] [numeric](2, 0) NOT NULL,
	[ObligationSeq_NUMB] [numeric](2, 0) NOT NULL,
	[MemberMci_IDNO] [numeric](10, 0) NOT NULL,
	[Periodic_AMNT] [numeric](11, 2) NOT NULL,
	[Daily_Prorated_Amount] [numeric](18, 6) NULL,
	[BeginObligation_DATE] [date] NOT NULL,
	[Prorated_Amnt_InsertByDefect12879Script_INDC] [varchar](1) NOT NULL,
	[Defect12879_NoOfDaysToProrate] [numeric](10, 0) NOT NULL,
	[Defect1287_AdjustedProratedOwedAmount] [numeric](11, 2) NOT NULL,
	[December_201312_CS_Balance_AMNT_Before_CR346_Defect13156Script_Update] [numeric](12, 2) NOT NULL,
	[December_201312_CS_Balance_AMNT_After_CR346_Defect13156Script_Update] [numeric](12, 2) NOT NULL,
	[January_201401_CS_Balance_AMNT_Before_CR346_Defect13156Script_Update] [numeric](12, 2) NOT NULL,
	[January_201401_CS_Balance_AMNT_After_CR346_Defect13156Script_Update] [numeric](12, 2) NOT NULL,
	[December_201312_Arrear_Balance_AMNT_Before_CR346_Defect13156Script_Update] [numeric](22, 2) NOT NULL,
	[December_201312_Arrear_Balance_AMNT_After_CR346_Defect13156Script_Update] [numeric](22, 2) NOT NULL,
	[January_201401_Arrear_Balance_AMNT_Before_CR346_Defect13156Script_Update] [numeric](22, 2) NOT NULL,
	[January_201401_Arrear_Balance_AMNT_After_CR346_Defect13156Script_Update] [numeric](22, 2) NOT NULL,
	[December_201312_Arrear_Adjustment_AMNT_After_CR346_Defect13156Script_Update] [numeric](20, 2) NOT NULL,
	[December_201312_CS_Balance_Difference_AMNT] [numeric](13, 2) NULL,
	[January_201401_CS_Balance_Difference_AMNT] [numeric](13, 2) NULL,
	[December_201312_Arrear_Balance_Difference_AMNT] [numeric](23, 2) NULL,
	[January_201401_Arrear_Balance_Difference_AMNT] [numeric](23, 2) NULL,
	[ArrearAdjustment_Match_INDC] [varchar](3) NULL,
	[Defect1287AdjAmnt_CR0346AdjtAmnt_Difference] [numeric](24, 2) NOT NULL,
	[EligibleForTesting_INDC] [varchar](1) NOT NULL,
	[Mismatch_INDC] [varchar](1) NOT NULL,
	[MismatchReason_TEXT] [varchar](500) NULL,
	[MismatchCategory_TEXT] [varchar](500) NULL,
	[MismatchReasonDescription_TEXT] [varchar](2000) NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
