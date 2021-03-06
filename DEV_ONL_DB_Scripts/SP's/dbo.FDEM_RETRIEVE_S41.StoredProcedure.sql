/****** Object:  StoredProcedure [dbo].[FDEM_RETRIEVE_S41]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[FDEM_RETRIEVE_S41](    
     @An_Case_IDNO	NUMERIC(6,0),
     @Ac_File_ID	CHAR(10),
     @Ac_Exists_INDC CHAR(1) OUTPUT
     )  
AS  
  
/*  
 *     PROCEDURE NAME    : FDEM_RETRIEVE_S41  
 *     DESCRIPTION       : Check whether dummy File_ID and Case_IDNO combination is valid.
 *     DEVELOPED BY      : Imp Team  
 *     DEVELOPED ON      : 20-OCT-2011  
 *     MODIFIED BY       :   
 *     MODIFIED ON       :   
 *     VERSION NO        : 1  
*/  
BEGIN
  
	DECLARE 
		@Lc_Empty_TEXT	CHAR(1) = '' ,
		@Ld_High_DATE	DATE = '12/31/9999', 
		@Lc_No_TEXT		CHAR(1)	= 'N',
		@Lc_Yes_TEXT	CHAR(1)	= 'Y';
		  	
	SET @Ac_Exists_INDC = @Lc_No_TEXT; 

	SELECT @Ac_Exists_INDC = @Lc_Yes_TEXT 
	  FROM FDEM_Y1 F
	 WHERE F.Case_IDNO = @An_Case_IDNO
	   AND F.File_ID = @Ac_File_ID
	   AND LTRIM(RTRIM(F.TypeDoc_CODE))= @Lc_Empty_TEXT
	   AND F.EndValidity_DATE = @Ld_High_DATE ;
 
END; --END OF FDEM_RETRIEVE_S41


GO
