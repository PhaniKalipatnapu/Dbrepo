/****** Object:  StoredProcedure [dbo].[UDEM_RETRIEVE_S2]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[UDEM_RETRIEVE_S2](
	@An_MemberMci_IDNO					NUMERIC(10,0),
	@An_MemberMciNew_IDNO				NUMERIC(10,0),
	@An_TransactionEventSeq_NUMB		NUMERIC(19,0),
	@Ac_First_NAME						CHAR(16)		OUTPUT,
	@Ac_Last_NAME           			CHAR(20)		OUTPUT,
	@Ac_Middle_NAME         			CHAR(20)		OUTPUT,
	@Ac_Suffix_NAME         			CHAR(4)			OUTPUT,
	@Ad_Birth_DATE          			DATE 			OUTPUT,
	@Ad_Deceased_DATE       			DATE 			OUTPUT,
	@An_MemberSsn_NUMB      			NUMERIC(9,0)	OUTPUT,
	@Ac_MemberSex_CODE      			CHAR(1)			OUTPUT,
	@Ac_Race_CODE           			CHAR(1)			OUTPUT,
	@Ac_Source_CODE						CHAR(3)			OUTPUT,
	@Ac_Status_CODE						CHAR(1)			OUTPUT,
	@Ac_FirstNameAcceptance_INDC		CHAR(1)			OUTPUT,
	@Ac_LastNameAcceptance_INDC			CHAR(1)			OUTPUT,
	@Ac_MiddleNameAcceptance_INDC		CHAR(1)			OUTPUT,
	@Ac_SuffixNameAcceptance_INDC		CHAR(1)			OUTPUT,
	@Ac_BirthDateAcceptance_INDC		CHAR(1)			OUTPUT,
	@Ac_DeceasedDateAcceptance_INDC		CHAR(1)			OUTPUT,
	@Ac_MemberSsnAcceptance_INDC		CHAR(1)			OUTPUT,
	@Ac_MemberSexAcceptance_INDC		CHAR(1)			OUTPUT,
	@Ac_RaceAcceptance_INDC				CHAR(1)			OUTPUT,
	@Ac_WorkerUpdate_ID					CHAR(30)		OUTPUT
	)
AS

/*
 *     PROCEDURE NAME    : UDEM_RETRIEVE_S2
 *     DESCRIPTION       : Retrieves the Member details for Review pop up.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 10-AUG-2011
 *     MODIFIED BY       :
 *     MODIFIED ON       :
 *     VERSION NO        : 1
*/

BEGIN

	SELECT @Ac_Source_CODE = U.Source_CODE,
		   @Ac_First_NAME = U.First_NAME,
		   @Ac_Last_NAME = U.Last_NAME,
		   @Ac_Middle_NAME = U.Middle_NAME,
		   @Ac_Suffix_NAME = U.Suffix_NAME,
		   @Ad_Birth_DATE = U.Birth_DATE,
		   @An_MemberSsn_NUMB = U.MemberSsn_NUMB,
		   @Ac_MemberSex_CODE = U.MemberSex_CODE,
		   @Ac_Race_CODE = U.Race_CODE,
		   @Ad_Deceased_DATE = U.Deceased_DATE,
		   @Ac_FirstNameAcceptance_INDC = U.FirstNameAcceptance_INDC,
		   @Ac_LastNameAcceptance_INDC = U.LastNameAcceptance_INDC,
		   @Ac_MiddleNameAcceptance_INDC = U.MiddleNameAcceptance_INDC,
		   @Ac_SuffixNameAcceptance_INDC = U.SuffixNameAcceptance_INDC,
		   @Ac_BirthDateAcceptance_INDC = U.BirthDateAcceptance_INDC,
		   @Ac_MemberSsnAcceptance_INDC = U.MemberSsnAcceptance_INDC,
		   @Ac_MemberSexAcceptance_INDC = U.MemberSexAcceptance_INDC,
		   @Ac_RaceAcceptance_INDC = U.RaceAcceptance_INDC,
		   @Ac_DeceasedDateAcceptance_INDC = U.DeceasedDateAcceptance_INDC,
		   @Ac_Status_CODE = U.Status_CODE,
		   @Ac_WorkerUpdate_ID = U.WorkerUpdate_ID
	FROM UDEM_Y1 U
	WHERE U.MemberMci_IDNO = @An_MemberMci_IDNO
	AND U.MemberMciNew_IDNO = @An_MemberMciNew_IDNO
	AND U.TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB;


END; --END OF UDEM_RETRIEVE_S2


GO
