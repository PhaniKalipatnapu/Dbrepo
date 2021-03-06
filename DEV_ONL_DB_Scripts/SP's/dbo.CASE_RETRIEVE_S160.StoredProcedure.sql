/****** Object:  StoredProcedure [dbo].[CASE_RETRIEVE_S160]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CASE_RETRIEVE_S160] (
 @An_Case_IDNO  NUMERIC(6, 0),
 @Ac_TypeWelfare_CODE	 CHAR(1),
 @Ai_Count_QNTY INT OUTPUT
 )
AS
 /*
 *      PROCEDURE NAME    : CASE_RETRIEVE_S160
  *     DESCRIPTION       : Retrieve the Row Count for given Case Idno where 
                            Intergovernmental Responding case to have the Program Type as Non Tanf.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 19-AUG-2013
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SET @Ai_Count_QNTY = NULL;

  DECLARE @Lc_RespondInitS_CODE					CHAR(1) = 'S',
          @Lc_RespondInitY_CODE					CHAR(1) = 'Y',  
          @Lc_RespondInitResponding_CODE 		CHAR(1) = 'R',
          @Lc_WelfareTypeNonTanf				CHAR(1) = 'N',
          @Ld_Highdate							DATE =  '12/31/9999';        

  SELECT @Ai_Count_QNTY = COUNT(1)
    FROM CASE_Y1 c
   WHERE c.Case_IDNO = @An_Case_IDNO
     AND c.RespondInit_CODE IN (@Lc_RespondInitResponding_CODE,@Lc_RespondInitY_CODE,@Lc_RespondInitS_CODE)
     AND EXISTS (SELECT 1 FROM 
                  MHIS_Y1 m 
                 WHERE m.Case_IDNO = c.Case_IDNO
                   AND m.TypeWelfare_CODE = @Lc_WelfareTypeNonTanf
                   AND m.End_DATE = @Ld_Highdate)
     AND @Ac_TypeWelfare_CODE !=@Lc_WelfareTypeNonTanf;
  
 END; -- END OF CASE_RETRIEVE_S160

GO
