/****** Object:  StoredProcedure [dbo].[ICAS_RETRIEVE_S14]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[ICAS_RETRIEVE_S14] (
 @An_Case_IDNO              NUMERIC(6, 0),
 @Ac_IVDOutOfStateFips_CODE CHAR(2),
 @Ac_Reason_CODE            CHAR(5),
 @An_RespondentMci_IDNO     NUMERIC(10, 0),
 @An_PetitionerMci_IDNO     NUMERIC(10, 0),
 @Ai_Count_QNTY             INT OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : ICAS_RETRIEVE_S14
  *     DESCRIPTION       : To Check whether a Case id already have Same Petitioner , Respondent , Reason for a Valid open Other State.
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
    FROM ICAS_Y1 i
   WHERE i.Case_IDNO = @An_Case_IDNO
     AND i.IVDOutOfStateFips_CODE = @Ac_IVDOutOfStateFips_CODE
     AND i.Status_CODE = @Lc_CaseStatusOpen_CODE
     AND i.Reason_CODE = @Ac_Reason_CODE
     AND i.PetitionerMCI_IDNO = @An_PetitionerMci_IDNO
     AND i.RespondentMCI_IDNO = @An_RespondentMci_IDNO
     AND i.EndValidity_DATE = @Ld_High_DATE;
 END; -- End of ICAS_RETRIEVE_S14

GO
