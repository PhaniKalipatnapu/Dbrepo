/****** Object:  StoredProcedure [dbo].[LWEL_RETRIEVE_S15]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[LWEL_RETRIEVE_S15](
 @An_CaseWelfare_IDNO NUMERIC(10),
 @An_Distribute_AMNT  NUMERIC(11, 2) OUTPUT
 )
AS
 /*                                                                                                                              
  *     PROCEDURE NAME    : LWEL_RETRIEVE_S15                                                                                     
  *     DESCRIPTION       :                                                                                                      
  *     DEVELOPED BY      : IMP TEAM                                                                                           
  *     DEVELOPED ON      : 11/28/2011                                                                                          
  *     MODIFIED BY       :                                                                                                      
  *     MODIFIED ON       :                                                                                                      
  *     VERSION NO        : 1                                                                                                    
 */
 BEGIN
  SET @An_Distribute_AMNT = NULL;

  DECLARE @Lc_Yes_TEXT           CHAR(1) = 'Y',
          @Ld_Highdate_DATE      DATE = '12/31/9999',
          @Ln_Zero_NUMB          NUMERIC(1) = 0,
          @Lc_ExcessOverUra_TEXT CHAR(1) = 'X';

  SELECT @An_Distribute_AMNT = ISNULL(SUM(CASE
                                           WHEN SUBSTRING(A.TypeDisburse_CODE, 2, 1) = @Lc_ExcessOverUra_TEXT
                                            THEN 0
                                           ELSE A.Distribute_AMNT
                                          END), @Ln_Zero_NUMB)
    FROM LWEL_Y1 A
   WHERE A.CaseWelfare_IDNO = @An_CaseWelfare_IDNO
     AND NOT EXISTS (SELECT 1 AS expr
                       FROM RCTH_Y1 Z
                      WHERE Z.Batch_DATE = A.Batch_DATE
                        AND Z.Batch_NUMB = A.Batch_NUMB
                        AND Z.SeqReceipt_NUMB = A.SeqReceipt_NUMB
                        AND Z.SourceBatch_CODE = A.SourceBatch_CODE
                        AND Z.BackOut_INDC = @Lc_Yes_TEXT
                        AND Z.EndValidity_DATE = @Ld_Highdate_DATE);
 END; -- End of LWEL_RETRIEVE_S15

GO
