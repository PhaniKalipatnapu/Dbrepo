/****** Object:  StoredProcedure [dbo].[R34UD_RETRIEVE_S2]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

 CREATE PROCEDURE [dbo].[R34UD_RETRIEVE_S2](
			@Ad_BeginQtr_DATE				DATE,
			@Ad_EndQtr_DATE					DATE,
			@Ac_LineP1No_TEXT				CHAR(3),
			@Ac_LineP2No_TEXT				CHAR(3),
			@Ad_Batch_DATE					DATE,
			@An_Batch_NUMB					NUMERIC (4,0),
			@An_SeqReceipt_NUMB				NUMERIC (6,0) ,
			@Ac_SourceBatch_CODE			CHAR(3),
			@Ai_RowFrom_NUMB				INT  = 1,
			@Ai_RowTo_NUMB					INT  = 10
			 )			
AS  
  
/*  
 *     PROCEDURE NAME    : R34UD_RETRIEVE_S2   
 *     DESCRIPTION       : This Procedure is used to show the supporting receipt level details of the
 *						   lineNo9 in the report.
 *     DEVELOPED BY      : IMP Team  
 *     DEVELOPED ON      : 15-NOV-2011  
 *     MODIFIED BY       :   
 *     MODIFIED ON       :   
 *     VERSION NO        : 1  
 */  
 
 BEGIN  
	  DECLARE
			@Lc_LinePNo_TEXT	CHAR(3) = '0';
								
	  SELECT b.Batch_DATE,
			 b.SourceBatch_CODE,
			 b.Batch_NUMB,
			 b.SeqReceipt_NUMB, 
			 b.Case_IDNO, 
			 b.PayorMCI_IDNO, 
			 b.ObligationKey_ID,
			 b.Trans_DATE,
             b.Trans_AMNT,
			 b.CheckNo_TEXT,
			 b.LookIn_TEXT,
             b.ReasonHold_CODE,
             b.RowCount_NUMB
        FROM (
				SELECT a.Batch_DATE,
					   a.SourceBatch_CODE,
					   a.Batch_NUMB,
					   a.SeqReceipt_NUMB,
					   a.Case_IDNO, 
					   a.PayorMCI_IDNO, 
					   a.ObligationKey_ID,
					   a.Trans_DATE,
                       a.Trans_AMNT,
					   a.CheckNo_TEXT,
					   a.LookIn_TEXT,
                       a.ReasonHold_CODE,
                       a.RowCount_NUMB, 
                       a.Row_NUMB
                  FROM (
						  SELECT r.Batch_DATE,
								 r.SourceBatch_CODE,
								 r.Batch_NUMB,
								 r.SeqReceipt_NUMB,
                                 r.Case_IDNO, 
                                 r.PayorMCI_IDNO, 
                                 r.ObligationKey_ID,
                                 r.Trans_DATE,
                                 r.Trans_AMNT,
                                 r.CheckNo_TEXT,
                                 r.LookIn_TEXT,
                                 r.ReasonHold_CODE,
                                 COUNT(1) OVER() RowCount_NUMB,
                                 ROW_NUMBER() OVER (ORDER BY Batch_DATE, Batch_NUMB, SeqReceipt_NUMB,
															 SourceBatch_CODE ) AS Row_NUMB 
                            FROM R34UD_Y1 r
                           WHERE r.BeginQtr_DATE = @Ad_BeginQtr_DATE
                             AND r.EndQtr_DATE = @Ad_EndQtr_DATE
                             AND (    r.LineP1No_TEXT = @Ac_LineP1No_TEXT
								   OR @Ac_LineP1No_TEXT = @Lc_LinePNo_TEXT
								 )   	
							 AND (    (	  r.LineP2A1No_TEXT = @Ac_LineP2No_TEXT
								   	   OR r.LineP2B1No_TEXT = @Ac_LineP2No_TEXT 	 
									  )
								   OR @Ac_LineP2No_TEXT = @Lc_LinePNo_TEXT 	
								 )    
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
 
 END; --END OF R34UD_RETRIEVE_S2
 

GO
