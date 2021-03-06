/****** Object:  StoredProcedure [dbo].[UCASE_RETRIEVE_S8]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
CREATE PROCEDURE [dbo].[UCASE_RETRIEVE_S8] 
(
	@Ad_Begin_DATE			DATE,
	@Ad_End_DATE			DATE,
	@An_SampleSize_QNTY		NUMERIC(7,0)
)
AS
/*                                                                                     
  *     PROCEDURE NAME    : UCASE_RETRIEVE_S8                                            
  *     DESCRIPTION       : This procedure is used to retrieve the cases that are associated with Incoming Intergovernmental services.
  *     DEVELOPED BY      : IMP TEAM                                                
  *     DEVELOPED ON      : 03/10/2012  
  *     MODIFIED BY       :                                                             
  *     MODIFIED ON       :                                                             
  *     VERSION NO        : 1                                                           
  */
BEGIN 
 
 DECLARE @Li_One_NUMB					INT		= 1,
		 @Ld_High_DATE					DATE    = '12/31/9999',
		 @Lc_RespondInitI_CODE			CHAR(1) = 'I',
         @Lc_RespondInitC_CODE			CHAR(1) = 'C',
         @Lc_RespondInitT_CODE			CHAR(1) = 'T',
		 @Lc_StatusCaseO_CODE			CHAR(1) = 'O',
		 @Lc_RefAssistR_CODE			CHAR(1) = 'R',
		 @Lc_TypeCaseH_CODE				CHAR(1) = 'H';
		  
	 SELECT m.Case_IDNO,
			m.StatusCase_CODE,
			m.TypeCase_CODE,
			m.RespondInit_CODE,
			m.County_IDNO,
			m.Office_IDNO,
			m.CaseTitle_NAME,
			m.Worker_ID,
			m.RsnStatusCase_CODE,
			m.Opened_DATE,
			m.Row_NUMB,
			m.RowCount_NUMB
	   FROM (SELECT b.Case_IDNO,
					b.StatusCase_CODE,
					b.TypeCase_CODE,
					b.RespondInit_CODE,
					b.County_IDNO,
					b.Office_IDNO,
					b.CaseTitle_NAME,
					b.Worker_ID,
					b.RsnStatusCase_CODE,
					b.Opened_DATE, 
					b.BeginValidity_DATE,
					ROW_NUMBER () OVER (ORDER BY NEWID()) Row_NUMB,
					COUNT (1) OVER () AS RowCount_NUMB			
			   FROM (SELECT a.Case_IDNO,
							a.StatusCase_CODE,
							a.TypeCase_CODE,
							a.RespondInit_CODE,
							a.County_IDNO,
							a.Office_IDNO,
							(SELECT c.CaseTitle_NAME
							   FROM UDCKT_V1 c
							  WHERE c.File_ID = a.File_ID
								AND c.EndValidity_DATE = @Ld_High_DATE) AS CaseTitle_NAME,
							a.Worker_ID,
							a.RsnStatusCase_CODE,
							a.Opened_DATE,
							a.BeginValidity_DATE ,
							ROW_NUMBER () OVER (PARTITION BY a.Case_IDNO ORDER BY a.TransactionEventSeq_NUMB DESC) AS Case_RowNum
					   FROM UCASE_V1 a 
					  WHERE a.StatusCase_CODE = @Lc_StatusCaseO_CODE    
					    AND a.TypeCase_CODE <> @Lc_TypeCaseH_CODE   
						AND a.RespondInit_CODE IN (@Lc_RespondInitC_CODE, @Lc_RespondInitI_CODE,  @Lc_RespondInitT_CODE) 
						AND a.BeginValidity_DATE BETWEEN @Ad_Begin_DATE AND @Ad_End_DATE
						AND EXISTS (SELECT 1  
									  FROM ICAS_Y1 d JOIN CFAR_Y1 f  
										ON f.Reason_CODE      = d.Reason_CODE  
									 WHERE d.Case_IDNO        = a.Case_IDNO  
									   AND f.RefAssist_CODE   = @Lc_RefAssistR_CODE 
								)
					 )b 
			   WHERE b.Case_RowNum = @Li_One_NUMB
			  ) m
		WHERE Row_NUMB < = @An_SampleSize_QNTY;

 END --End Of Procedure UCASE_RETRIEVE_S8

GO
