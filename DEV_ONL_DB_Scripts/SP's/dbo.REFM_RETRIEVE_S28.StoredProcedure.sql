/****** Object:  StoredProcedure [dbo].[REFM_RETRIEVE_S28]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[REFM_RETRIEVE_S28]
AS
 /*                                                               
  *     PROCEDURE NAME    : REFM_RETRIEVE_S28                      
  *     DESCRIPTION       : Procedure is used to get the REFM details.                                      
  *     DEVELOPED BY      : IMP Team                             
  *     DEVELOPED ON      : 02-AUG-2011                           
  *     MODIFIED BY       :                                       
  *     MODIFIED ON       :                                       
  *     VERSION NO        : 1                                     
 */
 BEGIN
  SELECT R.Table_ID,
         R.TableSub_ID,
         R.Value_CODE,
         R.DescriptionValue_TEXT,
         R.DispOrder_NUMB
    FROM REFM_Y1 R
   ORDER BY R.DispOrder_NUMB,
            R.DescriptionValue_TEXT;
 END; -- End of REFM_RETRIEVE_S28                                                             


GO
