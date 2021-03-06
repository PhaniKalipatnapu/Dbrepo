/****** Object:  StoredProcedure [dbo].[PARM_RETRIEVE_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[PARM_RETRIEVE_S1]
AS
 /*  
 *      PROCEDURE NAME     : PARM_RETRIEVE_S1  
  *     DESCRIPTION       : Retrieve all Distinct Job Idno and Description.  
  *     DEVELOPED BY      : IMP Team    
  *     DEVELOPED ON      : 02-AUG-2011  
  *     MODIFIED BY       :   
  *     MODIFIED ON       :   
  *     VERSION NO        : 1  
 */
 BEGIN
  DECLARE @Ld_High_DATE DATE = '12/31/9999';

  SELECT DISTINCT a.Job_ID,
         (SELECT c.DescriptionJob_TEXT
            FROM PARM_Y1 c
           WHERE c.Job_ID = a.Job_ID
             AND c.EndValidity_DATE = @Ld_High_DATE) AS DescriptionJob_TEXT
    FROM PARM_Y1 a
   ORDER BY DescriptionJob_TEXT;
 END; --End of PARM_RETRIEVE_S1   

GO
