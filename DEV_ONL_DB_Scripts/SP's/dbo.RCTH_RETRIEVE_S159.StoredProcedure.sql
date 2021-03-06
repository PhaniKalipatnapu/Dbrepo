/****** Object:  StoredProcedure [dbo].[RCTH_RETRIEVE_S159]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[RCTH_RETRIEVE_S159](
@An_Case_IDNO             NUMERIC(6, 0),
@An_DistributionHold_AMNT NUMERIC(11, 2) OUTPUT
)
AS
/*                                                                                     
  *     PROCEDURE NAME    : RCTH_RETRIEVE_S159                                             
  *     DESCRIPTION       : Procedure To Retrieve DistributionHold Amount from RCTH_Y1                                                            
  *     DEVELOPED BY      : IMP TEAM                                                
  *     DEVELOPED ON      : 23/02/2012                                          
  *     MODIFIED BY       :                                                             
  *     MODIFIED ON       :                                                             
  *     VERSION NO        : 1                                                           
 */
BEGIN
  SET @An_DistributionHold_AMNT = NULL;

  DECLARE @Li_One_NUMB               INT = 1,
          @Li_Zero_NUMB              SMALLINT = 0,
          @Lc_StatusReceiptHeld_CODE CHAR(1) = 'H',
          @Lc_BackOut_INDC           CHAR(1) = 'Y',
          @Lc_TypePostingPayor_CODE  CHAR(1) = 'P',
          @Lc_TypePostingCase_CODE   CHAR(1) = 'C',
          @Lc_CaseRelationship_CODE  CHAR(1) = 'A',
          @Ld_High_DATE              DATE = '12/31/9999';
          
   WITH Cmem_CTE 
   AS (
            SELECT CM.MemberMci_IDNO , CM.Case_IDNO
                                        FROM CMEM_Y1 CM
                                       WHERE CM.Case_IDNO = @An_Case_IDNO
                                         AND CM.CaseRelationship_CODE = @Lc_CaseRelationship_CODE
       )
  SELECT @An_DistributionHold_AMNT = ISNULL(SUM(RH.ToDistribute_AMNT), @Li_Zero_NUMB)
    FROM RCTH_Y1 RH ,Cmem_CTE CM
   WHERE RH.StatusReceipt_CODE = @Lc_StatusReceiptHeld_CODE
     AND RH.EndValidity_DATE = @Ld_High_DATE
     AND NOT EXISTS (SELECT TOP 1 @Li_One_NUMB
                       FROM RCTH_Y1 RC
                      WHERE RH.Batch_DATE = RC.Batch_DATE
                        AND RH.SourceBatch_CODE = RC.SourceBatch_CODE
                        AND RH.Batch_NUMB = RC.Batch_NUMB
                        AND RH.SeqReceipt_NUMB = RC.SeqReceipt_NUMB
                        AND RC.BackOut_INDC = @Lc_BackOut_INDC
                        AND RC.EndValidity_DATE = @Ld_High_DATE)
     AND ( ( RH.TypePosting_CODE = @Lc_TypePostingCase_CODE
              AND  RH.Case_IDNO = CM.Case_IDNO
            )
          OR ( RH.TypePosting_CODE = @Lc_TypePostingPayor_CODE
              AND RH.PayorMCI_IDNO = CM.MemberMci_IDNO
           )
          ) ;
END; ----End Of Procedure RCTH_RETRIEVE_S159


GO
