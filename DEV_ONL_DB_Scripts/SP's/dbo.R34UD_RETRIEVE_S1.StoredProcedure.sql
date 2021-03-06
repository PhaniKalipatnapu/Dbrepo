/****** Object:  StoredProcedure [dbo].[R34UD_RETRIEVE_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

 CREATE PROCEDURE [dbo].[R34UD_RETRIEVE_S1](
			@Ad_BeginQtr_DATE				DATE,
			@Ad_EndQtr_DATE					DATE,
			@Ac_LineNo_TEXT					CHAR (3),
			@Ad_Batch_DATE					DATE,
			@An_Batch_NUMB					NUMERIC (4,0),
			@An_SeqReceipt_NUMB				NUMERIC (6,0) ,
			@Ac_SourceBatch_CODE			CHAR(3),
			@Ai_RowFrom_NUMB				INT  = 1,
			@Ai_RowTo_NUMB					INT  = 10
			 )			
AS  
  
/*  
 *     PROCEDURE NAME    : R34UD_RETRIEVE_S1   
 *     DESCRIPTION       : This Procedure is used to show the supporting receipt level details  
 *						   for the selected LineNo7aa or LineNo7ac line in the report from R34UD_Y1 table.
 *     DEVELOPED BY      : IMP Team  
 *     DEVELOPED ON      : 15-NOV-2011  
 *     MODIFIED BY       :   
 *     MODIFIED ON       :   
 *     VERSION NO        : 1  
 */  
 
 BEGIN  
 
	   SELECT b.Receipt_NUMB, 
			 b.Case_IDNO, 
			 b.PayorMCI_IDNO, 
			 b.Receipt_DATE, 
			 b.IvaCase_ID, 
			 b.Line_AMNT,
			 b.RowCount_NUMB
		FROM (
				SELECT a.Receipt_NUMB, 
					   a.Case_IDNO, 
					   a.PayorMCI_IDNO, 
					   a.Receipt_DATE, 
					   a.IvaCase_ID,
					   a.Line_AMNT, 
					   a.RowCount_NUMB, 
					   a.Row_NUMB
				  FROM (
						  SELECT ' ' AS Receipt_NUMB,
								 r.Case_IDNO, 
								 r.PayorMCI_IDNO, 
								 r.Receipt_DATE, 
								 r.IvaCase_ID,  
								 r.Trans_AMNT AS Line_AMNT,
								 COUNT(1) OVER() RowCount_NUMB,
								 ROW_NUMBER() OVER (ORDER BY Batch_DATE, Batch_NUMB, SeqReceipt_NUMB,
															 SourceBatch_CODE ) AS Row_NUMB 
							FROM R34UD_Y1 r   
						   WHERE r.LineP1No_TEXT = @Ac_LineNo_TEXT 
							 AND r.BeginQtr_DATE = @Ad_BeginQtr_DATE 
							 AND r.EndQtr_DATE   =  @Ad_EndQtr_DATE
							 AND (   (   @Ad_Batch_DATE IS NOT NULL
									  AND r.Batch_DATE = @Ad_Batch_DATE
									  AND r.Batch_NUMB = @An_Batch_NUMB
									  AND r.SeqReceipt_NUMB = @An_SeqReceipt_NUMB
									  AND r.SourceBatch_CODE = @Ac_SourceBatch_CODE
									 )
								  OR ( @Ad_Batch_DATE IS NULL)
								 )
						) a 
				 WHERE a.Row_NUMB <= @Ai_RowTo_NUMB
			 ) b
	   WHERE b.Row_NUMB >= @Ai_RowFrom_NUMB ;
	     
 END; --END OF R34UD_RETRIEVE_S1
 

GO
