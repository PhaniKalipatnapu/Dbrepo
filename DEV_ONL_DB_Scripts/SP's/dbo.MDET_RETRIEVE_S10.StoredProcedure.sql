/****** Object:  StoredProcedure [dbo].[MDET_RETRIEVE_S10]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[MDET_RETRIEVE_S10](
 @An_MemberMci_IDNO          NUMERIC(10, 0),
 @Ad_EligParole_DATE         DATE OUTPUT,
 @Ad_Incarceration_DATE      DATE OUTPUT,
 @Ad_Institutionalized_DATE  DATE OUTPUT,
 @Ac_MoveType_CODE           CHAR(2) OUTPUT,
 @Ac_ParoleReason_CODE       CHAR(4) OUTPUT,
 @Ac_Sentence_CODE           CHAR(2) OUTPUT,
 @Ac_TypeInst_CODE           CHAR(2) OUTPUT,
 @As_DescriptionHold_TEXT    VARCHAR(70) OUTPUT,
 @Ad_Release_DATE            DATE OUTPUT,
 @An_InstFbin_IDNO           NUMERIC(9, 0) OUTPUT,
 @An_InstSbin_IDNO           NUMERIC(10, 0) OUTPUT,
 @An_PoliceDept_IDNO         NUMERIC(15, 0) OUTPUT,
 @Ac_Institution_NAME        CHAR(30) OUTPUT,
 @As_ParoleOfficer_NAME      VARCHAR(50) OUTPUT,
 @As_ProbationOfficer_NAME   VARCHAR(50) OUTPUT,
 @An_Inmate_NUMB             NUMERIC(15, 0) OUTPUT,
 @An_PhoneParoleOffice_NUMB  NUMERIC(15, 0) OUTPUT,
 @Ad_MaxRelease_DATE         DATE OUTPUT,
 @An_OthpPartyProbation_IDNO NUMERIC(9, 0) OUTPUT,
 @Ac_WorkRelease_INDC        CHAR(1) OUTPUT,
 @Ac_InstitutionStatus_CODE  CHAR(1) OUTPUT,
 @Ac_ReleaseReason_CODE      CHAR(4) OUTPUT,
 @An_TransactionEventSeq_NUMB	NUMERIC(19,0) OUTPUT 
 )
AS
 /*
 *     PROCEDURE NAME    : MDET_RETRIEVE_S10
  *     DESCRIPTION       : Retrieve Member Detention details for a Member ID when End Validity Date is equal to High Date.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 02-MAR-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SELECT @Ad_EligParole_DATE = NULL,
         @Ad_Incarceration_DATE = NULL,
         @Ad_Institutionalized_DATE = NULL,
         @Ac_MoveType_CODE = NULL,
         @Ac_ParoleReason_CODE = NULL,
         @Ac_Sentence_CODE = NULL,
         @Ac_TypeInst_CODE = NULL,
         @As_DescriptionHold_TEXT = NULL,
         @Ad_Release_DATE = NULL,
         @An_InstFbin_IDNO = NULL,
         @An_InstSbin_IDNO = NULL,
         @An_PoliceDept_IDNO = NULL,
         @Ac_Institution_NAME = NULL,
         @As_ParoleOfficer_NAME = NULL,
         @As_ProbationOfficer_NAME = NULL,
         @An_Inmate_NUMB = NULL,
         @An_PhoneParoleOffice_NUMB = NULL,
         @Ad_MaxRelease_DATE = NULL,
         @An_OthpPartyProbation_IDNO = NULL,
         @Ac_WorkRelease_INDC = NULL,
         @Ac_InstitutionStatus_CODE = NULL,
         @Ac_ReleaseReason_CODE = NULL,
         @An_TransactionEventSeq_NUMB = null;

  DECLARE @Ld_High_DATE DATE = '12/31/9999';

  SELECT @Ac_Institution_NAME = M.Institution_NAME,
         @Ac_TypeInst_CODE = M.TypeInst_CODE,
         @An_PoliceDept_IDNO = M.PoliceDept_IDNO,
         @Ad_Institutionalized_DATE = M.Institutionalized_DATE,
         @Ad_Incarceration_DATE = M.Incarceration_DATE,
         @Ad_Release_DATE = M.Release_DATE,
         @Ad_EligParole_DATE = M.EligParole_DATE,
         @Ac_MoveType_CODE = M.MoveType_CODE,
         @Ac_ParoleReason_CODE = M.ParoleReason_CODE,
         @An_InstSbin_IDNO = M.InstSbin_IDNO,
         @An_Inmate_NUMB = M.Inmate_NUMB,
         @As_ParoleOfficer_NAME = M.ParoleOfficer_NAME,
         @An_PhoneParoleOffice_NUMB = M.PhoneParoleOffice_NUMB,
         @As_DescriptionHold_TEXT = M.DescriptionHold_TEXT,
         @Ac_Sentence_CODE = M.Sentence_CODE,
         @As_ProbationOfficer_NAME = M.ProbationOfficer_NAME,
         @An_InstFbin_IDNO = M.InstFbin_IDNO,
         @Ad_MaxRelease_DATE = M.MaxRelease_DATE,
         @An_OthpPartyProbation_IDNO = M.OthpPartyProbation_IDNO,
         @Ac_WorkRelease_INDC = M.WorkRelease_INDC,
         @Ac_InstitutionStatus_CODE = M.InstitutionStatus_CODE,
         @Ac_ReleaseReason_CODE = M.ReleaseReason_CODE,
         @An_TransactionEventSeq_NUMB = M.TransactionEventSeq_NUMB
    FROM MDET_Y1 M
   WHERE M.MemberMci_IDNO = @An_MemberMci_IDNO
     AND M.EndValidity_DATE = @Ld_High_DATE;
 END; --End of MDET_RETRIEVE_S10


GO
