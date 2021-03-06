/****** Object:  StoredProcedure [dbo].[BSUP_RETRIEVE_S2]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[BSUP_RETRIEVE_S2] (
 @An_Case_IDNO  	NUMERIC(6, 0),
 @Ac_Exists_INDC	CHAR(1) OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : BSUP_RETRIEVE_S2
  *     DESCRIPTION       : Check whether the given case is in billing suppression.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 02-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN

  DECLARE  @Lc_Yes_TEXT  	CHAR(1) = 'Y',  
           @Lc_No_TEXT   	CHAR(1) = 'N',
           @Ld_Current_DATE	DATE = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),  
  		   @Ld_High_DATE 	DATE = '12/31/9999';
  			
  SET @Ac_Exists_INDC = @Lc_No_TEXT;   			
  			
  SELECT @Ac_Exists_INDC = @Lc_Yes_TEXT
    FROM BSUP_Y1 a
   WHERE a.Case_IDNO = @An_Case_IDNO
     AND (a.End_DATE > @Ld_Current_DATE 
			OR a.End_DATE = @Ld_Current_DATE)
     AND a.EndValidity_DATE = @Ld_High_DATE;   
      
 END; --END OF BSUP_RETRIEVE_S2


GO
