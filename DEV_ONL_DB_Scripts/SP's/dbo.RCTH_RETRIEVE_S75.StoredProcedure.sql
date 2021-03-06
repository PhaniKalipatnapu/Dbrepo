/****** Object:  StoredProcedure [dbo].[RCTH_RETRIEVE_S75]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[RCTH_RETRIEVE_S75] (
     @Ad_Batch_DATE                    DATE,
     @An_Batch_NUMB                    NUMERIC(4,0),
     @Ac_SourceBatch_CODE              CHAR(3),
     @An_SeqReceipt_NUMB               NUMERIC(6,0),
     @Ac_ReasonBackOut_CODE            CHAR(2)		OUTPUT
)
AS

/*
 *     PROCEDURE NAME    : RCTH_RETRIEVE_S75
 *     DESCRIPTION       : Procedure to get the reason code of the original receipt
 *     DEVELOPED BY      : IMP TEAM
 *     DEVELOPED ON      : 02-SEP-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
 */
   BEGIN

      SET @Ac_ReasonBackOut_CODE = NULL;

      DECLARE
         @Lc_Yes_INDC  CHAR(1) = 'Y', 
         @Ld_High_DATE DATE    = '12/31/9999';
        
        SELECT @Ac_ReasonBackOut_CODE = r.ReasonBackOut_CODE
          FROM RCTH_Y1 r
         WHERE r.Batch_DATE			  = @Ad_Batch_DATE 
           AND r.Batch_NUMB			  = @An_Batch_NUMB 
           AND r.SeqReceipt_NUMB	  = @An_SeqReceipt_NUMB 
           AND r.SourceBatch_CODE	  = @Ac_SourceBatch_CODE 
           AND r.BackOut_INDC		  = @Lc_Yes_INDC 
           AND r.EndValidity_DATE	  = @Ld_High_DATE;
           
END; --End Of Procedure RCTH_RETRIEVE_S75


GO
