/****** Object:  StoredProcedure [dbo].[DHLD_RETRIEVE_S31]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DHLD_RETRIEVE_S31](  
 @An_EventGlobalBeginSeq_NUMB   NUMERIC(19),
 @Ad_Batch_DATE                 DATE		= NULL,
 @Ac_SourceBatch_CODE           CHAR(3)		= NULL,
 @An_Batch_NUMB                 NUMERIC(4)  = NULL,
 @An_SeqReceipt_NUMB            NUMERIC(6)  = NULL
 )
AS
 /*
  *     PROCEDURE NAME    : DHLD_RETRIEVE_S31
  *    DESCRIPTION       :  This procedure is used to populate TANF Disbursement Hold Details for the Case
                            ID entered for inquiry. Details include the type of hold, the disbursement
                            release date, the amount of the disbursement and a description of the obligation
                            and balance to which the receipt was applied.
  *     DEVELOPED BY     : IMP Team
  *     DEVELOPED ON     : 12/09/2011
  *     MODIFIED BY      : 
  *     MODIFIED ON      : 
  *     VERSION NO       : 1
  */
BEGIN
 DECLARE  @Lc_IrsTypeHold_CODE CHAR(1) = 'I';
   
 SELECT l.TypeHold_CODE , 
        l.ReasonStatus_CODE ,
        l.Case_IDNO , 
        l.Transaction_DATE , 
        l.Transaction_AMNT AS Transaction_AMNT, 
        CASE l.TypeHold_CODE
           WHEN @Lc_IrsTypeHold_CODE THEN  DATEADD(m, 6, l.Transaction_DATE)
           ELSE NULL
        END AS DisbursementHoldRelease_DATE, 
        l.TypeDisburse_CODE , 
        l.Batch_DATE,
        l.SourceBatch_CODE,
        l.Batch_NUMB,
        l.SeqReceipt_NUMB,
        l.Disburse_DATE AS Disburse_DATE
   FROM DHLD_Y1 l
   WHERE l.EventGlobalBeginSeq_NUMB = @An_EventGlobalBeginSeq_NUMB 
     AND l.Batch_DATE = ISNULL(@Ad_Batch_DATE, l.Batch_DATE) 
     AND l.SourceBatch_CODE = ISNULL(@Ac_SourceBatch_CODE, l.SourceBatch_CODE) 
     AND l.Batch_NUMB = ISNULL(@An_Batch_NUMB, l.Batch_NUMB) 
     AND l.SeqReceipt_NUMB = ISNULL(@An_SeqReceipt_NUMB, l.SeqReceipt_NUMB);
            
END;--End Of Procedure DHLD_RETRIEVE_S31


GO
