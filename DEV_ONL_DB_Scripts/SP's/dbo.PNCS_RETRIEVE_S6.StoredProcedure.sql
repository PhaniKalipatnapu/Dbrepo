/****** Object:  StoredProcedure [dbo].[PNCS_RETRIEVE_S6]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[PNCS_RETRIEVE_S6] (
 @Ac_IvaCase_ID         CHAR(10),
 @Ac_StatusIvaCase_CODE CHAR(1) OUTPUT,
 @Ad_Referral_DATE      DATE OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : PNCS_RETRIEVE_S6
  *     DESCRIPTION       : Retrieve Top 1 record, Case Type of IVA Case Status when Welfare Type is Medical Aid then NON PA else PA TANF, IVA Case Status when Welfare Type is Medical Aid then Medical Aid only else Current Assistance, Source Referral to Famis and Referral Date to System Date for a IVA Case ID for the Pending Case.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 20-SEP-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Ld_SystemDate_DATE DATE=DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();

  SELECT @Ac_StatusIvaCase_CODE = NULL,
         @Ad_Referral_DATE = NULL;

  SELECT TOP 1 @Ac_StatusIvaCase_CODE = p.StatusIvaCase_CODE,
               @Ad_Referral_DATE = CONVERT(DATE, @Ld_SystemDate_DATE)
    FROM PNCS_Y1 p
   WHERE p.IvaCase_ID = @Ac_IvaCase_ID;
 END; --End of PNCS_RETRIEVE_S6


GO
