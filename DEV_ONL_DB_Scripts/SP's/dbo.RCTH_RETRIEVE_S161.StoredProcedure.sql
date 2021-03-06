/****** Object:  StoredProcedure [dbo].[RCTH_RETRIEVE_S161]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[RCTH_RETRIEVE_S161]  (

     
     @Ac_CheckNo_TEXT		CHAR(18),
     @Ac_Exists_INDC         CHAR(1)  OUTPUT
   )  
AS

/*
 *  PROCEDURE NAME    : RCTH_RETRIEVE_S161
 *  DESCRIPTION       : It return 'Y' for data exists,otherwise it return 'N'
 *  DEVELOPED BY      : IMP Team
 *  DEVELOPED ON      : 02-NOV-2011
 *  MODIFIED BY       : 
 *  MODIFIED ON       : 
 *  VERSION NO        : 1
*/
   BEGIN 

     

      DECLARE
         @Lc_Yes_INDC         CHAR(1)  = 'Y',
         @Lc_No_INDC		  CHAR(1)  = 'N',	
         @Ld_High_DATE        DATE     = '12/31/9999'; 
      SET @Ac_Exists_INDC = @Lc_No_INDC;
      
      SELECT  @Ac_Exists_INDC = @Lc_Yes_INDC
        FROM RCTH_Y1 R
        WHERE 
          R.CheckNo_TEXT=@Ac_CheckNo_TEXT
         AND  R.EndValidity_DATE = @Ld_High_DATE ;
      

                  
END; --END OF RCTH_RETRIEVE_S161


GO
