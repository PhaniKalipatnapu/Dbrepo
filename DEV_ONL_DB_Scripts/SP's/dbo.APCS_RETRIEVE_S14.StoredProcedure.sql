/****** Object:  StoredProcedure [dbo].[APCS_RETRIEVE_S14]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[APCS_RETRIEVE_S14](
 @An_Application_IDNO NUMERIC(15),
 @An_MemberMci_IDNO   NUMERIC(10)
 )
AS
 /*    
 *     PROCEDURE NAME    : APCS_RETRIEVE_S14    
  *     DESCRIPTION       : Retrieve Case details at the time of Application Received for an Application ID and Member ID when Application ID is same in Case Members and Case details at the time of Application Received.    
  *     DEVELOPED BY      : IMP Team    
  *     DEVELOPED ON      : 02-MAR-2011    
  *     MODIFIED BY       :     
  *     MODIFIED ON       :     
  *     VERSION NO        : 1    
 */
 BEGIN
  DECLARE @Ld_High_DATE DATE = '12/31/9999';

  SELECT a.RsnStatusCase_CODE,
         a.RespondInit_CODE,
         a.SourceRfrl_CODE,
         a.GoodCause_CODE,
         a.GoodCause_DATE,
         a.Restricted_INDC,
         a.MedicalOnly_INDC,
         a.IvdApplicant_CODE,
         a.Application_IDNO,
         a.AppSent_DATE,
         a.AppReq_DATE,
         a.AppRetd_DATE,
         a.AppSigned_DATE,
         a.DescriptionComments_TEXT,
         a.NonCoop_CODE,
         a.NonCoop_DATE,
         a.Referral_DATE,
         a.CaseCategory_CODE,
         a.File_ID,
         a.ApplicationFee_CODE,
         a.FeePaid_DATE,
         a.ServiceRequested_CODE,
         a.StatusEnforce_CODE,
         a.FeeCheckNo_TEXT,
         a.RsnFeeWaived_CODE
    FROM APCS_Y1 a
         JOIN APCM_Y1 c
          ON a.Application_IDNO = c.Application_IDNO
   WHERE a.Application_IDNO = @An_Application_IDNO
     AND a.EndValidity_DATE = @Ld_High_DATE
     AND c.MemberMci_IDNO = @An_MemberMci_IDNO
     AND c.EndValidity_DATE = @Ld_High_DATE;
 END; --End of APCS_RETRIEVE_S14

GO
