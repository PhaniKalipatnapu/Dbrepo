/****** Object:  StoredProcedure [dbo].[CSPR_RETRIEVE_S2]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CSPR_RETRIEVE_S2] (
 @An_Case_IDNO          NUMERIC(6, 0),
 @An_RespondentMci_IDNO NUMERIC(10, 0),
 @Ai_Count_QNTY         INT OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : CSPR_RETRIEVE_S2
  *     DESCRIPTION       : Retrieves the Row count for the given case idno, function code, status request code, generated date and end validity date equal to high date.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 04-OCT-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
  */
 BEGIN
  SET @Ai_Count_QNTY = NULL;

  DECLARE @Ld_High_DATE                 DATE = '12/31/9999',
          @Lc_FunctionLo1_CODE          CHAR(3) = 'LO1',
          @Lc_StatusRequestPending_CODE CHAR(2) = 'PN',
          @Ld_Current_DATE              DATE = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();

  SELECT @Ai_Count_QNTY = COUNT(1)
    FROM CSPR_Y1 a
   WHERE a.Case_IDNO = @An_Case_IDNO
     AND a.Function_CODE = @Lc_FunctionLo1_CODE
     AND a.StatusRequest_CODE = @Lc_StatusRequestPending_CODE
     AND a.RespondentMci_IDNO = @An_RespondentMci_IDNO
     AND a.Generated_DATE = @Ld_Current_DATE
     AND a.EndValidity_DATE = @Ld_High_DATE;
 END; -- End of CSPR_RETRIEVE_S2

GO
