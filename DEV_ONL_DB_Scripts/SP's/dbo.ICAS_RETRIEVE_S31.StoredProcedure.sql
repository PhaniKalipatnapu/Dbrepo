/****** Object:  StoredProcedure [dbo].[ICAS_RETRIEVE_S31]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[ICAS_RETRIEVE_S31] (
 @An_Case_IDNO              NUMERIC(6, 0),
 @Ac_IVDOutOfStateFips_CODE CHAR(2),
 @Ac_Reason_CODE            CHAR(5)
 )
AS
 /*
  *     PROCEDURE NAME    : ICAS_RETRIEVE_S31
  *     DESCRIPTION       : To Retrive Respondent Name for the selected ISIN state.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 11-OCT-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
  */
 BEGIN
  DECLARE @Ld_High_DATE       DATE = '12/31/9999',
          @Lc_StatusOpen_CODE CHAR(1)='O';

  SELECT DISTINCT I.Respondent_NAME,
         I.RespondentMci_IDNO
    FROM ICAS_Y1 I
   WHERE I.Case_IDNO = @An_Case_IDNO
     AND I.Reason_CODE = @Ac_Reason_CODE
     AND I.IVDOutOfStateFips_CODE = @Ac_IVDOutOfStateFips_CODE
     AND I.Status_CODE = @Lc_StatusOpen_CODE
     AND I.EndValidity_DATE = @Ld_High_DATE;
 END; -- End of ICAS_RETRIEVE_S31

GO
