/****** Object:  StoredProcedure [dbo].[DSBH_RETRIEVE_S14]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[DSBH_RETRIEVE_S14]  (

     @Ac_Misc_ID		 CHAR(11),
     @An_Check_NUMB		 NUMERIC(19,0)	 OUTPUT
     )
AS
 /*
  *     PROCEDURE NAME    : DSBH_RETRIEVE_S14
  *     DESCRIPTION       : Retrieves the valid check number for a given input.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 07-FEB-2012
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
  */
   BEGIN

      SET @An_Check_NUMB = NULL;
      DECLARE
         @Ld_High_DATE DATE = '12/31/9999';
      SELECT @An_Check_NUMB = D.Check_NUMB
      FROM DSBH_Y1 D
      WHERE D.Misc_ID = @Ac_Misc_ID 
      AND D.EndValidity_DATE = @Ld_High_DATE;

                  
END


GO
