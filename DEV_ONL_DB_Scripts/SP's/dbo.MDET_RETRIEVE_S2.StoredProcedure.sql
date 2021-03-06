/****** Object:  StoredProcedure [dbo].[MDET_RETRIEVE_S2]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[MDET_RETRIEVE_S2] (
 @An_MemberMci_IDNO          NUMERIC(10, 0),
 @An_Record_NUMB             NUMERIC(22, 0),
 @An_Institution_IDNO        NUMERIC(9, 0) OUTPUT,
 @Ac_TypeInst_CODE           CHAR(2) OUTPUT,
 @Ad_Institutionalized_DATE  DATE OUTPUT,
 @Ad_Incarceration_DATE      DATE OUTPUT,
 @Ad_Release_DATE            DATE OUTPUT,
 @Ad_EligParole_DATE         DATE OUTPUT,
 @Ac_MoveType_CODE           CHAR(2) OUTPUT,
 @An_Inmate_NUMB             NUMERIC(15, 0) OUTPUT,
 @Ac_ParoleReason_CODE       CHAR(4) OUTPUT,
 @An_InstSbin_IDNO           NUMERIC(10, 0) OUTPUT,
 @As_ParoleOfficer_NAME      VARCHAR(50) OUTPUT,
 @An_PhoneParoleOffice_NUMB  NUMERIC(15, 0) OUTPUT,
 @As_DescriptionHold_TEXT    VARCHAR(70) OUTPUT,
 @Ac_Sentence_CODE           CHAR(2) OUTPUT,
 @Ac_WorkerUpdate_ID         CHAR(30) OUTPUT,
 @Ad_Update_DTTM             DATETIME2 OUTPUT,
 @As_ProbationOfficer_NAME   VARCHAR(50) OUTPUT,
 @Ad_MaxRelease_DATE         DATE OUTPUT,
 @An_OthpPartyProbation_IDNO NUMERIC(9, 0) OUTPUT,
 @Ac_WorkRelease_INDC        CHAR(1) OUTPUT,
 @Ac_InstitutionStatus_CODE  CHAR(1) OUTPUT,
 @Ac_ReleaseReason_CODE      CHAR(4) OUTPUT,
 @As_OtherParty_NAME         VARCHAR(60) OUTPUT,
 @An_RowCount_NUMB           NUMERIC(6, 0) OUTPUT
 )
AS
 /*
 *     PROCEDURE NAME    : MDET_RETRIEVE_S2
  *     DESCRIPTION       : Retrieve Member Detention details from Member Detention table for Unique Number Assigned by the System to the Member and retrieved Unique Sequence Number that will be generated for any given Transaction on Member Demographisc History table.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 10-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SELECT @An_Institution_IDNO = NULL,
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
         @As_OtherParty_NAME = NULL,
         @An_RowCount_NUMB = NULL;

  DECLARE @Lc_TypeOthpJ_CODE CHAR(2)= 'J',
          @Ld_High_DATE      DATE= '12/31/9999';

  SELECT @An_Institution_IDNO = X.Institution_IDNO,
         @Ac_TypeInst_CODE = X.TypeInst_CODE,
         @Ad_Institutionalized_DATE = X.Institutionalized_DATE,
         @Ad_Incarceration_DATE = X.Incarceration_DATE,
         @Ad_Release_DATE = X.Release_DATE,
         @Ad_EligParole_DATE = X.EligParole_DATE,
         @Ac_MoveType_CODE = X.MoveType_CODE,
         @An_Inmate_NUMB = X.Inmate_NUMB,
         @Ac_ParoleReason_CODE = X.ParoleReason_CODE,
         @An_InstSbin_IDNO = X.InstSbin_IDNO,
         @As_ParoleOfficer_NAME = X.ParoleOfficer_NAME,
         @An_PhoneParoleOffice_NUMB = X.PhoneParoleOffice_NUMB,
         @As_DescriptionHold_TEXT = X.DescriptionHold_TEXT,
         @Ac_Sentence_CODE = X.Sentence_CODE,
         @Ac_WorkerUpdate_ID = X.WorkerUpdate_ID,
         @Ad_Update_DTTM = X.Update_DTTM,
         @As_ProbationOfficer_NAME = X.ProbationOfficer_NAME,
         @Ad_MaxRelease_DATE = X.MaxRelease_DATE,
         @An_OthpPartyProbation_IDNO = X.OthpPartyProbation_IDNO,
         @Ac_WorkRelease_INDC = X.WorkRelease_INDC,
         @Ac_InstitutionStatus_CODE = X.InstitutionStatus_CODE,
         @Ac_ReleaseReason_CODE = X.ReleaseReason_CODE,
         @As_OtherParty_NAME = (SELECT O.OtherParty_NAME
                                  FROM OTHP_Y1 O
                                 WHERE O.OtherParty_IDNO = X.Institution_IDNO
                                   AND O.TypeOthp_CODE = @Lc_TypeOthpJ_CODE
                                   AND O.EndValidity_DATE = @Ld_High_DATE),
         @An_RowCount_NUMB = X.RowCount_NUMB
    FROM (SELECT M.Institution_IDNO,
                 M.TypeInst_CODE,
                 M.Institutionalized_DATE,
                 M.Incarceration_DATE,
                 M.Release_DATE,
                 M.EligParole_DATE,
                 M.MoveType_CODE,
                 M.Inmate_NUMB,
                 M.ParoleReason_CODE,
                 M.InstSbin_IDNO,
                 M.ParoleOfficer_NAME,
                 M.PhoneParoleOffice_NUMB,
                 M.DescriptionHold_TEXT,
                 M.Sentence_CODE,
                 M.WorkerUpdate_ID,
                 M.Update_DTTM,
                 M.ProbationOfficer_NAME,
                 M.MaxRelease_DATE,
                 M.OthpPartyProbation_IDNO,
                 M.WorkRelease_INDC,
                 M.InstitutionStatus_CODE,
                 M.ReleaseReason_CODE,
                 COUNT(1) OVER() AS RowCount_NUMB,
                 ROW_NUMBER() OVER( ORDER BY M.TransactionEventSeq_NUMB DESC ) AS RecRank_NUMB
            FROM MDET_Y1 M
           WHERE M.MemberMci_IDNO = @An_MemberMci_IDNO
             AND M.EndValidity_DATE != @Ld_High_DATE) AS X
   WHERE X.RecRank_NUMB = @An_Record_NUMB;
 END; -- END of MDET_RETRIEVE_S2


GO
