/****** Object:  StoredProcedure [dbo].[DMNR_RETRIEVE_S127]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE  [dbo].[DMNR_RETRIEVE_S127]
 (
   @An_Case_IDNO                    NUMERIC(6, 0),  
   @Ad_Entered_DATE					DATE  OUTPUT
 )
As
 
 /*                                                                                                                                                     
  *     PROCEDURE NAME    : DMNR_RETRIEVE_S127                                                                                                            
  *     DESCRIPTION       : Retrieves the recent date NCP’s information was submitted to the Child Support Lien Network (CSLN).
  *     DEVELOPED BY      : IMP Team                                                                                                                  
  *     DEVELOPED ON      : 16-MAY-2012                                                                                                                 
  *     MODIFIED BY       :                                                                                                                             
  *     MODIFIED ON       :                                                                                                                             
  *     VERSION NO        : 1                                                                                                                           
 */    
 
BEGIN
   
	SET @Ad_Entered_DATE =NULL;
  
  	DECLARE @Lc_ActivityMinorMosle_CODE	CHAR(5) = 'MOSLE',
  			@Lc_ActivityMajorCsln_CODE CHAR(4) = 'CSLN',
  			@Ld_Low_DATE				DATE = '01/01/0001';

	SELECT @Ad_Entered_DATE = MIN(D.Entered_DATE)
	FROM DMNR_Y1 D, (SELECT *  
					FROM(SELECT A.MajorIntSeq_NUMB,
								A.Entered_DATE,
								A.Case_IDNO,
								ROW_NUMBER() OVER(ORDER BY Entered_DATE DESC) RowCount_NUMB
						 FROM DMJR_Y1 A
						 WHERE A.Case_IDNO = @An_Case_IDNO
							AND A.ActivityMajor_CODE = @Lc_ActivityMajorCsln_CODE)X 
					WHERE RowCount_NUMB = 1)Y
	WHERE D.ActivityMinor_CODE  = @Lc_ActivityMinorMosle_CODE
		  AND D.Case_IDNO = @An_Case_IDNO
		  AND D.Case_IDNO = Y.Case_IDNO
		  AND D.MajorIntSeq_NUMB  = Y.MajorIntSeq_NUMB;
                            
                            
 END; -- END OF DMNR_RETRIEVE_S127                                
GO
