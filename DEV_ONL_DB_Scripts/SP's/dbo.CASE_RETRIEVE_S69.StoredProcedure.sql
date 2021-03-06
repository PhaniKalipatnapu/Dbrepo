/****** Object:  StoredProcedure [dbo].[CASE_RETRIEVE_S69]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CASE_RETRIEVE_S69] (
 @An_Case_IDNO  NUMERIC(6, 0),
 @Ai_Count_QNTY INT OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : CASE_RETRIEVE_S69
  *     DESCRIPTION       : Retrieve the Row Count for a Case Idno and Case is Initiating or Responding Case.
  *     DEVELOPED BY      :IMP Team
  *     DEVELOPED ON      : 04-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
  */
 BEGIN
  SET @Ai_Count_QNTY = NULL;

  DECLARE @Lc_CaseStatusOpen_CODE          CHAR(1) = 'O',
          @Lc_EnforcementStatusExempt_CODE CHAR(1) = 'E',
          @Lc_RespondInitInitiate_CODE     CHAR(1) = 'I',
          @Lc_RespondInitC_CODE            CHAR(1) = 'C',
          @Lc_RespondInitT_CODE            CHAR(1) = 'T',
          @Ld_High_DATE                    DATE = '12/31/9999',
          @Ld_Low_DATE                     DATE = '01/01/0001';

  SELECT @Ai_Count_QNTY = COUNT(1)
    FROM CASE_Y1 c
   WHERE c.Case_IDNO = @An_Case_IDNO
     AND c.RespondInit_CODE IN (@Lc_RespondInitInitiate_CODE, @Lc_RespondInitC_CODE, @Lc_RespondInitT_CODE)
     AND c.StatusCase_CODE = @Lc_CaseStatusOpen_CODE
     AND EXISTS (SELECT 1
                   FROM ACEN_Y1 a
                  WHERE a.Case_IDNO = c.Case_IDNO
                    AND a.StatusEnforce_CODE = @Lc_EnforcementStatusExempt_CODE
                    AND a.EndValidity_DATE = @Ld_High_DATE
                    AND CONVERT(DATE, DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME())BETWEEN a.BeginExempt_DATE AND a.EndExempt_DATE
                    AND a.BeginExempt_DATE != @Ld_Low_DATE);
 END; -- END OF CASE_RETRIEVE_S69

GO
