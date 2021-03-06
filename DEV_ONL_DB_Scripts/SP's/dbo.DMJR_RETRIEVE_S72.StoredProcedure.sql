/****** Object:  StoredProcedure [dbo].[DMJR_RETRIEVE_S72]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DMJR_RETRIEVE_S72] 
( 
	@An_Case_IDNO				NUMERIC(6,0),
	@Ad_Opened_DATE				DATE,
	@Ad_StatusCurrent_DATE		DATE,
	@An_MajorIntSeq_NUMB		NUMERIC(5,0) OUTPUT
)   
AS
/*
 *     PROCEDURE NAME    : DMJR_RETRIEVE_S72
 *     DESCRIPTION       : This Procedure is used to fetch the Minimum of MajorIntseq Number.
 *     DEVELOPED BY      : IMP TEAM
 *     DEVELOPED ON      : 02-MAR-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/
BEGIN
	   SET @An_MajorIntSeq_NUMB				= NULL;

   DECLARE @Lc_ActivityMajorCCLO_CODE		CHAR(4) = 'CCLO',
		   @Lc_StatusCOMP_CODE				CHAR(4) = 'COMP';
   
	SELECT @An_MajorIntSeq_NUMB = MIN (a.MajorIntSeq_NUMB)
      FROM DMJR_Y1 a
     WHERE a.Case_IDNO = @An_Case_IDNO
       AND a.Entered_DATE BETWEEN @Ad_Opened_DATE AND @Ad_StatusCurrent_DATE
       AND a.ActivityMajor_CODE = @Lc_ActivityMajorCCLO_CODE
       AND a.Status_CODE = @Lc_StatusCOMP_CODE;
                  
END; -- END OF DMJR_RETRIEVE_S72
 

GO
