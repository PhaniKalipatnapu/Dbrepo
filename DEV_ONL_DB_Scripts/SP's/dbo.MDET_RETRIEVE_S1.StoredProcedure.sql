/****** Object:  StoredProcedure [dbo].[MDET_RETRIEVE_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[MDET_RETRIEVE_S1] (
 @An_MemberMci_IDNO           NUMERIC(10, 0),
 @An_TransactionEventSeq_NUMB NUMERIC(19, 0) OUTPUT,
 @An_Institution_IDNO         NUMERIC(9, 0) OUTPUT,
 @Ac_TypeInst_CODE            CHAR(2) OUTPUT,
 @Ad_Institutionalized_DATE   DATE OUTPUT,
 @Ad_Incarceration_DATE       DATE OUTPUT,
 @Ad_Release_DATE             DATE OUTPUT,
 @Ad_EligParole_DATE          DATE OUTPUT,
 @Ac_MoveType_CODE            CHAR(2) OUTPUT,
 @An_Inmate_NUMB              NUMERIC(15, 0) OUTPUT,
 @Ac_ParoleReason_CODE        CHAR(4) OUTPUT,
 @An_InstSbin_IDNO            NUMERIC(10, 0) OUTPUT,
 @As_ParoleOfficer_NAME       VARCHAR(50) OUTPUT,
 @An_PhoneParoleOffice_NUMB   NUMERIC(15, 0) OUTPUT,
 @As_DescriptionHold_TEXT     VARCHAR(70) OUTPUT,
 @Ac_Sentence_CODE            CHAR(2) OUTPUT,
 @Ac_WorkerUpdate_ID          CHAR(30) OUTPUT,
 @Ad_Update_DTTM              DATETIME2 OUTPUT,
 @As_ProbationOfficer_NAME    VARCHAR(50) OUTPUT,
 @Ad_MaxRelease_DATE          DATE OUTPUT,
 @An_OthpPartyProbation_IDNO  NUMERIC(9, 0) OUTPUT,
 @Ac_WorkRelease_INDC         CHAR(1) OUTPUT,
 @Ac_InstitutionStatus_CODE   CHAR(1) OUTPUT,
 @Ac_ReleaseReason_CODE       CHAR(4) OUTPUT,
 @Ac_History_INDC             CHAR(1) OUTPUT,
 @As_OtherParty_NAME          VARCHAR(60) OUTPUT,
 @An_InstFbin_IDNO            NUMERIC(9, 0) OUTPUT,
 @An_PoliceDept_IDNO          NUMERIC(15, 0)OUTPUT,
 @Ac_Institution_NAME         CHAR(30) OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : MDET_RETRIEVE_S1
  *     DESCRIPTION       : Retrieve Member Detention details from Member Detention table for Unique Number Assigned by the System to the Member, retrieved worker ID who created/modified that record and retrieved effective Date with Time at which that record was inserted / modified in Member Demographics table.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 02-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SELECT @An_TransactionEventSeq_NUMB = NULL,
         @An_Institution_IDNO = NULL,
         @Ac_TypeInst_CODE = NULL,
         @Ad_Institutionalized_DATE = NULL,
         @Ad_Incarceration_DATE = NULL,
         @Ad_Release_DATE = NULL,
         @Ad_EligParole_DATE = NULL,
         @Ac_MoveType_CODE = NULL,
         @An_Inmate_NUMB = NULL,
         @Ac_ParoleReason_CODE = NULL,
         @An_InstSbin_IDNO = NULL,
         @As_ParoleOfficer_NAME = NULL,
         @An_PhoneParoleOffice_NUMB = NULL,
         @As_DescriptionHold_TEXT = NULL,
         @Ac_Sentence_CODE = NULL,
         @Ac_WorkerUpdate_ID = NULL,
         @Ad_Update_DTTM = NULL,
         @As_ProbationOfficer_NAME = NULL,
         @Ad_MaxRelease_DATE = NULL,
         @An_OthpPartyProbation_IDNO = NULL,
         @Ac_WorkRelease_INDC = NULL,
         @Ac_InstitutionStatus_CODE = NULL,
         @Ac_ReleaseReason_CODE = NULL,
         @Ac_History_INDC = NULL,
         @As_OtherParty_NAME = NULL,
         @An_InstFbin_IDNO = NULL,
         @An_PoliceDept_IDNO = NULL,
         @Ac_Institution_NAME = NULL;

  DECLARE @Ld_High_DATE      DATE = '12/31/9999',
          @Lc_TypeOthpJ_CODE CHAR(2) = 'J',
          @Lc_Yes_INDC       CHAR(1) = 'Y',
          @Lc_No_INDC        CHAR(1) = 'N';

  SELECT @An_TransactionEventSeq_NUMB = M.TransactionEventSeq_NUMB,
         @An_Institution_IDNO = M.Institution_IDNO,
         @Ac_TypeInst_CODE = M.TypeInst_CODE,
         @Ad_Institutionalized_DATE = M.Institutionalized_DATE,
         @Ad_Incarceration_DATE = M.Incarceration_DATE,
         @Ad_Release_DATE = M.Release_DATE,
         @Ad_EligParole_DATE = M.EligParole_DATE,
         @Ac_MoveType_CODE = M.MoveType_CODE,
         @An_Inmate_NUMB = M.Inmate_NUMB,
         @Ac_ParoleReason_CODE = M.ParoleReason_CODE,
         @An_InstSbin_IDNO = M.InstSbin_IDNO,
         @As_ParoleOfficer_NAME = M.ParoleOfficer_NAME,
         @An_PhoneParoleOffice_NUMB = M.PhoneParoleOffice_NUMB,
         @As_DescriptionHold_TEXT = M.DescriptionHold_TEXT,
         @Ac_Sentence_CODE = M.Sentence_CODE,
         @Ac_WorkerUpdate_ID = M.WorkerUpdate_ID,
         @Ad_Update_DTTM = M.Update_DTTM,
         @As_ProbationOfficer_NAME = M.ProbationOfficer_NAME,
         @Ad_MaxRelease_DATE = M.MaxRelease_DATE,
         @An_OthpPartyProbation_IDNO = OthpPartyProbation_IDNO,
         @Ac_WorkRelease_INDC = M.WorkRelease_INDC,
         @Ac_InstitutionStatus_CODE = M.InstitutionStatus_CODE,
         @Ac_ReleaseReason_CODE = M.ReleaseReason_CODE,
         @Ac_History_INDC = ISNULL ((SELECT TOP 1 @Lc_Yes_INDC
                                       FROM MDET_Y1 h
                                      WHERE h.MemberMci_IDNO = @An_MemberMci_IDNO
                                        AND h.EndValidity_DATE != @Ld_High_DATE), @Lc_No_INDC),
         @As_OtherParty_NAME = (SELECT O.OtherParty_NAME
                                  FROM OTHP_Y1 O
                                 WHERE O.OtherParty_IDNO = M.Institution_IDNO
                                   AND O.TypeOthp_CODE = @Lc_TypeOthpJ_CODE
                                   AND O.EndValidity_DATE = @Ld_High_DATE),
         @An_InstFbin_IDNO = M.InstFbin_IDNO,
         @An_PoliceDept_IDNO = M.PoliceDept_IDNO,
         @Ac_Institution_NAME = M.Institution_NAME
    FROM MDET_Y1 M
   WHERE M.MemberMci_IDNO = @An_MemberMci_IDNO
     AND M.EndValidity_DATE = @Ld_High_DATE;
 END; --END of MDET_RETRIEVE_S1

GO
