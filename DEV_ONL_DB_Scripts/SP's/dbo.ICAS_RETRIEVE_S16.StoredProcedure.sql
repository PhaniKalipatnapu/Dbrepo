/****** Object:  StoredProcedure [dbo].[ICAS_RETRIEVE_S16]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[ICAS_RETRIEVE_S16] (
 @An_Case_IDNO                NUMERIC(6, 0),
 @Ac_IVDOutOfStateFips_CODE   CHAR(2),
 @Ac_Status_CODE              CHAR(1),
 @An_TransactionEventSeq_NUMB NUMERIC(19, 0),
 @Ac_Reason_CODE              CHAR(5),
 @An_PetitionerMci_IDNO       NUMERIC(10, 0),
 @An_RespondentMci_IDNO       NUMERIC(10, 0),
 @Ai_Count_QNTY               INT OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : ICAS_RETRIEVE_S16
  *     DESCRIPTION       : Retrieve the Row Count for a Case Idno, Other State Fips, and Status Code is Open.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 04-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
  */
 BEGIN
  SET @Ai_Count_QNTY = NULL;

  DECLARE @Lc_CaseStatusOpen_CODE CHAR(1) = 'O',
          @Ld_High_DATE           DATE = '12/31/9999';

  SELECT @Ai_Count_QNTY = COUNT(1)
    FROM ICAS_Y1 a
   WHERE a.Case_IDNO = @An_Case_IDNO
     AND a.IVDOutOfStateFips_CODE = @Ac_IVDOutOfStateFips_CODE
     AND a.Status_CODE = @Lc_CaseStatusOpen_CODE
     AND @Ac_Status_CODE = @Lc_CaseStatusOpen_CODE
     AND a.TransactionEventSeq_NUMB != @An_TransactionEventSeq_NUMB
     AND a.Reason_CODE=@Ac_Reason_CODE
     AND a.PetitionerMci_IDNO = @An_PetitionerMci_IDNO
     AND a.RespondentMci_IDNO = @An_RespondentMci_IDNO
     AND a.EndValidity_DATE = @Ld_High_DATE;
 END; -- END OF ICAS_RETRIEVE_S16

GO
