/****** Object:  StoredProcedure [dbo].[MDET_INSERT_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[MDET_INSERT_S1] (
 @An_MemberMci_IDNO           NUMERIC(10, 0),
 @An_TransactionEventSeq_NUMB NUMERIC(19, 0),
 @An_Institution_IDNO         NUMERIC(9, 0),
 @Ac_Institution_NAME         CHAR(30),
 @Ac_TypeInst_CODE            CHAR(2),
 @An_PoliceDept_IDNO          NUMERIC(15, 0),
 @Ad_Institutionalized_DATE   DATE,
 @Ad_Incarceration_DATE       DATE,
 @Ad_Release_DATE             DATE,
 @Ad_EligParole_DATE          DATE,
 @Ac_MoveType_CODE            CHAR(2),
 @An_Inmate_NUMB              NUMERIC(15, 0),
 @Ac_ParoleReason_CODE        CHAR(4),
 @An_InstSbin_IDNO            NUMERIC(10, 0),
 @An_InstFbin_IDNO            NUMERIC(9, 0),
 @As_ParoleOfficer_NAME       VARCHAR(50),
 @An_PhoneParoleOffice_NUMB   NUMERIC(15, 0),
 @As_DescriptionHold_TEXT     VARCHAR(70),
 @Ac_Sentence_CODE            CHAR(2),
 @Ac_SignedOnWorker_ID        CHAR(30),
 @As_ProbationOfficer_NAME    VARCHAR(50),
 @Ad_MaxRelease_DATE          DATE,
 @An_OthpPartyProbation_IDNO  NUMERIC(9, 0),
 @Ac_WorkRelease_INDC         CHAR(1),
 @Ac_InstitutionStatus_CODE   CHAR(1),
 @Ac_ReleaseReason_CODE       CHAR(4)
 )
AS
 /*
  *     PROCEDURE NAME    : MDET_INSERT_S1
  *     DESCRIPTION       : Insert Member Detention details with retrieved Police ID, Members Inmate number, the SET Release Date, maximum Life or Death Sentence of the Member, Name of the Institution and the FEIN Number of the Institution, new Sequence Event Transaction, the SET Incarceration Date and the SET Institutionalized Date into Member Detention table for Unique System generated Id for the Member.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 11-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Ld_Systemdatetime_DTTM DATETIME2 = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
          @Ld_High_DATE           DATE = '12/31/9999';

  INSERT MDET_Y1
         (MemberMci_IDNO,
          TransactionEventSeq_NUMB,
          Institution_IDNO,
          Institution_NAME,
          TypeInst_CODE,
          PoliceDept_IDNO,
          Institutionalized_DATE,
          Incarceration_DATE,
          Release_DATE,
          EligParole_DATE,
          MoveType_CODE,
          Inmate_NUMB,
          ParoleReason_CODE,
          InstSbin_IDNO,
          InstFbin_IDNO,
          ParoleOfficer_NAME,
          PhoneParoleOffice_NUMB,
          DescriptionHold_TEXT,
          Sentence_CODE,
          WorkerUpdate_ID,
          Update_DTTM,
          BeginValidity_DATE,
          EndValidity_DATE,
          ProbationOfficer_NAME,
          MaxRelease_DATE,
          OthpPartyProbation_IDNO,
          WorkRelease_INDC,
          InstitutionStatus_CODE,
          ReleaseReason_CODE)
  VALUES ( @An_MemberMci_IDNO,
           @An_TransactionEventSeq_NUMB,
           @An_Institution_IDNO,
           @Ac_Institution_NAME,
           @Ac_TypeInst_CODE,
           @An_PoliceDept_IDNO,
           @Ad_Institutionalized_DATE,
           @Ad_Incarceration_DATE,
           @Ad_Release_DATE,
           @Ad_EligParole_DATE,
           @Ac_MoveType_CODE,
           @An_Inmate_NUMB,
           @Ac_ParoleReason_CODE,
           @An_InstSbin_IDNO,
           @An_InstFbin_IDNO,
           @As_ParoleOfficer_NAME,
           @An_PhoneParoleOffice_NUMB,
           @As_DescriptionHold_TEXT,
           @Ac_Sentence_CODE,
           @Ac_SignedOnWorker_ID,
           @Ld_Systemdatetime_DTTM,
           @Ld_Systemdatetime_DTTM,
           @Ld_High_DATE,
           @As_ProbationOfficer_NAME,
           @Ad_MaxRelease_DATE,
           @An_OthpPartyProbation_IDNO,
           @Ac_WorkRelease_INDC,
           @Ac_InstitutionStatus_CODE,
           @Ac_ReleaseReason_CODE );
 END; --End of MDET_INSERT_S1


GO
