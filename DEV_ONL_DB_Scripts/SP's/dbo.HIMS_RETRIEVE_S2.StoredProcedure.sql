/****** Object:  StoredProcedure [dbo].[HIMS_RETRIEVE_S2]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[HIMS_RETRIEVE_S2]  
(
     @Ac_SourceReceipt_CODE		 	CHAR(2),
     @An_TransactionEventSeq_NUMB	NUMERIC(19,0)  OUTPUT,     
     @Ac_UdcCaseHold_CODE		 	CHAR(4)	 	   OUTPUT,
     @Ac_TypePosting_CODE		 	CHAR(1)		   OUTPUT
)
AS

/*
*     PROCEDURE NAME    : HIMS_RETRIEVE_S2
*     DESCRIPTION       : Retrieves Hold Instruction Details for the given Source Receipt and High Date
*     DEVELOPED BY      : IMP Team
*     DEVELOPED ON      : 02-AUG-2011
*     MODIFIED BY       : 
*     MODIFIED ON       : 
*     VERSION NO        : 1
*/
BEGIN

      SELECT 
       @An_TransactionEventSeq_NUMB = NULL,
       @Ac_UdcCaseHold_CODE = NULL,
       @Ac_TypePosting_CODE = NULL;

      DECLARE
         @Ld_High_DATE DATE = '12/31/9999';
        
      SELECT @An_TransactionEventSeq_NUMB = H.TransactionEventSeq_NUMB,
      	@Ac_UdcCaseHold_CODE = H.UdcCaseHold_CODE,
      	@Ac_TypePosting_CODE = H.TypePosting_CODE
      FROM HIMS_Y1 H
      WHERE H.SourceReceipt_CODE = @Ac_SourceReceipt_CODE 
	  AND H.EndValidity_DATE = @Ld_High_DATE;

                  
END;--End of HIMS_RETRIEVE_S2


GO
