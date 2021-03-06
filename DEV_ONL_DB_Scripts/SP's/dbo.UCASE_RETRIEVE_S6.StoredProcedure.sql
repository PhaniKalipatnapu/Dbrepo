/****** Object:  StoredProcedure [dbo].[UCASE_RETRIEVE_S6]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[UCASE_RETRIEVE_S6] (
	 @Ad_Begin_DATE      DATE,
	 @Ad_End_DATE        DATE,
	 @An_SampleSize_QNTY NUMERIC(7, 0)
 )
AS
 /*                                                                                   
 *     PROCEDURE NAME    : UCASE_RETRIEVE_S6                                          
 *     DESCRIPTION       : This procedure is used to retrieve the cases that associated with expedited process
 *     DEVELOPED BY      : IMP TEAM                                              
 *     DEVELOPED ON      : 07/MAR/2012
 *     MODIFIED BY       :                                                           
 *     MODIFIED ON       :                                                           
 *     VERSION NO        : 1                                                         
 */
 BEGIN
  DECLARE @Li_One_NUMB                    INT = 1,
          @Ld_Low_DATE                    DATE = '01/01/0001',
          @Ld_High_DATE                   DATE = '12/31/9999',
          @Lc_StatusCaseC_CODE            CHAR(1) = 'C',
          @Lc_StatusCaseO_CODE            CHAR(1) = 'O',
          @Lc_TypeCaseH_CODE              CHAR(1) = 'H',
          @Lc_TypeOrderV_CODE             CHAR(1) = 'V',          
		  @Lc_ServiceResultP_CODE		  CHAR(1) = 'P',
		  @Lc_ServiceResultN_CODE		  CHAR(1) = 'N',
          @Lc_ReasonStatusDB_CODE         CHAR(2) = 'DB',
          @Lc_StatusCOMP_CODE             CHAR(4) = 'COMP',
          @Lc_ActivityMajorESTP_CODE      CHAR(4) = 'ESTP',
          @Lc_ActivityMajorCASE_CODE      CHAR(4) = 'CASE',
          @Lc_ActivityMinorROPDP_CODE     CHAR(4) = 'ROPDP',
		  @Lc_ActivityMinorANDDI_CODE     CHAR(5) = 'ANDDI',
          @Lc_WorkerUpdateCONVERSION_CODE CHAR(30)= 'CONVERSION';

  SELECT m.Case_IDNO,
         m.StatusCase_CODE,
         m.TypeCase_CODE,
         m.RespondInit_CODE,
         m.County_IDNO,
         m.Office_IDNO,
         (SELECT d.CaseTitle_NAME
            FROM UDCKT_V1 d
           WHERE d.File_ID = M.File_ID
             AND d.EndValidity_DATE = @Ld_High_DATE) AS CaseTitle_NAME,
         m.Worker_ID,
         m.RsnStatusCase_CODE,
         m.Opened_DATE AS CaseCreation_DATE,
         m.WorkerUpdate_ID,
         m.Update_DTTM,
         m.Row_NUMB,
         m.RowCount_NUMB
    FROM (SELECT y.Case_IDNO,
                 y.StatusCase_CODE,
                 y.TypeCase_CODE,
                 y.RespondInit_CODE,
                 y.County_IDNO,
                 y.Office_IDNO,
                 y.File_ID,
                 y.Worker_ID,
                 y.RsnStatusCase_CODE,
                 y.Opened_DATE,
                 y.WorkerUpdate_ID,
                 y.Update_DTTM,
                 ROW_NUMBER () OVER (ORDER BY NEWID()) Row_NUMB,
                 COUNT (1) OVER () AS RowCount_NUMB
            FROM (SELECT a.Case_IDNO,
                         a.StatusCase_CODE,
                         a.TypeCase_CODE,
                         a.RespondInit_CODE,
                         a.County_IDNO,
                         a.Office_IDNO,
                         a.Worker_ID,
                         a.RsnStatusCase_CODE,
                         CASE a.WorkerUpdate_ID
							WHEN @Lc_WorkerUpdateCONVERSION_CODE
								THEN a.Opened_DATE
							ELSE a.Update_DTTM
                         END Opened_DATE,
                         a.File_ID,
                         a.WorkerUpdate_ID,
                         a.Update_DTTM,
                         ROW_NUMBER () OVER (PARTITION BY a.Case_IDNO ORDER BY a.TransactionEventSeq_NUMB) AS Case_RowNum
                    FROM UCASE_V1 a
                   WHERE a.StatusCase_CODE = @Lc_StatusCaseO_CODE
                     AND a.TypeCase_CODE <> @Lc_TypeCaseH_CODE
                     AND CASE a.WorkerUpdate_ID
							WHEN @Lc_WorkerUpdateCONVERSION_CODE
								THEN a.Opened_DATE
							ELSE a.Update_DTTM
                         END BETWEEN (SELECT ISNULL(MAX (u.StatusCurrent_DATE), @Ld_Low_DATE) 	
                                        FROM UCASE_V1 u
                                       WHERE u.Case_IDNO = a.Case_IDNO
                                         AND u.StatusCase_CODE = @Lc_StatusCaseC_CODE
                                         AND u.Update_DTTM <= @Ad_Begin_DATE) AND @Ad_Begin_DATE) y
           WHERE Case_RowNum = @Li_One_NUMB
             AND (EXISTS (SELECT 1
                            FROM (SELECT s.Case_IDNO,
                                         s.OrderSeq_NUMB,
                                         s.EventGlobalBeginSeq_NUMB,
                                         CASE s.WorkerUpdate_ID
											WHEN @Lc_WorkerUpdateCONVERSION_CODE
												THEN s.OrderIssued_DATE
											ELSE s.BeginValidity_DATE
                                         END OrderIssued_DATE,
                                         ROW_NUMBER() OVER(ORDER BY EventGlobalBeginSeq_NUMB ASC) Row_NUMB
                                    FROM SORD_Y1 s JOIN FSRT_Y1 f
                                      ON s.Case_IDNO = f.Case_IDNO
                                   WHERE s.Case_IDNO = y.Case_IDNO
                                     AND s.TypeOrder_CODE <> @Lc_TypeOrderV_CODE
                                     AND f.ServiceResult_CODE = @Lc_ServiceResultP_CODE                                     
									 AND (SELECT MAX(d.Service_DATE) 
											FROM FSRT_Y1 d 
										   WHERE d.Case_IDNO =y.Case_IDNO
											 AND d.EndValidity_DATE = @Ld_High_DATE) < = @Ad_End_DATE 
                                     AND CASE y.WorkerUpdate_ID
											WHEN @Lc_WorkerUpdateCONVERSION_CODE
												THEN s.OrderIssued_DATE
											ELSE s.BeginValidity_DATE
                                         END >= y.Opened_DATE) s
                           WHERE Row_NUMB = @Li_One_NUMB  
                             AND S.OrderIssued_DATE BETWEEN @Ad_Begin_DATE AND @Ad_End_DATE
                         )
             OR (EXISTS(SELECT 1
						  FROM DMNR_Y1 b JOIN FSRT_Y1 f
							ON b.Case_IDNO = f.Case_IDNO
						   AND b.Case_IDNO = y.Case_IDNO
						   AND f.MajorIntSeq_NUMB = (SELECT MAX(c.MajorIntSeq_NUMB) 
													   FROM DMJR_Y1 c 
												      WHERE c.Case_IDNO = y.Case_IDNO
												        AND c.ActivityMajor_CODE	= @Lc_ActivityMajorESTP_CODE)
						   AND b.Status_CODE = @Lc_StatusCOMP_CODE
						   AND f.EndValidity_DATE = @Ld_High_DATE
						   AND ((b.ActivityMajor_CODE = @Lc_ActivityMajorESTP_CODE
								AND b.ActivityMinor_CODE = @Lc_ActivityMinorANDDI_CODE 
								AND b.ReasonStatus_CODE = @Lc_ReasonStatusDB_CODE
								AND f.ServiceResult_CODE = @Lc_ServiceResultN_CODE
								)
								OR (b.ActivityMajor_CODE = @Lc_ActivityMajorCASE_CODE  
									AND b.ActivityMinor_CODE = @Lc_ActivityMinorROPDP_CODE 
									AND f.ServiceResult_CODE = @Lc_ServiceResultP_CODE
									))
						   AND (SELECT MAX(d.Service_DATE) 
								  FROM FSRT_Y1 d 
								 WHERE d.Case_IDNO =y.Case_IDNO
								   AND d.EndValidity_DATE = @Ld_High_DATE) < = @Ad_End_DATE))))m
   WHERE m.Row_NUMB <= @An_SampleSize_QNTY;
   
 END --End Of Procedure UCASE_RETRIEVE_S6


GO
