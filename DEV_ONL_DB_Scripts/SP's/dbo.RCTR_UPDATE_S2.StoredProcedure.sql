/****** Object:  StoredProcedure [dbo].[RCTR_UPDATE_S2]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[RCTR_UPDATE_S2] 
(
     @Ad_BatchOrig_DATE						 DATE,
     @Ac_SourceBatchOrig_CODE				 CHAR(3),
     @An_BatchOrig_NUMB						 NUMERIC(4,0),
     @An_SeqReceiptOrig_NUMB				 NUMERIC(6,0),
     @Ac_StatusMatch_CODE					 CHAR(1)
 )
AS

/*
 *     PROCEDURE NAME    : RCTR_UPDATE_S2
 *     DESCRIPTION       : Procedure To Update StatusMatch_CODE
 *     DEVELOPED BY      : IMP TEAM
 *     DEVELOPED ON      : 19-OCT-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/

   BEGIN
      DECLARE
			@Ld_High_DATE	 DATE  = '12/31/9999';
            
   UPDATE RCTR_Y1
      SET StatusMatch_CODE		= @Ac_StatusMatch_CODE 
    WHERE BatchOrig_DATE		= @Ad_BatchOrig_DATE 
      AND SourceBatchOrig_CODE	= @Ac_SourceBatchOrig_CODE 
      AND BatchOrig_NUMB		= @An_BatchOrig_NUMB 
	  AND SeqReceiptOrig_NUMB	= @An_SeqReceiptOrig_NUMB 
      AND EndValidity_DATE		= @Ld_High_DATE;
      
      DECLARE 
		  @Ln_RowsAffected_NUMB NUMERIC(10);
      
      SET @Ln_RowsAffected_NUMB = @@ROWCOUNT;
   SELECT @Ln_RowsAffected_NUMB;
      
END; --End Of Procedure RCTR_UPDATE_S2


GO
