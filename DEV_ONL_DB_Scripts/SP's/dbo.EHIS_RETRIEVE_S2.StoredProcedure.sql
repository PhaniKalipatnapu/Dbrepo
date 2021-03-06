/****** Object:  StoredProcedure [dbo].[EHIS_RETRIEVE_S2]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[EHIS_RETRIEVE_S2] (
 @An_MemberMci_IDNO             NUMERIC(10, 0),
 @An_OthpPartyEmpl_IDNO         NUMERIC(9, 0),
 @Ad_EndEmployment_DATE         DATE,
 @Ad_BeginEmployment_DATE       DATE OUTPUT,
 @Ac_TypeIncome_CODE            CHAR(2) OUTPUT,
 @Ac_DescriptionOccupation_TEXT CHAR(32) OUTPUT,
 @An_IncomeNet_AMNT             NUMERIC(11, 2) OUTPUT,
 @An_IncomeGross_AMNT           NUMERIC(11, 2) OUTPUT,
 @Ac_FreqIncome_CODE            CHAR(1) OUTPUT,
 @Ac_FreqPay_CODE               CHAR(1) OUTPUT,
 @Ac_SourceLoc_CODE             CHAR(3) OUTPUT,
 @Ad_SourceReceived_DATE        DATE OUTPUT,
 @Ac_Status_CODE                CHAR(1) OUTPUT,
 @Ad_Status_DATE                DATE OUTPUT,
 @Ac_SourceLocConf_CODE         CHAR(3) OUTPUT,
 @Ac_InsProvider_INDC           CHAR(1) OUTPUT,
 @An_CostInsurance_AMNT         NUMERIC(11, 2) OUTPUT,
 @Ac_FreqInsurance_CODE         CHAR(1) OUTPUT,
 @Ac_DpCoverageAvlb_INDC        CHAR(1) OUTPUT,
 @Ac_EmployerPrime_INDC         CHAR(1) OUTPUT,
 @Ac_DpCovered_INDC             CHAR(1) OUTPUT,
 @Ad_EligCoverage_DATE          DATE OUTPUT,
 @Ac_InsReasonable_INDC         CHAR(1) OUTPUT,
 @Ac_LimitCcpa_INDC             CHAR(1) OUTPUT,
 @Ad_BeginValidity_DATE         DATE OUTPUT,
 @Ac_WorkerUpdate_ID            CHAR(30) OUTPUT,
 @Ad_Update_DTTM                DATETIME2 OUTPUT,
 @An_TransactionEventSeq_NUMB   NUMERIC(19, 0) OUTPUT,
 @As_OtherParty_NAME            VARCHAR(60) OUTPUT,
 @Ac_Attn_ADDR                  CHAR(40) OUTPUT,
 @As_Line1_ADDR                 VARCHAR(50) OUTPUT,
 @As_Line2_ADDR                 VARCHAR(50) OUTPUT,
 @Ac_City_ADDR                  CHAR(28) OUTPUT,
 @Ac_Zip_ADDR                   CHAR(15) OUTPUT,
 @Ac_State_ADDR                 CHAR(2) OUTPUT,
 @Ac_Country_ADDR               CHAR(2) OUTPUT,
 @An_Phone_NUMB                 NUMERIC(15, 0) OUTPUT,
 @An_Fax_NUMB                   NUMERIC(15, 0) OUTPUT,
 @An_Fein_IDNO                  NUMERIC(9, 0) OUTPUT,
 @An_Sein_IDNO                  NUMERIC(12, 0) OUTPUT
 )
AS
 /*                                                                                                                                                                                   
  *     PROCEDURE NAME    : EHIS_RETRIEVE_S2                                                                                                                                           
  *     DESCRIPTION       : Retrieve Employment information for a Member Idno, Other Party Idno, and Employment Begin Date that is common between four tables.                        
  *     DEVELOPED BY      : IMP Team                                                                                                                                                
  *     DEVELOPED ON      : 04-OCT-2011                                                                                                                                               
  *     MODIFIED BY       :                                                                                                                                                           
  *     MODIFIED ON       :                                                                                                                                                           
  *     VERSION NO        : 1                                                                                                                                                         
 */
 BEGIN
  SELECT @Ad_BeginEmployment_DATE = NULL,
         @Ac_TypeIncome_CODE = NULL,
         @Ac_DescriptionOccupation_TEXT = NULL,
         @An_IncomeNet_AMNT = NULL,
         @An_IncomeGross_AMNT = NULL,
         @Ac_FreqIncome_CODE = NULL,
         @Ac_FreqPay_CODE = NULL,
         @Ac_SourceLoc_CODE = NULL,
         @Ad_SourceReceived_DATE = NULL,
         @Ac_Status_CODE = NULL,
         @Ad_Status_DATE = NULL,
         @Ac_SourceLocConf_CODE = NULL,
         @Ac_InsProvider_INDC = NULL,
         @An_CostInsurance_AMNT = NULL,
         @Ac_FreqInsurance_CODE = NULL,
         @Ac_DpCoverageAvlb_INDC = NULL,
         @Ac_EmployerPrime_INDC = NULL,
         @Ac_DpCovered_INDC = NULL,
         @Ad_EligCoverage_DATE = NULL,
         @Ac_InsReasonable_INDC = NULL,
         @Ac_LimitCcpa_INDC = NULL,
         @Ad_BeginValidity_DATE = NULL,
         @Ac_WorkerUpdate_ID = NULL,
         @Ad_Update_DTTM = NULL,
         @An_TransactionEventSeq_NUMB = NULL,
         @As_OtherParty_NAME = NULL,
         @Ac_Attn_ADDR = NULL,
         @As_Line1_ADDR = NULL,
         @As_Line2_ADDR = NULL,
         @Ac_City_ADDR = NULL,
         @Ac_Zip_ADDR = NULL,
         @Ac_State_ADDR = NULL,
         @Ac_Country_ADDR = NULL,
         @An_Phone_NUMB = NULL,
         @An_Fax_NUMB = NULL,
         @An_Fein_IDNO = NULL,
         @An_Sein_IDNO = NULL;

  DECLARE @Ld_High_DATE DATE = '12/31/9999';

  SELECT @Ad_BeginEmployment_DATE = a.BeginEmployment_DATE,
         @Ac_TypeIncome_CODE = a.TypeIncome_CODE,
         @Ac_DescriptionOccupation_TEXT = a.DescriptionOccupation_TEXT,
         @An_IncomeNet_AMNT = a.IncomeNet_AMNT,
         @An_IncomeGross_AMNT = a.IncomeGross_AMNT,
         @Ac_FreqIncome_CODE = a.FreqIncome_CODE,
         @Ac_FreqPay_CODE = a.FreqPay_CODE,
         @Ac_SourceLoc_CODE = a.SourceLoc_CODE,
         @Ad_SourceReceived_DATE = a.SourceReceived_DATE,
         @Ac_Status_CODE = a.Status_CODE,
         @Ad_Status_DATE = a.Status_DATE,
         @Ac_SourceLocConf_CODE = a.SourceLocConf_CODE,
         @Ac_InsProvider_INDC = a.InsProvider_INDC,
         @An_CostInsurance_AMNT = a.CostInsurance_AMNT,
         @Ac_FreqInsurance_CODE = a.FreqInsurance_CODE,
         @Ac_DpCoverageAvlb_INDC = a.DpCoverageAvlb_INDC,
         @Ac_EmployerPrime_INDC = a.EmployerPrime_INDC,
         @Ac_DpCovered_INDC = a.DpCovered_INDC,
         @Ad_EligCoverage_DATE = a.EligCoverage_DATE,
         @Ac_InsReasonable_INDC = a.InsReasonable_INDC,
         @Ac_LimitCcpa_INDC = a.LimitCcpa_INDC,
         @Ad_BeginValidity_DATE = a.BeginValidity_DATE,
         @Ac_WorkerUpdate_ID = a.WorkerUpdate_ID,
         @Ad_Update_DTTM = a.Update_DTTM,
         @An_TransactionEventSeq_NUMB = a.TransactionEventSeq_NUMB,
         @As_OtherParty_NAME = b.OtherParty_NAME,
         @Ac_Attn_ADDR = b.Attn_ADDR,
         @As_Line1_ADDR = b.Line1_ADDR,
         @As_Line2_ADDR = b.Line2_ADDR,
         @Ac_City_ADDR = b.City_ADDR,
         @Ac_Zip_ADDR = b.Zip_ADDR,
         @Ac_State_ADDR = b.State_ADDR,
         @Ac_Country_ADDR = b.Country_ADDR,
         @An_Phone_NUMB = b.Phone_NUMB,
         @An_Fax_NUMB = b.Fax_NUMB,
         @An_Fein_IDNO = b.Fein_IDNO,
         @An_Sein_IDNO = b.Sein_IDNO
    FROM EHIS_Y1 a
         JOIN OTHP_Y1 b
          ON a.OthpPartyEmpl_IDNO = b.OtherParty_IDNO
   WHERE a.MemberMci_IDNO = @An_MemberMci_IDNO
     AND a.OthpPartyEmpl_IDNO = @An_OthpPartyEmpl_IDNO
     AND b.EndValidity_DATE = @Ld_High_DATE
     AND a.EndEmployment_DATE  = ISNULL(@Ad_EndEmployment_DATE ,@Ld_High_DATE);
      
 END; --END OF EHIS_RETRIEVE_S2                                                                                                                                                                                  


GO
