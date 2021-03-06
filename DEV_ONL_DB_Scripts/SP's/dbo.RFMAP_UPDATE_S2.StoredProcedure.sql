/****** Object:  StoredProcedure [dbo].[RFMAP_UPDATE_S2]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[RFMAP_UPDATE_S2] ( 

				@Ad_Begin_DATE         DATE
				)            
AS

/*
 *     PROCEDURE NAME    : RFMAP_UPDATE_S2
 *     DESCRIPTION       : This procedue is used to end the current valid record inorder to insert new record.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 02-NOV-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/
   BEGIN

		DECLARE
				@Ld_High_DATE	DATE	= '12/31/9999';
        
         UPDATE RFMAP_Y1 
            SET End_DATE = DATEADD(D, -1, @Ad_Begin_DATE)
		  WHERE EndValidity_DATE = @Ld_High_DATE
            AND End_DATE = @Ld_High_DATE;
            
        DECLARE @Ln_RowsAffected_NUMB NUMERIC(10);
        
            SET @Ln_RowsAffected_NUMB = @@ROWCOUNT;
      
         SELECT @Ln_RowsAffected_NUMB;
        
END; --END OF RFMAP_UPDATE_S2


GO
