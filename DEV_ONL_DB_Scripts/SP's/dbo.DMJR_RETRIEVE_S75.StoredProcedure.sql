/****** Object:  StoredProcedure [dbo].[DMJR_RETRIEVE_S75]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
CREATE PROCEDURE [dbo].[DMJR_RETRIEVE_S75]
(
	@Ad_Begin_DATE			DATE,
	@An_Case_IDNO			NUMERIC(6,0),
	@An_MajorIntSeq_NUMB	NUMERIC(5,0) OUTPUT
)
AS
/*                                                                                     
  *     PROCEDURE NAME    : DMJR_RETRIEVE_S75                                            
  *     DESCRIPTION       : This procedure is used to retrieve the Majorintseq number.  
  *     DEVELOPED BY      : IMP TEAM                                                
  *     DEVELOPED ON      : 03/08/2012  
  *     MODIFIED BY       :                                                             
  *     MODIFIED ON       :                                                             
  *     VERSION NO        : 1                                                           
  */
BEGIN
		SET @An_MajorIntSeq_NUMB		= NULL;
 
	DECLARE @Lc_ActivityMajorOBRA_CODE		CHAR(4) = 'OBRA',
			@Lc_ActivityMinorRMDCY_CODE		CHAR(5) = 'RMDCY',
			@Ld_ThreeYrsOld_DATE			DATE = DATEADD(MM,-36,@Ad_Begin_DATE);
 
	 SELECT @An_MajorIntSeq_NUMB = MAX(a.MajorIntSeq_NUMB)
	   FROM DMJR_Y1 a
	  WHERE a.Case_IDNO = @An_Case_IDNO
	    AND a.ActivityMajor_CODE =@Lc_ActivityMajorOBRA_CODE
		AND a.Entered_DATE BETWEEN @Ld_ThreeYrsOld_DATE AND @Ad_Begin_DATE
		AND NOT EXISTS(SELECT 1
						 FROM DMNR_Y1 b
						WHERE b.Case_IDNO = a.Case_IDNO
						  AND b.MajorIntSeq_NUMB = a.MajorIntSeq_NUMB
						  AND b.ActivityMinor_CODE <> @Lc_ActivityMinorRMDCY_CODE);
 
END --End Of Procedure DMJR_RETRIEVE_S75
 

GO
