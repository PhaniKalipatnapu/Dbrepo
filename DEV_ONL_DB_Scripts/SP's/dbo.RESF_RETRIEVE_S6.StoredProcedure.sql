/****** Object:  StoredProcedure [dbo].[RESF_RETRIEVE_S6]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[RESF_RETRIEVE_S6] (
 @Ac_Process_ID CHAR(10),
 @Ac_Type_CODE  CHAR(5)
 )
AS
 /*                                                                                                                                                                                                                       
  *     PROCEDURE NAME    : RESF_RETRIEVE_S6                                                                                                                                                                               
  *     DESCRIPTION       : Retrive reason code and description text for process id ,type code                                                                                                                                                                                              
  *     DEVELOPED BY      : IMP Team                                                                                                                                                                                    
  *     DEVELOPED ON      : 06-OCT-2011                                                                                                                                                                                   
  *     MODIFIED BY       :                                                                                                                                                                                               
  *     MODIFIED ON       :                                                                                                                                                                                               
  *     VERSION NO        : 1                                                                                                                                                                                             
 */
 BEGIN
  SELECT b.Value_CODE,
         b.DescriptionValue_TEXT
    FROM RESF_Y1 a
         JOIN REFM_Y1 b
          ON b.Table_ID = a.Table_ID
             AND b.TableSub_ID = a.TableSub_ID
             AND b.Value_CODE = a.Reason_CODE
   WHERE a.Process_ID = @Ac_Process_ID
     AND a.Type_CODE = @Ac_Type_CODE
   ORDER BY DescriptionValue_TEXT;
 END; --END OF RESF_RETRIEVE_S6	                                                                                                                                                                                                                      

GO
