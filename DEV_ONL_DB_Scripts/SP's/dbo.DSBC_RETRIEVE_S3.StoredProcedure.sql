/****** Object:  StoredProcedure [dbo].[DSBC_RETRIEVE_S3]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DSBC_RETRIEVE_S3]  

     @Ad_Disburse_DATE                     DATETIME2(0),
     @An_DisburseSeq_NUMB                    NUMERIC(4,0),
     @Ac_CheckRecipient_CODE                      CHAR(1),
     @Ac_CheckRecipient_ID                      CHAR(10)           
AS

/*
  *     PROCEDURE NAME    : DSBC_RETRIEVE_S3
  *     DESCRIPTION       : 
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 14-FEB-2012
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
   BEGIN
      SELECT DS.CheckRecipientOrig_ID AS CheckRecipientOrig_ID,
        DS.CheckRecipientOrig_CODE AS CheckRecipientOrig_CODE,
        DS.DisburseOrig_DATE AS DisburseOrig_DATE,
        DS.DisburseOrigSeq_NUMB AS DisburseOrigSeq_NUMB
      FROM DSBC_Y1 DS
      WHERE 
         DS.CheckRecipient_ID = @Ac_CheckRecipient_ID AND 
         DS.CheckRecipient_CODE = @Ac_CheckRecipient_CODE AND 
         DS.Disburse_DATE = @Ad_Disburse_DATE AND 
         DS.DisburseSeq_NUMB = @An_DisburseSeq_NUMB;

                  
END


GO
