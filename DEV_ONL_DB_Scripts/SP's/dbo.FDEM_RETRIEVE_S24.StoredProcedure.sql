/****** Object:  StoredProcedure [dbo].[FDEM_RETRIEVE_S24]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[FDEM_RETRIEVE_S24] 
(
 @An_Case_IDNO         NUMERIC(6, 0),
 @Ac_File_ID		   CHAR(10),
 @An_MajorIntSeq_NUMB  NUMERIC(6)
)
AS

/*
 *     PROCEDURE NAME    : FDEM_RETRIEVE_S24
 *     DESCRIPTION       : Retrieve the case id and file id  for the given petition id
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 16-oct-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/

BEGIN
	DECLARE @Ld_High_DATE         DATE = '12/31/9999',
	        @Li_Zero_NUMB         SMALLINT = 0;

	SELECT DISTINCT F.Petition_IDNO
	FROM FDEM_Y1 F
	WHERE F.Case_IDNO = @An_Case_IDNO
	AND F.File_ID = @Ac_File_ID 
	AND (@An_MajorIntSeq_NUMB IS NULL
	      OR
	      (@An_MajorIntSeq_NUMB IS NOT NULL 
	      AND F.MajorIntSeq_NUMB <> @Li_Zero_NUMB
		  AND F.MajorIntSeq_NUMB = @An_MajorIntSeq_NUMB	))		
	AND F.Petition_IDNO <> @Li_Zero_NUMB								
	AND F.EndValidity_DATE = @Ld_High_DATE;
	
END ; -- END OF FDEM_RETRIEVE_S24

GO
