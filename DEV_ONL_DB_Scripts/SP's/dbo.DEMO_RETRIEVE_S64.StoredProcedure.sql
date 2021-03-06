/****** Object:  StoredProcedure [dbo].[DEMO_RETRIEVE_S64]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DEMO_RETRIEVE_S64](
 @An_MemberMci_IDNO           NUMERIC(10, 0),
 @Ac_BirthCity_NAME           CHAR(28) OUTPUT,
 @Ac_BirthState_CODE          CHAR(2) OUTPUT,
 @An_TransactionEventSeq_NUMB NUMERIC(19, 0) OUTPUT,
 @Ac_PaternityEst_INDC        CHAR(1) OUTPUT,
 @Ac_PaternityEst_CODE        CHAR(2) OUTPUT,
 @Ad_PaternityEst_DATE        DATE OUTPUT,
 @An_IveParty_IDNO            NUMERIC(10, 0) OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : DEMO_RETRIEVE_S64
  *     DESCRIPTION       : Retrieve Unique Sequence Number for a Member ID.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 20-SEP-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SELECT @An_TransactionEventSeq_NUMB = NULL,
         @Ac_BirthCity_NAME = NULL,
         @Ac_BirthState_CODE = NULL,
         @Ac_PaternityEst_INDC = NULL,
         @Ac_PaternityEst_CODE = NULL,
         @Ad_PaternityEst_DATE = NULL;

  SELECT @An_TransactionEventSeq_NUMB = D.TransactionEventSeq_NUMB,
         @Ac_BirthCity_NAME = D.BirthCity_NAME,
         @Ac_BirthState_CODE = D.BirthState_CODE,
         @Ac_PaternityEst_INDC = M.PaternityEst_INDC,
         @Ac_PaternityEst_CODE = M.PaternityEst_CODE,
         @Ad_PaternityEst_DATE = M.PaternityEst_DATE,
		 @An_IveParty_IDNO = D.IveParty_IDNO
    FROM DEMO_Y1 D
         JOIN MPAT_Y1 M
          ON (D.MemberMci_IDNO = M.MemberMci_IDNO)
   WHERE D.MemberMci_IDNO = @An_MemberMci_IDNO;
 END; --End of DEMO_RETRIEVE_S64

GO
