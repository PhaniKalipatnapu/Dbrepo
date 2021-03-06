/****** Object:  StoredProcedure [dbo].[DCRS_RETRIEVE_S11]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE 
	[dbo].[DCRS_RETRIEVE_S11]  
AS

/*
*     PROCEDURE NAME    : DCRS_RETRIEVE_S11
 *     DESCRIPTION       : Retrieves checkrecipient ID whose EFT status is cancelled/Pre-note rejected, CP who has not responded 20 days.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 14-SEP-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/
   BEGIN

      DECLARE
         @Ld_High_DATE					DATE = '12/31/9999',
         @Lc_StatusNoticeSent_CODE		CHAR(1)='N',
         @Lc_StatusActive_CODE			CHAR(1)='A',
         @Lc_StatusExempt_CODE			CHAR(1)='E',
         @Lc_EftStatusPrenoteP_CODE     CHAR(2) ='PP',
		 @Lc_EftStatusPrenoteG_CODE     CHAR(2) ='PG',
		 @Lc_EftStatusActive_CODE		CHAR(2) ='AC',
		 @Lc_EftStatusCancel_CODE		CHAR(2) ='CA',
		 @Lc_EftStatusReject_CODE		CHAR(2) ='PR',
		 @Ld_Current_DATE	            DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
        
      SELECT d.CheckRecipient_ID, d.Status_CODE
      FROM DCRS_Y1   d 
      WHERE d.CheckRecipient_ID NOT IN (
											SELECT e.CheckRecipient_ID
											FROM EFTR_Y1 e
											WHERE StatusEft_CODE IN (@Lc_EftStatusActive_CODE,@Lc_EftStatusPrenoteP_CODE,@Lc_EftStatusPrenoteG_CODE))
											AND d.Status_CODE = @Lc_StatusNoticeSent_CODE
											AND @Ld_Current_DATE > DATEADD(D,20,d.Status_DATE)  
		AND d.EndValidity_DATE = @Ld_High_DATE
	  UNION
       SELECT e.CheckRecipient_ID, e.StatusEft_CODE
      FROM DCRS_Y1   d JOIN EFTR_Y1 e
      ON d.CheckRecipient_ID = e.CheckRecipient_ID
      WHERE e.StatusEft_CODE IN(@Lc_EftStatusCancel_CODE,@Lc_EftStatusReject_CODE)
      AND d.Status_CODE NOT IN (@Lc_StatusActive_CODE,@Lc_StatusExempt_CODE)
      AND d.EndValidity_DATE = @Ld_High_DATE
      AND e.EndValidity_DATE = @Ld_High_DATE;
                  
END; -- End of DCRS_RETRIEVE_S11


GO
