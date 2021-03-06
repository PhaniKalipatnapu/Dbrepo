/****** Object:  StoredProcedure [dbo].[FDEM_RETRIEVE_S38]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[FDEM_RETRIEVE_S38]
	(    
		@Ac_File_ID	CHAR(10)
     )  
AS  
  
/*  
 *     PROCEDURE NAME    : FDEM_RETRIEVE_S38  
 *     DESCRIPTION       : Retrieving the Case_ID for the given VALID File_id To ADD.
 *     DEVELOPED BY      : Imp Team  
 *     DEVELOPED ON      : 03-MAY-2012  
 *     MODIFIED BY       :   
 *     MODIFIED ON       :   
 *     VERSION NO        : 1  
*/  
BEGIN
   
	DECLARE 
		@Ld_High_DATE	DATE	= '12/31/9999';  

	SELECT C.Case_IDNO
	 FROM CASE_Y1 C
	WHERE C.File_ID = @Ac_File_ID
	  AND EXISTS (SELECT 1
				 FROM SORD_Y1 S
				WHERE S.File_ID = C.File_ID
				  AND S.EndValidity_DATE = @Ld_High_DATE)
	UNION
	SELECT F.Case_IDNO
	FROM FDEM_Y1 F
	WHERE F.File_ID = @Ac_File_ID
	  AND F.EndValidity_DATE = @Ld_High_DATE
	  AND NOT EXISTS (SELECT 1
					 FROM SORD_Y1 S
					WHERE S.File_ID = F.File_ID
					  AND S.EndValidity_DATE = @Ld_High_DATE)
 
END; --END OF FDEM_RETRIEVE_S38


GO
