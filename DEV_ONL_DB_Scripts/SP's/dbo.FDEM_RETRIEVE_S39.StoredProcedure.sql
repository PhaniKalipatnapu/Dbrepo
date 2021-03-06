/****** Object:  StoredProcedure [dbo].[FDEM_RETRIEVE_S39]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[FDEM_RETRIEVE_S39] (
 @An_Case_IDNO		NUMERIC(6, 0),
 @Ac_File_ID		CHAR(10),
 @Ac_Exists_INDC	CHAR(1)		OUTPUT
 )
AS
 /*  
  *     PROCEDURE NAME    : FDEM_RETRIEVE_S39  
  *     DESCRIPTION       : checks the valid case idno, file id  are exists while ADD
  *     DEVELOPED BY      : IMP Team  
  *     DEVELOPED ON      : 22-MAR-2012  
  *     MODIFIED BY       :   
  *     MODIFIED ON       :   
  *     VERSION NO        : 1  
 */
 BEGIN
  DECLARE  
	@Lc_Yes_INDC	CHAR(1) = 'Y',
	@Lc_No_INDC		CHAR(1) = 'N',
	@Ld_High_DATE	DATE	= '12/31/9999';

SET
	@Ac_Exists_INDC = @Lc_No_INDC ;

  SELECT @Ac_Exists_INDC = @Lc_Yes_INDC
    FROM (SELECT 1 Exists_INDC
		 FROM CASE_Y1 C
		WHERE C.Case_IDNO = @An_Case_IDNO
		  AND C.File_ID = @Ac_File_ID
			UNION
		  SELECT 1
		FROM FDEM_Y1 F
		WHERE F.Case_IDNO = @An_Case_IDNO 
		  AND F.File_ID = @Ac_File_ID
		  AND F.EndValidity_DATE = @Ld_High_DATE
		  AND NOT EXISTS (SELECT 1 
						 FROM SORD_Y1 S
						WHERE S.File_ID = F.File_ID
						  AND S.Case_IDNO = F.Case_IDNO
						  AND S.EndValidity_DATE = @Ld_High_DATE)) A ;
						  
					  
					      
 END; -- END OF FDEM_RETRIEVE_S39  



GO
