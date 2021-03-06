/****** Object:  StoredProcedure [dbo].[FDEM_RETRIEVE_S44]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[FDEM_RETRIEVE_S44](    
     @An_Case_IDNO	       NUMERIC(6,0),
     @An_MajorIntSeq_NUMB  NUMERIC(6,0)
     )  
AS  
  
/*  
 *     PROCEDURE NAME    : FDEM_RETRIEVE_S44  
 *     DESCRIPTION       : Retrieveing the Linked File_id or Sord Established File_Id for the given Case_id and MajorIntSeq_NUMB for ADD and View pop up.
 *     DEVELOPED BY      : Imp Team  
 *     DEVELOPED ON      : 20-OCT-2011  
 *     MODIFIED BY       :   
 *     MODIFIED ON       :   
 *     VERSION NO        : 1  
*/  
BEGIN
  
	DECLARE 
		@Lc_Empty_TEXT	CHAR(1) = '' ,
		@Ld_High_DATE   DATE = '12/31/9999',
		@Li_Zero_NUMB   SMALLINT = 0;  

		SELECT  f.File_ID
		   FROM FDEM_Y1 f 
		   WHERE f.Case_IDNO        = @An_Case_IDNO    
		     AND ((@An_MajorIntSeq_NUMB IS NULL 
		            AND EXISTS ( SELECT 1 
		                  FROM SORD_Y1 S
		                  WHERE S.Case_IDNO =f.Case_IDNO
		                  AND S.File_ID =f.File_ID
		                   AND S.EndValidity_DATE = @Ld_High_DATE)
		     
		           OR (@An_MajorIntSeq_NUMB IS NOT NULL                
		                 AND f.MajorIntSeq_NUMB = @An_MajorIntSeq_NUMB)))
		    
		    AND  F.EndValidity_DATE = @Ld_High_DATE    
    
	    UNION
	   SELECT  F.File_ID
		  FROM FDEM_Y1 F  
		  JOIN DCKT_Y1 D  
		  ON F.File_ID = D.File_ID  
		 WHERE F.Case_IDNO = @An_Case_IDNO  
		  AND  F.MajorIntSeq_NUMB = ISNULL( @An_MajorIntSeq_NUMB,F.MajorIntSeq_NUMB)
		  AND F.EndValidity_DATE = @Ld_High_DATE 
		  AND NOT EXISTS  (SELECT 1  
							  FROM SORD_Y1 S  
							 WHERE S.Case_IDNO = F.Case_IDNO
							   AND S.EndValidity_DATE = @Ld_High_DATE )
END; --END OF FDEM_RETRIEVE_S44


GO
