/****** Object:  StoredProcedure [dbo].[NRRQ_RETRIEVE_S15]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[NRRQ_RETRIEVE_S15] 
( 
	@An_Case_IDNO				NUMERIC(6,0),
	@Ad_NMSNIssued_DATE			DATE		OUTPUT
)   
AS
/*
 *     PROCEDURE NAME    : NRRQ_RETRIEVE_S15
 *     DESCRIPTION       : This procedure is used to retrieve the NMSN generated date for medical support component.
 *     DEVELOPED BY      : IMP TEAM
 *     DEVELOPED ON      : 05-MAR-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/
BEGIN	
	    SET @Ad_NMSNIssued_DATE			= NULL;

	DECLARE @Li_Zero_NUMB				INT     = 0,
			@Lc_NoticeENF03_ID			CHAR(8) = 'ENF-03';
	
			 SELECT TOP 1 @Ad_NMSNIssued_DATE	= n.Generate_DTTM
			   FROM NRRQ_Y1 n
		      WHERE n.Case_IDNO			   = @An_Case_IDNO
				AND n.Notice_ID			   = @Lc_NoticeENF03_ID
				AND ISNUMERIC(n.Notice_ID) = @Li_Zero_NUMB
		   ORDER BY n.barcode_NUMB DESC;
                      
END;  --END OF NRRQ_RETRIEVE_S15


GO
