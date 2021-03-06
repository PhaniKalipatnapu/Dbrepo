/****** Object:  StoredProcedure [dbo].[ICAS_RETRIEVE_S29]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[ICAS_RETRIEVE_S29] (
 @An_Case_IDNO   NUMERIC(6, 0),
 @Ac_Reason_CODE CHAR(5),
 @Ai_Count_QNTY  INT OUTPUT
 )
AS
 /*
 *     PROCEDURE NAME     : ICAS_RETRIEVE_S29
  *     DESCRIPTION       : To Check Whether ISIN record Exists for the Referral Types.For Referral Type's from REFM ISIN/REFL
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      :20-OCT-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SET @Ai_Count_QNTY = NULL;

  DECLARE @Ld_High_DATE       DATE = '12/31/9999',
          @Lc_StatusOpen_CODE CHAR(1)='O';

  SELECT @Ai_Count_QNTY = COUNT(1)
    FROM ICAS_Y1 I
   WHERE I.Case_IDNO = @An_Case_IDNO
     AND I.Reason_CODE = @Ac_Reason_CODE
     AND Status_CODE = @Lc_StatusOpen_CODE
     AND EndValidity_DATE = @Ld_High_DATE;
 END; -- End of ICAS_RETRIEVE_S29

GO
