/****** Object:  StoredProcedure [dbo].[DSBH_RETRIEVE_S13]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[DSBH_RETRIEVE_S13]  (

     @An_Check_NUMB		 NUMERIC(19,0),
     @Ac_Misc_ID		 CHAR(11)	 OUTPUT
     )
AS

/*   
  *     PROCEDURE NAME    : DSBH_RETRIEVE_S13   
  *     DESCRIPTION       : RRetrieves the valid control value for the given input.
  *     DEVELOPED BY      : IMP Team   
  *     DEVELOPED ON      : 02-FEB-2012   
  *     MODIFIED BY       :    
  *     MODIFIED ON       :    
  *     VERSION NO        : 1   
  */
   BEGIN

      SET @Ac_Misc_ID = NULL;

      DECLARE
         @Ld_High_DATE DATE = '12/31/9999';
        
        SELECT @Ac_Misc_ID = D.Misc_ID
      FROM DSBH_Y1 D
      WHERE D.Check_NUMB = @An_Check_NUMB 
      AND D.EndValidity_DATE = @Ld_High_DATE;

                  
END 


GO
