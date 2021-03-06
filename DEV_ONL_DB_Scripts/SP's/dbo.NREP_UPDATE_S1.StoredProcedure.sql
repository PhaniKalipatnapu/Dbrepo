/****** Object:  StoredProcedure [dbo].[NREP_UPDATE_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[NREP_UPDATE_S1] (
 @Ac_Notice_ID                CHAR(8),
 @Ac_Recipient_CODE           CHAR(2),
 @Ac_TypeService_CODE         CHAR(2),
 @An_TransactionEventSeq_NUMB NUMERIC(19, 0)
 )
AS
 /*                                                                                                                                                                                                                                                                     
  *     PROCEDURE NAME    : NREP_UPDATE_S1                                                                                                                                                                                                                               
  *     DESCRIPTION       : Updates the End Validity Date for a respective Notice,Transaction sequence and Recipient Code.                                                                                                                                                   
  *     DEVELOPED BY      : IMP Team                                                                                                                                                                                                                                  
  *     DEVELOPED ON      : 10-AUG-2011                                                                                                                                                                                                                                 
  *     MODIFIED BY       :                                                                                                                                                                                                                                             
  *     MODIFIED ON       :                                                                                                                                                                                                                                             
  *     VERSION NO        : 1                                                                                                                                                                                                                                           
 */
 BEGIN
  DECLARE @Ln_RowsAffected_NUMB NUMERIC(10);

  UPDATE NREP_Y1
     SET EndValidity_DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME()
   WHERE Notice_ID = @Ac_Notice_ID
     AND Recipient_CODE = @Ac_Recipient_CODE
     AND TypeService_CODE = @Ac_TypeService_CODE
     AND TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB;

  SET @Ln_RowsAffected_NUMB = @@ROWCOUNT;

  SELECT @Ln_RowsAffected_NUMB AS RowsAffected_NUMB;
 END; -- End Of NREP_UPDATE_S1                                                                                                                                                                                                                                           

GO
