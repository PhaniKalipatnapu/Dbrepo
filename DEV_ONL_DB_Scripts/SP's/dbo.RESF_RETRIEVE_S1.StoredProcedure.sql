/****** Object:  StoredProcedure [dbo].[RESF_RETRIEVE_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[RESF_RETRIEVE_S1]  
(
     @Ac_Type_CODE		     CHAR(5),           
     @Ac_Reason_CODE         CHAR(5),          
     @Ai_Count_QNTY          INT           OUTPUT
)     
AS                                                              

/*
*     PROCEDURE NAME    : RESF_RETRIEVE_S1
*     DESCRIPTION       : Retrieves Count for the given Cross Reason Code Records.
*     DEVELOPED BY      : IMP Team
*     DEVELOPED ON      : 02-AUG-2011
*     MODIFIED BY       : 
*     MODIFIED ON       : 
*     VERSION NO        : 1
*/

   BEGIN

      SET @Ai_Count_QNTY = NULL;

      DECLARE
         @Lc_ProcessDhld_ID CHAR(5) = 'DHLD',
         @Li_One_NUMB       SMALLINT = 1,
         @Li_Two_NUMB       SMALLINT = 2;
        
      SELECT @Ai_Count_QNTY = COUNT(1)
      FROM RESF_Y1 R
      WHERE RTRIM(LTRIM(R.Type_CODE)) = @Ac_Type_CODE
      AND R.Reason_CODE = SUBSTRING(@Ac_Reason_CODE, @Li_One_NUMB, @Li_Two_NUMB) 
      AND R.Process_ID = @Lc_ProcessDhld_ID;

                  
END; --End of RESF_RETRIEVE_S1  


GO
