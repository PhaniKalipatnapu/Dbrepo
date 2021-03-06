/****** Object:  StoredProcedure [dbo].[CSPR_RETRIEVE_S5]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CSPR_RETRIEVE_S5] (
 @An_Request_IDNO           NUMERIC(9, 0),
 @An_Case_IDNO              NUMERIC(6, 0),
 @Ac_IVDOutOfStateFips_CODE CHAR(2)
 )
AS
 /*
  *     PROCEDURE NAME    : CSPR_RETRIEVE_S5
  *     DESCRIPTION       : Retrieve Csenet Pending Request details for a Case Idno, Request Idno, Other State Fips Code, and End Validity date.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 11-OCT-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
  */
 BEGIN
  DECLARE @Ld_Current_DATE DATE = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();

  SELECT c.Request_IDNO,
         c.Generated_DATE,
         c.Case_IDNO,
         c.IVDOutOfStateFips_CODE,
         c.IVDOutOfStateCountyFips_CODE,
         c.IVDOutOfStateOfficeFips_CODE,
         c.IVDOutOfStateCase_ID,
         c.ExchangeMode_INDC,
         c.Form_ID,
         c.FormWeb_URL,
         c.TransHeader_IDNO,
         c.Function_CODE,
         c.Action_CODE,
         c.Reason_CODE,
         c.DescriptionComments_TEXT,
         c.CaseFormer_ID,
         c.InsCarrier_NAME,
         c.InsPolicyNo_TEXT,
         c.Hearing_DATE,
         c.Dismissal_DATE,
         c.GeneticTest_DATE,
         c.Attachment_INDC,
         c.File_ID,
         c.PfNoShow_DATE,
         c.ArrearComputed_DATE,
         c.TotalInterestOwed_AMNT,
         c.TotalArrearsOwed_AMNT,
         c.RespondentMci_IDNO
    FROM CSPR_Y1 c
   WHERE c.Case_IDNO = @An_Case_IDNO
     AND c.Request_IDNO = @An_Request_IDNO
     AND c.IVDOutOfStateFips_CODE = @Ac_IVDOutOfStateFips_CODE
     AND c.EndValidity_DATE = @Ld_Current_DATE;
 END; -- End of CSPR_RETRIEVE_S5

GO
