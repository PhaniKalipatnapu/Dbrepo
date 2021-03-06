/****** Object:  StoredProcedure [dbo].[ACES_UPDATE_S1]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[ACES_UPDATE_S1](
 @An_Case_IDNO                NUMERIC(6),
 @Ad_BeginEstablishment_DATE  DATE,
 @Ac_StatusEstablish_CODE     CHAR(1),
 @Ac_ReasonStatus_CODE        CHAR(2),
 @Ac_SignedOnWorker_ID        CHAR(30),
 @An_TransactionEventSeq_NUMB NUMERIC(19)
 )
AS
 /*                                                                                                                                                               
 *     PROCEDURE NAME     : ACES_UPDATE_S1                                                                                                                         
 *     DESCRIPTION       : Updates the enddate validity to today's date for the given Case Id where enddate validity is highdate.                                
 *     DEVELOPED BY      : IMP Team                                                                                                                            
 *     DEVELOPED ON      : 02-NOV-2011                                                                                                                           
 *     MODIFIED BY       :                                                                                                                                       
 *     MODIFIED ON       :                                                                                                                                       
 *     VERSION NO        : 1                                                                                                                                     
 */
 BEGIN
  DECLARE @Ld_Systemdatetime_DTTM DATETIME = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
          @Ld_High_DATE           DATE = '12/31/9999',
          @Ln_RowsAffected_NUMB   NUMERIC(10) = 0;

  UPDATE ACES_Y1
     SET Case_IDNO = @An_Case_IDNO,
         BeginEstablishment_DATE = @Ad_BeginEstablishment_DATE,
         StatusEstablish_CODE = @Ac_StatusEstablish_CODE,
         ReasonStatus_CODE = @Ac_ReasonStatus_CODE,
         BeginValidity_DATE = @Ld_Systemdatetime_DTTM,
         WorkerUpdate_ID = @Ac_SignedOnWorker_ID,
         Update_DTTM = @Ld_Systemdatetime_DTTM,
         TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB
  OUTPUT DELETED.Case_IDNO,
         DELETED.BeginEstablishment_DATE,
         DELETED.StatusEstablish_CODE,
         DELETED.ReasonStatus_CODE,
         DELETED.BeginValidity_DATE,
         @Ld_Systemdatetime_DTTM,
         DELETED.WorkerUpdate_ID,
         DELETED.Update_DTTM,
         DELETED.TransactionEventSeq_NUMB
  INTO ACES_Y1
   WHERE Case_IDNO = @An_Case_IDNO
     AND EndValidity_DATE = @Ld_High_DATE;

  SET @Ln_RowsAffected_NUMB = @@ROWCOUNT;

  SELECT @Ln_RowsAffected_NUMB AS RowsAffected_NUMB;
 END; --End of ACES_UPDATE_S1                                                                                                                                                              


GO
