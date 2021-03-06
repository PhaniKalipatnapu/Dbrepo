/****** Object:  StoredProcedure [dbo].[ICAS_RETRIEVE_S13]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[ICAS_RETRIEVE_S13] (
 @An_Case_IDNO                    NUMERIC(6, 0),
 @Ai_Row_NUMB                     INT,
 @Ac_IVDOutOfStateFips_CODE       CHAR(2) OUTPUT,
 @Ac_StateFips_CODE               CHAR(2) OUTPUT,
 @Ac_IVDOutOfStateFile_ID         CHAR(17) OUTPUT,
 @Ac_Reason_CODE                  CHAR(5) OUTPUT,
 @An_TransactionEventSeq_NUMB     NUMERIC(19, 0) OUTPUT,
 @Ac_IVDOutOfStateCase_ID         CHAR(15) OUTPUT,
 @Ac_IVDOutOfStateOfficeFips_CODE CHAR(2) OUTPUT,
 @Ac_IVDOutOfStateCountyFips_CODE CHAR(3) OUTPUT,
 @Ac_Status_CODE                  CHAR(1) OUTPUT,
 @Ac_RespondInit_CODE             CHAR(1) OUTPUT,
 @As_Petitioner_NAME              VARCHAR(65) OUTPUT,
 @Ac_ContactFirst_NAME            CHAR(30) OUTPUT,
 @As_Respondent_NAME              VARCHAR(65) OUTPUT,
 @Ac_ContactLast_NAME             CHAR(30) OUTPUT,
 @Ac_ContactMiddle_NAME           CHAR(30) OUTPUT,
 @An_PhoneContact_NUMB            NUMERIC(15, 0) OUTPUT,
 @Ad_Referral_DATE                DATE OUTPUT,
 @As_Contact_EML                  VARCHAR(100) OUTPUT,
 @An_FaxContact_NUMB              NUMERIC(15, 0) OUTPUT,
 @Ac_File_ID                      CHAR(10) OUTPUT,
 @Ac_IVDOutOfStateTypeCase_CODE   CHAR(1) OUTPUT,
 @Ac_Worker_ID                    CHAR(30) OUTPUT,
 @Ac_WorkerUpdate_ID              CHAR(30) OUTPUT,
 @An_RespondentMci_IDNO           NUMERIC(10, 0) OUTPUT,
 @An_PetitionerMci_IDNO           NUMERIC(10, 0) OUTPUT,
 @As_DescriptionComments_TEXT     VARCHAR(1000) OUTPUT,
 @As_State_NAME                   VARCHAR(60) OUTPUT,
 @An_RowCount_NUMB                NUMERIC(6, 0) OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : ICAS_RETRIEVE_S13
  *     DESCRIPTION       : Retrieve Interstate Case details for a Case Idno that's common between two tables.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 04-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
  */
 BEGIN
  SELECT @Ac_IVDOutOfStateFips_CODE = NULL,
         @Ac_StateFips_CODE = NULL,
         @Ac_IVDOutOfStateFile_ID = NULL,
         @Ac_Reason_CODE = NULL,
         @An_TransactionEventSeq_NUMB = NULL,
         @Ac_IVDOutOfStateCase_ID = NULL,
         @Ac_IVDOutOfStateOfficeFips_CODE = NULL,
         @Ac_IVDOutOfStateCountyFips_CODE = NULL,
         @Ac_Status_CODE = NULL,
         @Ac_RespondInit_CODE = NULL,
         @As_Petitioner_NAME = NULL,
         @Ac_ContactFirst_NAME = NULL,
         @As_Respondent_NAME = NULL,
         @Ac_ContactLast_NAME = NULL,
         @Ac_ContactMiddle_NAME = NULL,
         @An_PhoneContact_NUMB = NULL,
         @Ad_Referral_DATE = NULL,
         @As_Contact_EML = NULL,
         @An_FaxContact_NUMB = NULL,
         @Ac_File_ID = NULL,
         @Ac_IVDOutOfStateTypeCase_CODE = NULL,
         @Ac_Worker_ID = NULL,
         @Ac_WorkerUpdate_ID = NULL,
         @An_PetitionerMci_IDNO = NULL,
         @An_RespondentMci_IDNO = NULL,
         @As_DescriptionComments_TEXT = NULL,
         @An_RowCount_NUMB = NULL,
         @As_State_NAME = NULL;

  DECLARE @Ld_High_DATE DATE = '12/31/9999';

  SELECT @Ac_IVDOutOfStateFips_CODE = a.IVDOutOfStateFips_CODE,
         @Ac_StateFips_CODE = a.StateFips_CODE,
         @Ac_IVDOutOfStateFile_ID = a.IVDOutOfStateFile_ID,
         @Ac_Reason_CODE = a.Reason_CODE,
         @An_TransactionEventSeq_NUMB = a.TransactionEventSeq_NUMB,
         @Ac_IVDOutOfStateCase_ID = a.IVDOutOfStateCase_ID,
         @Ac_IVDOutOfStateOfficeFips_CODE = a.IVDOutOfStateOfficeFips_CODE,
         @Ac_IVDOutOfStateCountyFips_CODE = a.IVDOutOfStateCountyFips_CODE,
         @Ac_Status_CODE = a.Status_CODE,
         @Ac_RespondInit_CODE = a.RespondInit_CODE,
         @As_Petitioner_NAME = a.Petitioner_NAME,
         @Ac_ContactFirst_NAME = a.ContactFirst_NAME,
         @As_Respondent_NAME = a.Respondent_NAME,
         @Ac_ContactLast_NAME = a.ContactLast_NAME,
         @Ac_ContactMiddle_NAME = a.ContactMiddle_NAME,
         @An_PhoneContact_NUMB = a.PhoneContact_NUMB,
         @Ad_Referral_DATE = a.Referral_DATE,
         @As_Contact_EML = a.Contact_EML,
         @An_FaxContact_NUMB = a.FaxContact_NUMB,
         @Ac_File_ID = a.File_ID,
         @Ac_IVDOutOfStateTypeCase_CODE = a.IVDOutOfStateTypeCase_CODE,
         @Ac_Worker_ID = a.Worker_ID,
         @Ac_WorkerUpdate_ID = a.WorkerUpdate_ID,
         @An_RespondentMci_IDNO = a.RespondentMci_IDNO,
         @An_PetitionerMci_IDNO = a.PetitionerMci_IDNO,
         @As_DescriptionComments_TEXT = a.DescriptionComments_TEXT,
         @As_State_NAME = a.State_NAME,
         @An_RowCount_NUMB = a.row_count
    FROM (SELECT sf.State_NAME,
                 sf.StateFips_CODE,
                 i.Petitioner_NAME,
                 i.Respondent_NAME,
                 i.IVDOutOfStateFips_CODE,
                 i.Status_CODE,
                 i.IVDOutOfStateCase_ID,
                 i.IVDOutOfStateFile_ID,
                 i.File_ID,
                 i.Referral_DATE,
                 i.IVDOutOfStateTypeCase_CODE,
                 i.ContactFirst_NAME,
                 i.ContactLast_NAME,
                 i.ContactMiddle_NAME,
                 i.Contact_EML,
                 i.PhoneContact_NUMB,
                 i.FaxContact_NUMB,
                 i.IVDOutOfStateCountyFips_CODE,
                 i.IVDOutOfStateOfficeFips_CODE,
                 i.RespondInit_CODE,
                 i.Reason_CODE,
                 i.Worker_ID,
                 i.WorkerUpdate_ID,
                 i.TransactionEventSeq_NUMB,
                 i.RespondentMci_IDNO,
                 i.PetitionerMci_IDNO,
                 i.DescriptionComments_TEXT,
                 COUNT(1) OVER() AS row_count,
                 ROW_NUMBER() OVER( ORDER BY i.Status_CODE DESC, i.Create_DATE DESC, i.TransactionEventSeq_NUMB DESC, i.Update_DTTM DESC) AS RecRank_NUMB
            FROM ICAS_Y1 i
                 JOIN CASE_Y1 c
                  ON i.Case_IDNO = c.Case_IDNO
                 LEFT OUTER JOIN STAT_Y1 sf
                  ON sf.StateFips_CODE = i.IVDOutOfStateFips_CODE
           WHERE i.Case_IDNO = @An_Case_IDNO
             AND i.EndValidity_DATE = @Ld_High_DATE) AS a
   WHERE a.RecRank_NUMB = @Ai_Row_NUMB;
 END; -- END OF ICAS_RETRIEVE_S13


GO
