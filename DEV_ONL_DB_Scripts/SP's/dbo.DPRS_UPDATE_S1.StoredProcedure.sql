/****** Object:  StoredProcedure [dbo].[DPRS_UPDATE_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[DPRS_UPDATE_S1]
	(
     @Ac_File_ID						CHAR(10),
     @An_DocketPerson_IDNO              NUMERIC(10,0),
     @Ac_SignedOnWorker_ID				CHAR(30),
     @Ad_EffectiveStart_DATE			DATE,
     @Ad_EffectiveEnd_DATE				DATE,
     @An_TransactionEventSeq_NUMB		NUMERIC(19,0),
     @As_AttorneyAttn_NAME				VARCHAR(60),
     @An_AssociatedMemberMci_IDNO		NUMERIC(10,0),
     @An_TransactionEventSeqOld_NUMB	NUMERIC(19,0),
     @An_AssociatedMemberMciOld_IDNO	NUMERIC(10,0)
    )
AS

/*
 *     PROCEDURE NAME    : DPRS_UPDATE_S1
 *     DESCRIPTION       : Updating File Persons Details.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 24-DEC-2011
 *     MODIFIED BY       :
 *     MODIFIED ON       :
 *     VERSION NO        : 1
*/
   BEGIN
		DECLARE
			 @Ld_SystemDatetime_DTTM		DATETIME2	= dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
			 @Ld_High_DATE          		DATE    = '12/31/9999',
			 @Ln_RowsAffected_NUMB  		NUMERIC(10);

      UPDATE DPRS_Y1
         SET WorkerUpdate_ID = @Ac_SignedOnWorker_ID,
             EffectiveStart_DATE = @Ad_EffectiveStart_DATE,
             EffectiveEnd_DATE = @Ad_EffectiveEnd_DATE,
             BeginValidity_DATE = @Ld_SystemDatetime_DTTM,
             EndValidity_DATE = @Ld_High_DATE,
             TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB,
             Update_DTTM = @Ld_SystemDatetime_DTTM,
             AttorneyAttn_NAME = @As_AttorneyAttn_NAME,
             AssociatedMemberMci_IDNO = @An_AssociatedMemberMci_IDNO
      OUTPUT
            DELETED.File_ID,
			DELETED.County_IDNO,
			DELETED.TypePerson_CODE,
			DELETED.DocketPerson_IDNO,
			DELETED.WorkerUpdate_ID,
			DELETED.File_NAME,
			DELETED.EffectiveStart_DATE,
			DELETED.EffectiveEnd_DATE,
			DELETED.BeginValidity_DATE,
			@Ld_SystemDatetime_DTTM AS EndValidity_DATE,
			DELETED.TransactionEventSeq_NUMB,
			DELETED.Update_DTTM,
			DELETED.AttorneyAttn_NAME,
			DELETED.AssociatedMemberMci_IDNO
	  INTO DPRS_Y1
      WHERE File_ID = @Ac_File_ID
      AND AssociatedMemberMci_IDNO = @An_AssociatedMemberMciOld_IDNO
      AND DocketPerson_IDNO = @An_DocketPerson_IDNO
      AND TransactionEventSeq_NUMB = @An_TransactionEventSeqOld_NUMB
      AND EndValidity_DATE = @Ld_High_DATE;

          SET @Ln_RowsAffected_NUMB = @@ROWCOUNT;
       SELECT @Ln_RowsAffected_NUMB AS  RowsAffected_NUMB;

END; --END OF DPRS_UPDATE_S1


GO
