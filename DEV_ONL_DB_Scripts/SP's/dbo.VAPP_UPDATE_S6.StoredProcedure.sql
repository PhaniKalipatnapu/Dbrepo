/****** Object:  StoredProcedure [dbo].[VAPP_UPDATE_S6]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[VAPP_UPDATE_S6](
 @Ac_ChildBirthCertificate_ID		CHAR(7),
 @Ac_TypeDocument_CODE				CHAR(3),
 @Ac_DopAttached_CODE				CHAR(1),
 @Ac_SignedOnWorker_ID				CHAR(30),
 @An_TransactionEventSeq_NUMB		NUMERIC(19)
 )
AS
 /*    
 *      PROCEDURE NAME    : VAPP_UPDATE_S6    
  *     DESCRIPTION       : Update dop attached information for the given birth certificate and document type.
  *     DEVELOPED BY      : IMP Team    
  *     DEVELOPED ON      : 20-SEP-2011    
  *     MODIFIED BY       :     
  *     MODIFIED ON       :     
  *     VERSION NO        : 1    
 */
 BEGIN
  	DECLARE	@Ld_Current_DTTM DATETIME2 = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();

	UPDATE VAPP_Y1
    SET DopAttached_CODE = @Ac_DopAttached_CODE,
         WorkerUpdate_ID = @Ac_SignedOnWorker_ID,
         TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB,
         Update_DTTM = @Ld_Current_DTTM 
	WHERE ChildBirthCertificate_ID = @Ac_ChildBirthCertificate_ID
		AND TypeDocument_CODE = @Ac_TypeDocument_CODE;

  DECLARE @Ln_RowsAffected_NUMB NUMERIC(10);

  SELECT @Ln_RowsAffected_NUMB AS RowsAffected_NUMB;

 END; -- End Of VAPP_UPDATE_S6  


GO
