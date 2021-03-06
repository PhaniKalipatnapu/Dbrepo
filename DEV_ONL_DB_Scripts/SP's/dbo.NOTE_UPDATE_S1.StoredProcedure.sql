/****** Object:  StoredProcedure [dbo].[NOTE_UPDATE_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[NOTE_UPDATE_S1] (
 @An_Case_IDNO                NUMERIC(6, 0),
 @An_Topic_IDNO               NUMERIC(10, 0),
 @An_TransactionEventSeq_NUMB NUMERIC(19, 0),
 @Ac_SignedOnWorker_ID        CHAR(30)
 )
AS
 /*    
  *     PROCEDURE NAME    : NOTE_UPDATE_S1  
  *     DESCRIPTION       : Update End Validity Date and Worker ID who created/modified this record for a Case and Transaction sequence.    
  *     DEVELOPED BY      : IMP Team  
  *     DEVELOPED ON      : 09-AUG-2011    
  *     MODIFIED BY       :     
  *     MODIFIED ON       :     
  *     VERSION NO        : 1    
 */
 BEGIN
  DECLARE @Ld_Systemdate_DTTM   DATETIME2(0) = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
          @Ld_High_DATE         DATE = '12/31/9999',
          @Li_One_NUMB          SMALLINT = 1,
          @Ln_RowsAffected_NUMB NUMERIC(10);

  UPDATE NOTE_Y1
     SET EndValidity_DATE = @Ld_Systemdate_DTTM,
         WorkerUpdate_ID = @Ac_SignedOnWorker_ID
   WHERE Case_IDNO = @An_Case_IDNO
     AND Topic_IDNO = @An_Topic_IDNO
     AND Post_IDNO = @Li_One_NUMB
     AND EndValidity_DATE = @Ld_High_DATE
     AND TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB;

  SET @Ln_RowsAffected_NUMB = @@ROWCOUNT;

  SELECT @Ln_RowsAffected_NUMB AS RowsAffected_NUMB;
 END; -- END OF NOTE_UPDATE_S1  


GO
