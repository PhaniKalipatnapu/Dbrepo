/****** Object:  StoredProcedure [dbo].[POFL_RETRIEVE_S41]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[POFL_RETRIEVE_S41](
  @An_Case_IDNO           NUMERIC(6),
  @An_EventGlobalSeq_NUMB NUMERIC(19),
  @Ac_CheckRecipient_CODE CHAR(1),
  @Ac_CheckRecipient_ID   CHAR(10),
  @Ad_Batch_DATE          DATE,
  @Ac_SourceBatch_CODE    CHAR(3),
  @An_Batch_NUMB          NUMERIC(4),
  @An_SeqReceipt_NUMB     NUMERIC(6)
  )
AS
 /*
  *     PROCEDURE NAME    : POFL_RETRIEVE_S41
  *     DESCRIPTION       : This Procedure is used to populate data for 'Reverse And Repost' pop up.
							This Pop up will show reversals and all associated events which occur as a result
							of the reversal transaction, as a single event identified as 'Reverse and Repost'.
							Balance will display the actual balance because of reversing all the receipts as
						    part of this bulk reversal.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 12/09/2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
  */
  BEGIN
 
    DECLARE
      @Li_One_NUMB					  INT	  = 1,
      @Li_Two_NUMB					  INT     = 2,
      @Li_Three_NUMB				  INT	  = 3,
      @Li_Four_NUMB					  INT	  = 4,
      @Li_Five_NUMB					  INT	  = 5,
      @Li_Zero_NUMB                   SMALLINT= 0,
      @Lc_TransactionAppe_CODE        CHAR(4) = 'APPE',
      @Lc_TransactionDcrc_CODE        CHAR(4) = 'DCRC',
      @Lc_TransactionInpe_CODE        CHAR(4) = 'INPE',
      @Lc_TransactionInrc_CODE        CHAR(4) = 'INRC',
      @Lc_TransactionMult_CODE        CHAR(4) = 'MULT',
      @Lc_TransactionRdpe_CODE        CHAR(4) = 'RDPE',
      @Lc_TransactionRdrc_CODE        CHAR(4) = 'RDRC',
      @Lc_TransactionRepe_CODE        CHAR(4) = 'REPE';
      
    SELECT l.Transaction_DATE,
           CASE A.Row_NUMB 
            WHEN 1 THEN 
            l.Transaction_CODE
            WHEN 2 THEN 
            @Lc_TransactionRdpe_CODE
            WHEN 3 THEN 
            @Lc_TransactionInpe_CODE
            WHEN 4 THEN 
            @Lc_TransactionRdrc_CODE
            WHEN 5 THEN 
            @Lc_TransactionInrc_CODE
            END AS Transaction_CODE,
           l.Case_IDNO ,
           l.Batch_DATE, 
           l.SourceBatch_CODE, 
           l.Batch_NUMB, 
           l.SeqReceipt_NUMB,
           l.Reason_CODE ,
           g.Worker_ID ,
           CASE WHEN A.Row_NUMB = 1
              THEN
              CASE
               WHEN l.Transaction_CODE IN (@Lc_TransactionRdpe_CODE, @Lc_TransactionInpe_CODE, @Lc_TransactionRepe_CODE)
               THEN l.PendOffset_AMNT
               WHEN l.Transaction_CODE IN (@Lc_TransactionRdrc_CODE, @Lc_TransactionInrc_CODE, @Lc_TransactionAppe_CODE, @Lc_TransactionDcrc_CODE)
               THEN l.AssessOverpay_AMNT
              END
            WHEN A.Row_NUMB IN (2,3)
            THEN l.PendOffset_AMNT
            WHEN A.Row_NUMB IN (4,5)
            THEN l.AssessOverpay_AMNT
           END AS Transaction_AMNT,
           (SELECT UN.DescriptionNote_TEXT
              FROM UNOT_Y1 UN
             WHERE UN.EventGlobalSeq_NUMB = @An_EventGlobalSeq_NUMB) AS Notes_TEXT,
           l.CheckRecipient_ID,
           l.CheckRecipient_CODE,
           l.TypeRecoupment_CODE 
     FROM  POFL_Y1 l  
       LEFT OUTER  JOIN ELRP_Y1 e
            ON l.EventGlobalSeq_NUMB =e.EventGlobalBackOutSeq_NUMB 
       LEFT OUTER  JOIN GLEV_Y1 g    
            ON E.EventGlobalRrepSeq_NUMB = g.EventGlobalSeq_NUMB  
       CROSS JOIN dbo.BATCH_COMMON$SF_GET_NUMBERS(1,5) a  
     WHERE ((@Ac_CheckRecipient_ID IS NOT NULL 
             AND l.CheckRecipient_ID = @Ac_CheckRecipient_ID
             AND l.CheckRecipient_CODE = @Ac_CheckRecipient_CODE)
             OR (@Ad_Batch_DATE  IS NOT NULL 
                 AND l.Batch_DATE = @Ad_Batch_DATE
                 AND l.SourceBatch_CODE = @Ac_SourceBatch_CODE
                 AND l.Batch_NUMB = @An_Batch_NUMB
                 AND l.SeqReceipt_NUMB = @An_SeqReceipt_NUMB))
       AND (l.EventGlobalSeq_NUMB = @An_EventGlobalSeq_NUMB
            OR  E.EventGlobalRrepSeq_NUMB = @An_EventGlobalSeq_NUMB)
       AND l.Case_IDNO = @An_Case_IDNO
       AND ((A.Row_NUMB = @Li_One_NUMB
             AND l.Transaction_CODE <> @Lc_TransactionMult_CODE)
             OR (A.Row_NUMB = @Li_Two_NUMB
                 AND l.Transaction_CODE = @Lc_TransactionMult_CODE
                 AND l.PendOffset_AMNT < @Li_Zero_NUMB)
             OR (A.Row_NUMB = @Li_Three_NUMB
                 AND l.Transaction_CODE = @Lc_TransactionMult_CODE
                 AND l.PendOffset_AMNT > @Li_Zero_NUMB )
             OR (A.Row_NUMB = @Li_Four_NUMB
                 AND l.Transaction_CODE = @Lc_TransactionMult_CODE
                 AND l.AssessOverpay_AMNT < @Li_Zero_NUMB)
             OR (A.Row_NUMB = @Li_Five_NUMB
                 AND l.Transaction_CODE = @Lc_TransactionMult_CODE
                 AND l.AssessOverpay_AMNT > @Li_Zero_NUMB))
     ORDER BY l.Transaction_DATE DESC;
     
  END; --End Of Procedure POFL_RETRIEVE_S41


GO
