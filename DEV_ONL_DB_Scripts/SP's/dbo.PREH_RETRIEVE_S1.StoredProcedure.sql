/****** Object:  StoredProcedure [dbo].[PREH_RETRIEVE_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[PREH_RETRIEVE_S1]	
(@An_CaseWelfare_IDNO 			NUMERIC(10),
@An_AgSequence_NUMB	  			NUMERIC(4),
@An_MemberMci_IDNO	  			NUMERIC(10),
@An_TransactionEventSeq_NUMB	NUMERIC(19),
@Ad_ReferralReceived_DATE 		DATE OUTPUT,
@As_Employer_NAME				VARCHAR(60) OUTPUT,
@An_Fein_IDNO					NUMERIC(9) OUTPUT,
@As_Line1_ADDR					VARCHAR(50) OUTPUT,
@As_Line2_ADDR					VARCHAR(50) OUTPUT,
@Ac_City_ADDR					CHAR(28) OUTPUT,
@Ac_State_ADDR					CHAR(2) OUTPUT,
@Ac_Zip_ADDR					CHAR(15) OUTPUT
)
AS
 /*
 *     PROCEDURE NAME    : PREH_RETRIEVE_S1
  *     DESCRIPTION       : Retrieves Employer details.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 02-MAR-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
BEGIN

--13681 -- BATCH_FIN_IVA_UPDATES failed while inserting record into CPDR -- Start
SELECT @Ad_ReferralReceived_DATE = P.ReferralReceived_DATE,
	@As_Employer_NAME = P.Employer_NAME,
	@An_Fein_IDNO = P.Fein_IDNO,
	@As_Line1_ADDR = P.Line1_ADDR,
	@As_Line2_ADDR = P.Line2_ADDR,
	@Ac_City_ADDR = P.City_ADDR,
	@Ac_State_ADDR = P.State_ADDR,
	@Ac_Zip_ADDR = P.Zip_ADDR
FROM PREH_Y1 P 
	 JOIN PRDE_Y1 D
		ON D.CaseWelfare_IDNO = P.CaseWelfare_IDNO
	AND D.AgSequence_NUMB = P.AgSequence_NUMB
	AND D.MemberMci_IDNO = P.MemberMci_IDNO
	AND D.ReferralReceived_DATE = P.ReferralReceived_DATE
	AND D.TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB
WHERE P.CaseWelfare_IDNO = @An_CaseWelfare_IDNO
AND P.AgSequence_NUMB = @An_AgSequence_NUMB
AND P.MemberMci_IDNO = @An_MemberMci_IDNO;
--13681 -- BATCH_FIN_IVA_UPDATES failed while inserting record into CPDR -- End

END;

GO
