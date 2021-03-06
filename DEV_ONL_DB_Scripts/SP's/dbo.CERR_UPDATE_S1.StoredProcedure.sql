/****** Object:  StoredProcedure [dbo].[CERR_UPDATE_S1]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CERR_UPDATE_S1] (
 @An_TransHeader_IDNO  NUMERIC(12, 0),
 @Ad_Transaction_DATE  DATE,
 @An_SeqError_IDNO     NUMERIC(6, 0),
 @Ac_SignedOnWorker_ID CHAR(30)
 )
AS
 /*    
  *     PROCEDURE NAME    : CERR_UPDATE_S1    
  *     DESCRIPTION       : Update Action Date, Worker Update Idno, and Date and Time the record was modified / inserted for a Transaction Header Idno, Transaction Date, and Error Sequence number.    
  *     DEVELOPED BY      : IMP Team    
  *     DEVELOPED ON      : 01-SEP-2011    
  *     MODIFIED BY       :     
  *     MODIFIED ON       :     
  *     VERSION NO        : 1    
  */
 BEGIN
  DECLARE @Ld_High_DATE         DATE = '12/31/9999',
          @Ld_Systemdate_DTTM   DATETIME2 = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
          @Ln_RowsAffected_NUMB NUMERIC(10);

  UPDATE CERR_Y1
     SET ActionTaken_DATE = @Ld_Systemdate_DTTM,
         WorkerUpdate_ID = @Ac_SignedOnWorker_ID,
         Update_DTTM = @Ld_Systemdate_DTTM
   WHERE TransHeader_IDNO = @An_TransHeader_IDNO
     AND Transaction_DATE = @Ad_Transaction_DATE
     AND SeqError_IDNO = @An_SeqError_IDNO
     AND ActionTaken_DATE = @Ld_High_DATE;

  SET @Ln_RowsAffected_NUMB = @@ROWCOUNT;

  SELECT @Ln_RowsAffected_NUMB AS RowsAffected_NUMB;
 END; --End of CERR_UPDATE_S1

GO
