/****** Object:  StoredProcedure [dbo].[ACES_INSERT_S1]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[ACES_INSERT_S1](
 @An_Case_IDNO                NUMERIC(6),
 @Ad_BeginEstablishment_DATE  DATE,
 @Ac_StatusEstablish_CODE     CHAR(1),
 @Ac_ReasonStatus_CODE        CHAR(2),
 @Ac_SignedOnWorker_ID        CHAR(30),
 @An_TransactionEventSeq_NUMB NUMERIC(19)
 )
AS
 /*                                                                                                                                                                                                                                                
  *     PROCEDURE NAME    : ACES_INSERT_S1                                                                                                                                                                                                          
  *     DESCRIPTION       : Inserts the date on which the case has been moved to Establishment for the given status of the Case in Establishment, Case Id, Worker , Reason for updating the current record with the new Transaction event sequence.
  *     DEVELOPED BY      : IMP Team                                                                                                                                                                                                             
  *     DEVELOPED ON      : 11/11/2011                                                                                                                                                                                                       
  *     MODIFIED BY       :                                                                                                                                                                                                                        
  *     MODIFIED ON       :                                                                                                                                                                                                                        
  *     VERSION NO        : 1                                                                                                                                                                                                                      
  */
 DECLARE @Ld_Systemdatetime_DTTM DATETIME2 = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
         @Ld_High_DATE           DATE = '12/31/9999';

 BEGIN
  INSERT ACES_Y1
         (Case_IDNO,
          BeginEstablishment_DATE,
          StatusEstablish_CODE,
          ReasonStatus_CODE,
          BeginValidity_DATE,
          EndValidity_DATE,
          WorkerUpdate_ID,
          Update_DTTM,
          TransactionEventSeq_NUMB)
  VALUES ( @An_Case_IDNO,
           @Ad_BeginEstablishment_DATE,
           @Ac_StatusEstablish_CODE,
           @Ac_ReasonStatus_CODE,
           @Ld_Systemdatetime_DTTM,
           @Ld_High_DATE,
           @Ac_SignedOnWorker_ID,
           @Ld_Systemdatetime_DTTM,
           @An_TransactionEventSeq_NUMB);
 END; --End of ACES_INSERT_S1


GO
