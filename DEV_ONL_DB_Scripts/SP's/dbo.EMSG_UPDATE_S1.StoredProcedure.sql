/****** Object:  StoredProcedure [dbo].[EMSG_UPDATE_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[EMSG_UPDATE_S1] (
 @Ac_Error_CODE               CHAR(18),
 @As_DescriptionError_TEXT    VARCHAR(300),
 @An_TransactionEventSeq_NUMB NUMERIC(19, 0),
 @Ac_SignedOnWorker_ID        CHAR(30)
 )
AS
 /*                                                                                                               
  *     Procedure Name    : EMSG_UPDATE_S1                                                                        
  *     Description       : Updates Error Description with new Sequence Event Transaction for the given Error Code
  *     Developed By      : IMP Team                                                                              
  *     Developed On      : 03-AUG-2011                                                                           
  *     Modified By       :                                                                                       
  *     Modified On       :                                                                                       
  *     Version No        : 1                                                                                     
 */
 BEGIN
  DECLARE @Ln_RowsAffected_NUMB NUMERIC(10, 0);

  UPDATE EMSG_Y1
     SET DescriptionError_TEXT = @As_DescriptionError_TEXT,
         Update_DTTM = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
         WorkerUpdate_ID = @Ac_SignedOnWorker_ID,
         TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB
   WHERE Error_CODE = @Ac_Error_CODE;

  SELECT @Ln_RowsAffected_NUMB = @@ROWCOUNT;

  SELECT @Ln_RowsAffected_NUMB AS RowsAffected_NUMB;
 END; --End of EMSG_UPDATE_S1                                                                                      

GO
