/****** Object:  StoredProcedure [dbo].[CFAR_RETRIEVE_S1]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CFAR_RETRIEVE_S1] (
 @Ac_Function_CODE CHAR(3),
 @Ac_Action_CODE   CHAR(1)
 )
AS
 /*
  *     PROCEDURE NAME    : CFAR_RETRIEVE_S1
  *     DESCRIPTION       : Retrieve Value, Description Code and Description of the Reference Table for a Function code, Action code and Reason code for which the request is made, order by Description Value. 
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 25-OCT-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Lc_Imcl_CODE  CHAR(4) = 'IMCL',
          @Lc_Space_TEXT CHAR(1) = ' ',
          @Lc_Blank_CODE CHAR(5) = 'BLANK',
          @Lc_Refl_CODE  CHAR(4) = 'REFL';

  SELECT DISTINCT ISNULL ((CASE a.reason_code                   
                           WHEN @Lc_Space_TEXT               
                              THEN NULL                      
                           ELSE a.reason_code                
                        END),@Lc_Blank_CODE ) AS Reason_CODE,   
         a.DescriptionFar_TEXT
    FROM CFAR_Y1 a,
         REFM_Y1 b
   WHERE a.Function_CODE = @Ac_Function_CODE
     AND a.Action_CODE = @Ac_Action_CODE
     AND (a.Reason_CODE = @Lc_Space_TEXT
           OR a.Reason_CODE = b.Value_CODE)
     AND b.Table_ID = @Lc_Imcl_CODE
     AND b.TableSub_ID = @Lc_Refl_CODE
   ORDER BY a.DescriptionFar_TEXT;
   
 END; --END OF CFAR_RETRIEVE_S1  


GO
