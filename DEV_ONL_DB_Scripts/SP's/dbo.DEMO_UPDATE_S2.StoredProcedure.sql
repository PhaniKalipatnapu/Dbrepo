/****** Object:  StoredProcedure [dbo].[DEMO_UPDATE_S2]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DEMO_UPDATE_S2] (
 @An_MemberMci_IDNO           NUMERIC(10),
 @Ac_Restricted_INDC          CHAR(1),
 @Ac_SignedOnWorker_ID        CHAR(30),
 @An_TransactionEventSeq_NUMB NUMERIC(19)
 )
AS
 /*    
  *     PROCEDURE NAME    : DEMO_UPDATE_S2
  *     DESCRIPTION       : Update Member Demographics details for High Profile Member Idno.
  *     DEVELOPED BY      : IMP Team    
  *     DEVELOPED ON      : 17-AUG-2011
  *     MODIFIED BY       :     
  *     MODIFIED ON       :     
  *     VERSION NO        : 1    
 */
 BEGIN
  DECLARE @Ld_Systemdate_DTTM DATETIME2 = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
		  @Ld_Systemdate_DATE   DATE = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
          @Ln_RowsAffected_NUMB NUMERIC(10);

  UPDATE DEMO_Y1
     SET Restricted_INDC = @Ac_Restricted_INDC,
         WorkerUpdate_ID = @Ac_SignedOnWorker_ID,
         TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB,
		 BeginValidity_DATE = @Ld_Systemdate_DATE,
         Update_DTTM = @Ld_Systemdate_DTTM
   WHERE DEMO_Y1.MemberMci_IDNO = @An_MemberMci_IDNO
     AND DEMO_Y1.Restricted_INDC <> @Ac_Restricted_INDC;

  SET @Ln_RowsAffected_NUMB = @@ROWCOUNT;

  SELECT @Ln_RowsAffected_NUMB AS RowsAffected_NUMB;
 END -- End Of DEMO_UPDATE_S2  

GO
