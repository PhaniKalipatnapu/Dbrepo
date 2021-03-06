/****** Object:  StoredProcedure [dbo].[UDEM_UPDATE_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[UDEM_UPDATE_S1]
	(
		@An_MemberMci_IDNO                  NUMERIC(10,0),
		@An_MemberMciNew_IDNO               NUMERIC(10,0),
		@Ac_Status_CODE                     CHAR(1),
		@Ac_FirstNameAcceptance_INDC        CHAR(1),
		@Ac_LastNameAcceptance_INDC         CHAR(1),
		@Ac_MiddleNameAcceptance_INDC       CHAR(1),
		@Ac_SuffixNameAcceptance_INDC       CHAR(1),
		@Ac_BirthDateAcceptance_INDC        CHAR(1),
		@Ac_DeceasedDateAcceptance_INDC     CHAR(1),
		@Ac_MemberSsnAcceptance_INDC        CHAR(1),
		@Ac_MemberSexAcceptance_INDC        CHAR(1),
		@Ac_RaceAcceptance_INDC             CHAR(1),
		@Ac_SignedOnWorker_ID				CHAR(30),
		@An_TransactionEventSeq_NUMB		NUMERIC(19,0),
		@An_TransactionEventSeqNew_NUMB		NUMERIC(19,0)
    )
AS

/*
 *     PROCEDURE NAME    : UDEM_UPDATE_S1
 *     DESCRIPTION       : Updates the Member details after reviewed in Review pop up.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 24-DEC-2011
 *     MODIFIED BY       :
 *     MODIFIED ON       :
 *     VERSION NO        : 1
*/
   BEGIN
		DECLARE
			 @Ld_SystemDatetime_DTTM		DATETIME2	= dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
			 @Ln_RowsAffected_NUMB  		NUMERIC(10);

      UPDATE UDEM_Y1
         SET Status_CODE = @Ac_Status_CODE,
			 FirstNameAcceptance_INDC = @Ac_FirstNameAcceptance_INDC,
			 LastNameAcceptance_INDC = @Ac_LastNameAcceptance_INDC,
			 MiddleNameAcceptance_INDC = @Ac_MiddleNameAcceptance_INDC,
			 SuffixNameAcceptance_INDC = @Ac_SuffixNameAcceptance_INDC,
			 BirthDateAcceptance_INDC = @Ac_BirthDateAcceptance_INDC,
			 DeceasedDateAcceptance_INDC = @Ac_DeceasedDateAcceptance_INDC,
			 MemberSsnAcceptance_INDC = @Ac_MemberSsnAcceptance_INDC,
			 MemberSexAcceptance_INDC = @Ac_MemberSexAcceptance_INDC,
			 RaceAcceptance_INDC = @Ac_RaceAcceptance_INDC,
			 Completed_DATE = @Ld_SystemDatetime_DTTM,
			 BeginValidity_DATE = @Ld_SystemDatetime_DTTM,
			 Update_DTTM = @Ld_SystemDatetime_DTTM,
			 WorkerUpdate_ID = @Ac_SignedOnWorker_ID,
			 TransactionEventSeq_NUMB = @An_TransactionEventSeqNew_NUMB
      OUTPUT DELETED.MemberMci_IDNO,
			 DELETED.MemberMciNew_IDNO,
			 DELETED.First_NAME,
			 DELETED.Last_NAME,
			 DELETED.Middle_NAME,
			 DELETED.Suffix_NAME,
			 DELETED.Birth_DATE,
			 DELETED.Deceased_DATE,
			 DELETED.MemberSsn_NUMB,
			 DELETED.MemberSex_CODE,
			 DELETED.Race_CODE,
			 DELETED.TypeUpdate_CODE,
			 DELETED.Source_CODE,
			 DELETED.Received_DATE,
			 DELETED.Completed_DATE,
			 DELETED.Status_CODE,
			 DELETED.FirstNameAcceptance_INDC,
			 DELETED.LastNameAcceptance_INDC,
			 DELETED.MiddleNameAcceptance_INDC,
			 DELETED.SuffixNameAcceptance_INDC,
			 DELETED.BirthDateAcceptance_INDC,
			 DELETED.DeceasedDateAcceptance_INDC,
			 DELETED.MemberSsnAcceptance_INDC,
			 DELETED.MemberSexAcceptance_INDC,
			 DELETED.RaceAcceptance_INDC,
			 DELETED.BeginValidity_DATE,
			 @Ld_SystemDatetime_DTTM,
			 DELETED.Update_DTTM,
			 DELETED.WorkerUpdate_ID,
			 DELETED.TransactionEventSeq_NUMB			
	  INTO HUDEM_Y1 (
					MemberMci_IDNO,
					MemberMciNew_IDNO,
					First_NAME,
					Last_NAME,
					Middle_NAME,
					Suffix_NAME,
					Birth_DATE,
					Deceased_DATE,
					MemberSsn_NUMB,
					MemberSex_CODE,
					Race_CODE,
					TypeUpdate_CODE,
					Source_CODE,
					Received_DATE,
					Completed_DATE,
					Status_CODE,
					FirstNameAcceptance_INDC,
					LastNameAcceptance_INDC,
					MiddleNameAcceptance_INDC,
					SuffixNameAcceptance_INDC,
					BirthDateAcceptance_INDC,
					DeceasedDateAcceptance_INDC,
					MemberSsnAcceptance_INDC,
					MemberSexAcceptance_INDC,
					RaceAcceptance_INDC,
					BeginValidity_DATE,
					EndValidity_DATE,
					Update_DTTM,
					WorkerUpdate_ID,
					TransactionEventSeq_NUMB
	  				)
      WHERE MemberMci_IDNO = @An_MemberMci_IDNO
      AND MemberMciNew_IDNO = @An_MemberMciNew_IDNO
	  AND TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB;

          SET @Ln_RowsAffected_NUMB = @@ROWCOUNT;
       SELECT @Ln_RowsAffected_NUMB AS  RowsAffected_NUMB;

END; --END OF UDEM_UPDATE_S1


GO
