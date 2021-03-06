/****** Object:  StoredProcedure [dbo].[CTHB_RETRIEVE_S20]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CTHB_RETRIEVE_S20] (
 @Ad_TransactionFrom_DATE   DATE,
 @Ac_IVDOutOfStateFips_CODE CHAR(2),
 @Ac_FullDisplay_NAME       CHAR(37),
 @Ai_Count_QNTY             INT OUTPUT
 )
AS
 /*    
  *     PROCEDURE NAME    : CTHB_RETRIEVE_S20    
  *     DESCRIPTION       : To Retrieve Total Quick Locate (LO1) Requests received during the current calendar year.
  *     DEVELOPED BY      : IMP Team    
  *     DEVELOPED ON      : 01-SEP-2011    
  *     MODIFIED BY       :     
  
  *     MODIFIED ON       :     
  *     VERSION NO        : 1    
 */
 BEGIN
  SET @Ai_Count_QNTY = NULL;

  DECLARE @Lc_FunctionQuickLocate_CODE CHAR(3) = 'LO1',
          @Lc_Space_TEXT               CHAR(1) = ' ',
          @Lc_ActionR_CODE             CHAR(1) = 'R';

  SELECT @Ai_Count_QNTY = COUNT(1)
    FROM CTHB_Y1 a
         JOIN CFAR_Y1 b
          ON a.Action_CODE = b.Action_CODE
             AND a.Function_CODE = b.Function_CODE
             AND a.Reason_CODE = b.Reason_CODE
         JOIN CNCB_Y1 c
          ON c.TransHeader_IDNO = a.TransHeader_IDNO
   WHERE (@Ac_FullDisplay_NAME IS NULL
           OR (@Ac_FullDisplay_NAME IS NOT NULL
               AND ((RTRIM (c.First_NAME) + @Lc_Space_TEXT + RTRIM (c.Last_NAME) = @Ac_FullDisplay_NAME)
                     OR ((RTRIM (c.First_NAME) = @Ac_FullDisplay_NAME)
                          OR (RTRIM (c.Last_NAME) = @Ac_FullDisplay_NAME)))))
     AND (@Ac_IVDOutOfStateFips_CODE IS NULL
           OR (@Ac_IVDOutOfStateFips_CODE IS NOT NULL
               AND a.IVDOutOfStateFips_CODE = @Ac_IVDOutOfStateFips_CODE))
     AND a.Function_CODE = @Lc_FunctionQuickLocate_CODE
     AND a.Action_CODE = @Lc_ActionR_CODE
     AND YEAR(a.Transaction_DATE) = YEAR(@Ad_TransactionFrom_DATE);
 END; --End of CTHB_RETRIEVE_S20     


GO
