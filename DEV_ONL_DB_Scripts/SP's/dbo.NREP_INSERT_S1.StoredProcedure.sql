/****** Object:  StoredProcedure [dbo].[NREP_INSERT_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[NREP_INSERT_S1] (
 @Ac_Notice_ID                CHAR(8),
 @Ac_Recipient_CODE           CHAR(2),
 @Ac_TypeService_CODE         CHAR(2),
 @An_TransactionEventSeq_NUMB NUMERIC(19, 0),
 @Ac_PrintMethod_CODE         CHAR(2),
 @An_Copies_QNTY              NUMERIC(5, 0),
 @Ac_SignedOnWorker_ID        CHAR(30)
 )
AS
 /*                                                                              
  *     PROCEDURE NAME    : NREP_INSERT_S1                                        
  *     DESCRIPTION       : Insert details into Notice Recipient Reference table.
  *     DEVELOPED BY      : IMP Team                                           
  *     DEVELOPED ON      : 26-AUG-2011                                          
  *     MODIFIED BY       :                                                      
  *     MODIFIED ON       :                                                      
  *     VERSION NO        : 1                                                    
 */
 BEGIN
  DECLARE @Lc_Space_TEXT CHAR(1) = ' ',
          @Ld_High_DATE  DATE = '12/31/9999';

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
  VALUES ( @Ac_Notice_ID,
           @Ac_Recipient_CODE,
           @Lc_Space_TEXT,
           @Ac_TypeService_CODE,
           @Ac_PrintMethod_CODE,
           @An_Copies_QNTY,
           dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
           @Ld_High_DATE,
           @Ac_SignedOnWorker_ID,
           @An_TransactionEventSeq_NUMB,
           dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME() );
 END; -- End Of NREP_INSERT_S1                                                                           

GO
