/****** Object:  StoredProcedure [dbo].[R34RT_RETRIEVE_S10]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

 CREATE PROCEDURE [dbo].[R34RT_RETRIEVE_S10](
			@Ad_BeginQtr_DATE				DATE,
			@Ad_EndQtr_DATE					DATE,
			@Ad_Batch_DATE					DATE,
			@An_Batch_NUMB					NUMERIC (4,0),
			@An_SeqReceipt_NUMB				NUMERIC (6,0) ,
			@Ac_SourceBatch_CODE			CHAR(3),
			@Ai_RowFrom_NUMB				INT  = 1,
			@Ai_RowTo_NUMB					INT  = 10
			 )			
AS  
  
/*  
 *     PROCEDURE NAME    : R34RT_RETRIEVE_S10   
 *     DESCRIPTION       : This Procedure is used to show the supporting reciept level details of
 *						   LineNo3 in the report.
 *     DEVELOPED BY      : IMP Team  
 *     DEVELOPED ON      : 15-NOV-2011  
 *     MODIFIED BY       :   
 *     MODIFIED ON       :   
 *     VERSION NO        : 1  
 */  
 BEGIN  
	 DECLARE @Li_Zero_NUMB SMALLINT =0; 					
	  SELECT b.Batch_DATE,
			 b.SourceBatch_CODE,
			 b.Batch_NUMB,
			 b.SeqReceipt_NUMB, 
			 b.Case_IDNO, 
			 b.PayorMCI_IDNO, 
			 b.Receipt_DATE, 
			 b.CheckNo_TEXT, 
			 b.LineNo3_AMNT,
             b.RowCount_NUMB
        FROM (
				SELECT a.Batch_DATE,
					   a.SourceBatch_CODE,
					   a.Batch_NUMB,
					   a.SeqReceipt_NUMB, 
					   a.Case_IDNO, 
					   a.PayorMCI_IDNO, 
					   a.Receipt_DATE, 
					   a.CheckNo_TEXT,
                       a.LineNo3_AMNT, 
                       a.RowCount_NUMB, 
                       a.Row_NUMB
                  FROM (
						  SELECT r.Batch_DATE,
								 r.SourceBatch_CODE,
								 r.Batch_NUMB,
								 r.SeqReceipt_NUMB,
                                 r.Case_IDNO, 
                                 r.PayorMCI_IDNO, 
                                 r.Receipt_DATE, 
                                 r.CheckNo_TEXT,
                                 r.LineNo3_AMNT,
                                 COUNT(1) OVER() RowCount_NUMB,
                                 ROW_NUMBER() OVER (ORDER BY Batch_DATE, Batch_NUMB, SeqReceipt_NUMB,
															 SourceBatch_CODE ) AS Row_NUMB 
                            FROM R34RT_Y1 r
                           WHERE r.LineNo3_AMNT != @Li_Zero_NUMB
                             AND r.BeginQtr_DATE = @Ad_BeginQtr_DATE
                             AND r.EndQtr_DATE = @Ad_EndQtr_DATE
                             AND (   (    @Ad_Batch_DATE IS NOT NULL
                                      AND r.Batch_DATE = @Ad_Batch_DATE
                                      AND r.Batch_NUMB = @An_Batch_NUMB
                                      AND r.SeqReceipt_NUMB = @An_SeqReceipt_NUMB
                                      AND r.SourceBatch_CODE = @Ac_SourceBatch_CODE
                                     )
                                  OR (@Ad_Batch_DATE IS NULL)
                                 )
                        ) a 
                 WHERE a.Row_NUMB <= @Ai_RowTo_NUMB
             ) b
       WHERE b.Row_NUMB >= @Ai_RowFrom_NUMB;
 
 END; --END OF R34RT_RETRIEVE_S10
 

GO
