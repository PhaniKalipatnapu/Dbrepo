/****** Object:  StoredProcedure [dbo].[URCT_RETRIEVE_S3]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[URCT_RETRIEVE_S3]  (

     @Ad_Batch_DATE		            DATE,
     @An_Batch_NUMB                 NUMERIC(4,0),
     @Ac_SourceBatch_CODE	        CHAR(3),
     @An_SeqReceipt_NUMB	        NUMERIC(6,0),
     @An_EventGlobalBeginSeq_NUMB	NUMERIC(19,0) OUTPUT,
     @An_OtherParty_IDNO		    NUMERIC(9,0)  OUTPUT,
     @Ac_IdentificationStatus_CODE	CHAR(1)	      OUTPUT,
     @An_IvdAgency_IDNO		        NUMERIC(7,0)  OUTPUT,
     @Ad_StatusEscheat_DATE		    DATE	      OUTPUT,
     @Ac_StatusEscheat_CODE		    CHAR(2)	      OUTPUT
     )
AS

/*
 *  PROCEDURE NAME    : URCT_RETRIEVE_S3
 *  DESCRIPTION       : Retrieves UnidentifiedReceipts Details for the given Batch Date ,Batch Number, Sequence Receipt and SourceBatch Code
 *  DEVELOPED BY      : IMP Team
 *  DEVELOPED ON      : 10-NOV-2011
 *  MODIFIED BY       : 
 *  MODIFIED ON       : 
 *  VERSION NO        : 1
*/
   BEGIN

      SELECT @Ac_IdentificationStatus_CODE = NULL,
             @Ad_StatusEscheat_DATE = NULL,
             @An_EventGlobalBeginSeq_NUMB = NULL,
             @Ac_StatusEscheat_CODE = NULL,
             @An_IvdAgency_IDNO = NULL,
             @An_OtherParty_IDNO = NULL;

      DECLARE
         @Ld_High_DATE  DATE = '12/31/9999';
        
        SELECT @An_EventGlobalBeginSeq_NUMB = U.EventGlobalBeginSeq_NUMB, 
         @Ac_IdentificationStatus_CODE = U.IdentificationStatus_CODE, 
         @Ad_StatusEscheat_DATE = U.StatusEscheat_DATE, 
         @Ac_StatusEscheat_CODE = U.StatusEscheat_CODE, 
         @An_IvdAgency_IDNO = U.IvdAgency_IDNO, 
         @An_OtherParty_IDNO = U.OtherParty_IDNO
      FROM URCT_Y1 U
      WHERE U.Batch_DATE = @Ad_Batch_DATE 
       AND  U.Batch_NUMB = @An_Batch_NUMB 
       AND  U.SeqReceipt_NUMB = @An_SeqReceipt_NUMB 
       AND  U.SourceBatch_CODE = @Ac_SourceBatch_CODE 
       AND  U.EndValidity_DATE = @Ld_High_DATE;

                  
END; --END OF URCT_RETRIEVE_S3


GO
