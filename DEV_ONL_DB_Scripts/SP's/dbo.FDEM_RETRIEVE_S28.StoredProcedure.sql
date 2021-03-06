/****** Object:  StoredProcedure [dbo].[FDEM_RETRIEVE_S28]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[FDEM_RETRIEVE_S28](    
     @An_Case_IDNO	NUMERIC(6)
     )  
AS  
  
/*  
 *     PROCEDURE NAME    : FDEM_RETRIEVE_S28  
 *     DESCRIPTION       : Retrieveing the file_id for the given Case_id.
 *     DEVELOPED BY      : Imp Team  
 *     DEVELOPED ON      : 20-OCT-2011  
 *     MODIFIED BY       :   
 *     MODIFIED ON       :   
 *     VERSION NO        : 1  
*/  
BEGIN
  
	DECLARE @Ld_High_DATE DATE = '12/31/9999';  
	
	-- 13639 - Archived File ID is Excluded from Drop Down display - Start
	SELECT DISTINCT f.File_ID 
	  FROM FDEM_Y1 f
	  WHERE f.Case_IDNO = @An_Case_IDNO
		AND f.EndValidity_DATE = @Ld_High_DATE
		AND EXISTS (SELECT 1 
					  FROM DCKT_Y1 d
				     WHERE d.File_ID = f.File_ID);
	-- 13639 - Archived File ID is Excluded from Drop Down display - End
 
END; --END OF FDEM_RETRIEVE_S28


GO
