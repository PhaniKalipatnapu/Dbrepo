/****** Object:  StoredProcedure [dbo].[FDEM_RETRIEVE_S37]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[FDEM_RETRIEVE_S37]
	(    
		@An_Case_IDNO			NUMERIC(6),
		@Ac_ShowAllFile_INDC	CHAR(1)
     )  
AS  
  
/*  
 *     PROCEDURE NAME    : FDEM_RETRIEVE_S37  
 *     DESCRIPTION       : Retrieving the File IDs conditionally according to the show all file input indicator for the given Case ID.
 *     DEVELOPED BY      : Imp Team  
 *     DEVELOPED ON      : 03-MAY-2012  
 *     MODIFIED BY       :   
 *     MODIFIED ON       :   
 *     VERSION NO        : 1  
*/  
BEGIN
   
	DECLARE 
		@Ld_High_DATE	DATE	= '12/31/9999',
		@Lc_No_TEXT		CHAR(1)	= 'N',
		@Lc_Yes_TEXT	CHAR(1)	= 'Y';
		  
	-- 13639 - Archived File ID is Excluded from Drop Down display - Start
	SELECT c.File_ID, 
		   @Lc_Yes_TEXT AS SordExists_INDC
	 FROM CASE_Y1 c
	WHERE c.Case_IDNO = @An_Case_IDNO
	  AND ISNULL(@Ac_ShowAllFile_INDC,'') != @Lc_Yes_TEXT 
	  AND EXISTS (SELECT 1
					FROM SORD_Y1 s
				   WHERE s.Case_IDNO = c.Case_IDNO
					 AND s.EndValidity_DATE = @Ld_High_DATE)
	UNION
	SELECT f.File_ID, 
		   @Lc_No_TEXT AS SordExists_INDC
	  FROM FDEM_Y1 f
	WHERE f.Case_IDNO = @An_Case_IDNO
	  AND f.EndValidity_DATE = @Ld_High_DATE
	  AND (@Ac_ShowAllFile_INDC = @Lc_Yes_TEXT 
	       OR ( EXISTS (SELECT 1
						 FROM DCKT_Y1 d
						WHERE d.File_ID = F.File_ID) 
				  AND NOT EXISTS (SELECT 1
									FROM SORD_Y1 s
								   WHERE s.Case_IDNO = f.Case_IDNO
									 AND s.EndValidity_DATE = @Ld_High_DATE)));
	-- 13639 - Archived File ID is Excluded from Drop Down display - End 
END; --END OF FDEM_RETRIEVE_S37


GO
