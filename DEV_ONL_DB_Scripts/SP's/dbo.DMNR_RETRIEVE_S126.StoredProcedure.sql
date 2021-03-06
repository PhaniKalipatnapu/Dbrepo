/****** Object:  StoredProcedure [dbo].[DMNR_RETRIEVE_S126]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE  [dbo].[DMNR_RETRIEVE_S126]
 (
   @An_Case_IDNO                    NUMERIC(6, 0),  
   @Ad_Entered_DATE					DATE  OUTPUT,
   @As_OtherParty_NAME				VARCHAR(60)  OUTPUT
 )
As
 
 /*                                                                                                                                                     
  *     PROCEDURE NAME    : DMNR_RETRIEVE_S126                                                                                                            
  *     DESCRIPTION       : Retrieves the NCP’s information was submitted to a financial institution to freeze and seize funds in the NCP’s account. 
  *     DEVELOPED BY      : IMP Team                                                                                                                  
  *     DEVELOPED ON      : 16-MAY-2012                                                                                                                 
  *     MODIFIED BY       :                                                                                                                             
  *     MODIFIED ON       :                                                                                                                             
  *     VERSION NO        : 1                                                                                                                           
 */    
 
BEGIN
   
	SET @Ad_Entered_DATE =NULL;
	SET @As_OtherParty_NAME =NULL;
  
  	DECLARE @Lc_ActivityMinorMorfd_CODE	CHAR(5) = 'MORFD',
  			@Lc_ActivityMajorFidm_CODE CHAR(4) = 'FIDM',
  			@Ld_Low_DATE				DATE = '01/01/0001';

	SELECT @Ad_Entered_DATE = MIN(D.Entered_DATE),
		@As_OtherParty_NAME = O.OtherParty_NAME
	FROM DMNR_Y1 D, OTHP_Y1 O, (SELECT *  
					FROM(SELECT A.MajorIntSeq_NUMB,
								A.Entered_DATE, 
								A.OthpSource_IDNO,
								A.Case_IDNO,
								ROW_NUMBER() OVER(ORDER BY Entered_DATE DESC) RowCount_NUMB
						 FROM DMJR_Y1 A
						 WHERE A.Case_IDNO = @An_Case_IDNO
							AND A.ActivityMajor_CODE = @Lc_ActivityMajorFidm_CODE)X
					WHERE RowCount_NUMB = 1)Y
	WHERE D.ActivityMinor_CODE  = @Lc_ActivityMinorMorfd_CODE
		  AND D.Case_IDNO = @An_Case_IDNO
		  AND D.Case_IDNO = Y.Case_IDNO
		  AND D.MajorIntSeq_NUMB  = Y.MajorIntSeq_NUMB  
		  AND O.OtherParty_IDNO = Y.OthpSource_IDNO
	GROUP BY O.OtherParty_NAME   
                            
                            
 END; -- END OF DMNR_RETRIEVE_S126                                
GO
