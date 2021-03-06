/****** Object:  StoredProcedure [dbo].[ACEN_RETRIEVE_S1]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[ACEN_RETRIEVE_S1] (
 @An_Case_IDNO                NUMERIC(6, 0),
 @An_TransactionEventSeq_NUMB NUMERIC(19, 0) OUTPUT,
 @Ac_ReasonStatus_CODE        CHAR(2) OUTPUT,
 @Ad_BeginExempt_DATE         DATE OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : ACEN_RETRIEVE_S1
  *     DESCRIPTION       : Retrieve Exempt Begin Date and Reason for Exempt.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 04-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SELECT @Ad_BeginExempt_DATE = NULL,
         @An_TransactionEventSeq_NUMB = NULL,
         @Ac_ReasonStatus_CODE = NULL;

  DECLARE @Lc_EnforcementStatusExempt_CODE CHAR(1) = 'E',
          @Ld_High_DATE                    DATE = '12/31/9999',
          @Ld_Low_DATE                     DATE = '01/01/0001';

  SELECT @An_TransactionEventSeq_NUMB = a.TransactionEventSeq_NUMB,
         @Ac_ReasonStatus_CODE = a.ReasonStatus_CODE,
         @Ad_BeginExempt_DATE = a.BeginExempt_DATE
    FROM ACEN_Y1 a
   WHERE a.Case_IDNO = @An_Case_IDNO
     AND a.StatusEnforce_CODE = @Lc_EnforcementStatusExempt_CODE
     AND a.EndValidity_DATE = @Ld_High_DATE
     AND CONVERT(DATE, DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME())BETWEEN a.BeginExempt_DATE AND a.EndExempt_DATE
     AND a.BeginExempt_DATE != @Ld_Low_DATE
     AND a.EndExempt_DATE = @Ld_High_DATE;
 END; -- END OF ACEN_RETRIEVE_S1

GO
