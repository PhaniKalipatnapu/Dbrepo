/****** Object:  StoredProcedure [dbo].[RFMAP_RETRIEVE_S7]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[RFMAP_RETRIEVE_S7] (

			 @Ad_Begin_DATE    DATE,
			 @Ai_Count_QNTY    INT  OUTPUT
			 )
AS

/*
 *     PROCEDURE NAME    : RFMAP_RETRIEVE_S7
 *     DESCRIPTION       : This procedure to check whether the same record already exists in the table.
 *						   This will check the same Percentage amount has been already in FMAP_Y1 table for the
 *						   corresponding fiscal year.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 02-NOV-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
 */
BEGIN
      
      DECLARE
			  @Ld_High_DATE		DATE = '12/31/9999';
	
		  SET @Ai_Count_QNTY = NULL;
		        
       SELECT @Ai_Count_QNTY = COUNT(1)
         FROM RFMAP_Y1 a
        WHERE a.Begin_DATE = @Ad_Begin_DATE 
          AND a.EndValidity_DATE = @Ld_High_DATE;
                
END;  --END OF RFMAP_RETRIEVE_S7


GO
