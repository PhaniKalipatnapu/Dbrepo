/****** Object:  StoredProcedure [dbo].[UCASE_RETRIEVE_S10]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[UCASE_RETRIEVE_S10] (
	 @Ad_Begin_DATE      DATE,
	 @Ad_End_DATE        DATE,
	 @An_SampleSize_QNTY NUMERIC(7, 0)
 )
AS
 /*                                                                                     
  *     PROCEDURE NAME    : UCASE_RETRIEVE_S10                                            
  *     DESCRIPTION       : This procedure is used to retrieve the cases that are associated with Outgoing Intergovernmental services.
  *     DEVELOPED BY      : IMP TEAM                                                
  *     DEVELOPED ON      : 03/10/2012  
  *     MODIFIED BY       :                                                             
  *     MODIFIED ON       :                                                             
  *     VERSION NO        : 1                                                           
  */
 BEGIN
  DECLARE @Li_One_NUMB					INT = 1,
          @Ld_High_DATE					DATE = '12/31/9999',
          @Lc_IoDirectionI_CODE			CHAR(1) = 'I',
          @Lc_RespondInitR_CODE			CHAR(1) = 'R',
		  @Lc_RespondInitY_CODE			CHAR(1) = 'Y',
		  @Lc_RespondInitS_CODE			CHAR(1) = 'S',
          @Lc_StatusCaseO_CODE			CHAR(1) = 'O',
          @Lc_RefAssistR_CODE			CHAR(1) = 'R',
          @Lc_TypeCaseH_CODE			CHAR(1) = 'H';
		  
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
							ROW_NUMBER () OVER (PARTITION BY a.Case_IDNO ORDER BY a.TransactionEventSeq_NUMB DESC) AS Case_RowNum
					   FROM UCASE_V1 a 
					  WHERE a.StatusCase_CODE = @Lc_StatusCaseO_CODE    
					    AND a.TypeCase_CODE <> @Lc_TypeCaseH_CODE   
						AND a.RespondInit_CODE IN (@Lc_RespondInitR_CODE, @Lc_RespondInitS_CODE, @Lc_RespondInitY_CODE) 
						AND a.BeginValidity_DATE BETWEEN @Ad_Begin_DATE AND @Ad_End_DATE
						AND EXISTS ( SELECT 1  
									   FROM CTHB_Y1 d JOIN CFAR_Y1 f  
										 ON f.Function_CODE    = d.Function_CODE  
										AND f.Action_CODE      = d.Action_CODE  
										AND f.Reason_CODE      = d.Reason_CODE  
									  WHERE d.Case_IDNO        = a.Case_IDNO  
										AND f.RefAssist_CODE   = @Lc_RefAssistR_CODE  
										AND d.IoDirection_CODE = @Lc_IoDirectionI_CODE 
										AND d.Transaction_DATE >= a.BeginValidity_DATE)
						AND NOT EXISTS (SELECT 1
										  FROM BSAIN_Y1 b
										 WHERE b.Case_IDNO = a.Case_IDNO
										 AND b.EndValidity_DATE = @Ld_High_DATE)
					 )b 
			   WHERE b.Case_RowNum = @Li_One_NUMB
			  ) m
		WHERE Row_NUMB < = @An_SampleSize_QNTY;

 END --End Of Procedure UCASE_RETRIEVE_S10

GO
