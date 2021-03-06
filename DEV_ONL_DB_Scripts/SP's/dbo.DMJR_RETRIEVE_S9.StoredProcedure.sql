/****** Object:  StoredProcedure [dbo].[DMJR_RETRIEVE_S9]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DMJR_RETRIEVE_S9]  (
     @An_Case_IDNO		 NUMERIC(6,0),
     @Ai_Count_QNTY		 INT            OUTPUT
     )
AS

/*
 *     PROCEDURE NAME    : DMJR_RETRIEVE_S9
 *     DESCRIPTION       : Retrives the count for the case
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 12/29/2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1.0
 */

 BEGIN

      SET @Ai_Count_QNTY = NULL;

  DECLARE @Ld_High_DATE DATE                    = '12/31/9999', 
          @Lc_RemedyStatusComplete_CODE CHAR(4) = 'COMP', 
          @Lc_RemedyStatusExempt_CODE CHAR(4)   = 'EXMT', 
          @Lc_ActivityMajorCase_CODE CHAR(4)    = 'CASE', 
          @Lc_ActivityMajorCclo_CODE CHAR(4)    = 'CCLO';
        
   SELECT @Ai_Count_QNTY = COUNT(1)
	 FROM AMJR_Y1  r
	 LEFT OUTER JOIN DMJR_Y1  d
       ON d.ActivityMajor_CODE = r.ActivityMajor_CODE 
    WHERE d.Status_CODE NOT IN ( @Lc_RemedyStatusExempt_CODE,@Lc_RemedyStatusComplete_CODE ) 
	  AND d.Case_IDNO = @An_Case_IDNO 
	  AND d.ActivityMajor_CODE NOT IN ( @Lc_ActivityMajorCclo_CODE,@Lc_ActivityMajorCase_CODE) 
	  AND r.EndValidity_DATE = @Ld_High_DATE;
            
END--END OF DMJR_RETRIEVE_S9


GO
