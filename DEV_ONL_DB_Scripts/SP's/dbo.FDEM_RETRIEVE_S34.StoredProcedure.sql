/****** Object:  StoredProcedure [dbo].[FDEM_RETRIEVE_S34]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[FDEM_RETRIEVE_S34]
	(    
		@Ac_File_ID	CHAR(10)
     )  
AS  
  
/*  
 *     PROCEDURE NAME    : FDEM_RETRIEVE_S34  
 *     DESCRIPTION       : Retrieve the case id's associated with given file id
 *     DEVELOPED BY      : Imp Team  
 *     DEVELOPED ON      : 25-JAN-2012  
 *     MODIFIED BY       :   
 *     MODIFIED ON       :   
 *     VERSION NO        : 1  
*/  
BEGIN
  
	DECLARE 
		@Li_Zero_NUMB INT  = 0 ,
		@Ld_High_DATE DATE = '12/31/9999';  

	SELECT DISTINCT f.Case_IDNO 
	  FROM FDEM_Y1 f
	 WHERE f.File_ID = @Ac_File_ID
	   AND f.EndValidity_DATE = @Ld_High_DATE;
 
END; --FDEM_RETRIEVE_S34


GO
