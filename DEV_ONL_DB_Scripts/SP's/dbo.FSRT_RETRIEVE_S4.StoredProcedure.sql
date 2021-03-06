/****** Object:  StoredProcedure [dbo].[FSRT_RETRIEVE_S4]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[FSRT_RETRIEVE_S4](
 @An_Case_IDNO          NUMERIC(6),
 @An_MajorIntSeq_NUMB   NUMERIC(5),
 @Ac_ServiceResult_CODE CHAR(1) OUTPUT,
 @Ai_Count_QNTY         INT OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : FDEM_RETRIEVE_S1
  *     DESCRIPTION       : This procedure checks whether a petition is created or not for the given Case ID and the active Major sequence int.
  *     DEVELOPED BY      : Imp Team
  *     DEVELOPED ON      : 20-OCT-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SET @Ai_Count_QNTY = NULL;

  DECLARE @Li_Zero_NUMB INT = 0,
		  @Lc_ServiceResultPositive_CODE CHAR(1)	= 'P',
          @Ld_High_DATE DATE = '12/31/9999';

  SELECT @Ac_ServiceResult_CODE = f.ServiceResult_CODE,
         @Ai_Count_QNTY = COUNT(1)
    FROM FSRT_Y1 f
   WHERE f.Case_IDNO = @An_Case_IDNO
     AND f.MajorIntSeq_NUMB = @An_MajorIntSeq_NUMB
     AND f.Petition_IDNO != @Li_Zero_NUMB
     AND (f.ServiceResult_CODE != @Lc_ServiceResultPositive_CODE
     OR (f.ServiceResult_CODE = @Lc_ServiceResultPositive_CODE
     AND f.EndValidity_DATE = @Ld_High_DATE))
   GROUP BY f.Case_IDNO,
            f.MajorIntSeq_NUMB,
            f.ServiceResult_CODE;
 END


GO
