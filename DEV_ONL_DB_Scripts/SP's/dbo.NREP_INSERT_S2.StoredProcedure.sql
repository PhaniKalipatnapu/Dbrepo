/****** Object:  StoredProcedure [dbo].[NREP_INSERT_S2]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[NREP_INSERT_S2] (
 @Ac_Notice_ID                   CHAR(8),
 @Ac_Recipient_CODE              CHAR(2),
 @An_TransactionEventSeq_NUMB    NUMERIC(19, 0),
 @An_TransactionEventSeqOld_NUMB NUMERIC(19, 0),
 @Ac_SignedOnWorker_ID           CHAR(30)
 )
AS
 /*                                                                                                                       
  *     PROCEDURE NAME    : NREP_INSERT_S2                                                                              
  *     DESCRIPTION       : Inserts the invalid notice details.
  *     DEVELOPED BY      : IMP TEAM                                                                                    
  *     DEVELOPED ON      : 02-AUG-2011                                                                                   
  *     MODIFIED BY       :                                                                                               
  *     MODIFIED ON       :                                                                                               
  *     VERSION NO        : 1                                                                                             
 */
 BEGIN
  INSERT NREP_Y1
         (Notice_ID,
          Recipient_CODE,
          Mask_INDC,
          TypeService_CODE,
          PrintMethod_CODE,
          Copies_QNTY,
          BeginValidity_DATE,
          EndValidity_DATE,
          WorkerUpdate_ID,
          TransactionEventSeq_NUMB,
          Update_DTTM)
  SELECT N.Notice_ID,
         N.Recipient_CODE,
         N.Mask_INDC,
         N.TypeService_CODE,
         N.PrintMethod_CODE,
         N.Copies_QNTY,
         CONVERT(DATE, DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME()),
         CONVERT(DATE, DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME()),
         @Ac_SignedOnWorker_ID,
         @An_TransactionEventSeq_NUMB,
         DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME()
    FROM NREP_Y1 N
   WHERE N.Notice_ID = @Ac_Notice_ID
     AND N.Recipient_CODE = @Ac_Recipient_CODE
     AND N.TransactionEventSeq_NUMB = @An_TransactionEventSeqOld_NUMB;
 END; --End of NREP_INSERT_S2                                                                                                                  


GO
