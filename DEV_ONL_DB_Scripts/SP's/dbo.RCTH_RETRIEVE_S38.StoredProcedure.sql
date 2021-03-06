/****** Object:  StoredProcedure [dbo].[RCTH_RETRIEVE_S38]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[RCTH_RETRIEVE_S38]  (

     @Ad_Batch_DATE		    DATE,
     @An_Batch_NUMB         NUMERIC(4,0),
     @An_SeqReceipt_NUMB	NUMERIC(6,0),
     @Ac_SourceBatch_CODE	CHAR(3),
     @Ac_Exists_INDC        CHAR(1)  OUTPUT
   )  
AS

/*
 *  PROCEDURE NAME    : RCTH_RETRIEVE_S38
 *  DESCRIPTION       : It Return 'Y' if the receipt amount greater than Zero.
 *  DEVELOPED BY      : IMP Team
 *  DEVELOPED ON      : 02-NOV-2011
 *  MODIFIED BY       : 
 *  MODIFIED ON       : 
 *  VERSION NO        : 1
*/
   BEGIN

    DECLARE
         @Lc_Yes_INDC         CHAR(1)  = 'Y', 
		 @Lc_No_INDC          CHAR(1)  = 'N', 
         @Ld_High_DATE        DATE     = '12/31/9999', 
         @Li_Zero_NUMB        SMALLINT = 0;

 SET @Ac_Exists_INDC = @Lc_No_INDC;

      SELECT  @Ac_Exists_INDC = @Lc_Yes_INDC
        FROM RCTH_Y1 R
        WHERE R.Batch_DATE = @Ad_Batch_DATE 
         AND  R.SourceBatch_CODE = @Ac_SourceBatch_CODE 
         AND  R.Batch_NUMB = @An_Batch_NUMB 
         AND  R.SeqReceipt_NUMB = @An_SeqReceipt_NUMB 
         AND  R.EndValidity_DATE = @Ld_High_DATE 
         AND  R.Receipt_AMNT > @Li_Zero_NUMB;

                  
END; --END OF RCTH_RETRIEVE_S38


GO
