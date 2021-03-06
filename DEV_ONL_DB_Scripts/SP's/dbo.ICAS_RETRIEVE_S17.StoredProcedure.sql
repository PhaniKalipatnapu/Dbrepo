/****** Object:  StoredProcedure [dbo].[ICAS_RETRIEVE_S17]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[ICAS_RETRIEVE_S17] (
 @An_Case_IDNO                    NUMERIC(6, 0),
 @Ac_IVDOutOfStateFips_CODE       CHAR(2),
 @Ac_Reason_CODE                  CHAR(5),
 @An_TransactionEventSeq_NUMB     NUMERIC(19, 0),
 @An_RespondentMci_IDNO           NUMERIC(10, 0),
 @Ac_IVDOutOfStateFile_ID         CHAR(17) OUTPUT,
 @Ac_IVDOutOfStateCase_ID         CHAR(15) OUTPUT,
 @Ac_IVDOutOfStateOfficeFips_CODE CHAR(2) OUTPUT,
 @Ac_IVDOutOfStateCountyFips_CODE CHAR(3) OUTPUT,
 @Ac_Status_CODE                  CHAR(1) OUTPUT,
 @Ad_Effective_DATE               DATE OUTPUT,
 @Ad_End_DATE                     DATE OUTPUT,
 @Ac_RespondInit_CODE             CHAR(1) OUTPUT,
 @Ac_ControlByCrtOrder_INDC       CHAR(1) OUTPUT,
 @Ad_ContOrder_DATE               DATE OUTPUT,
 @Ac_ContOrder_ID                 CHAR(15) OUTPUT,
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
 @An_County_IDNO                  NUMERIC(3, 0) OUTPUT,
 @Ac_IVDOutOfStateTypeCase_CODE   CHAR(1) OUTPUT,
 @Ad_Create_DATE                  DATE OUTPUT,
 @Ac_Worker_ID                    CHAR(30) OUTPUT,
 @Ad_Update_DTTM                  DATETIME2 OUTPUT,
 @Ac_WorkerUpdate_ID              CHAR(30) OUTPUT,
 @Ad_EndValidity_DATE             DATE OUTPUT,
 @Ad_BeginValidity_DATE           DATE OUTPUT,
 @An_PetitionerMci_IDNO           NUMERIC(10, 0) OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : ICAS_RETRIEVE_S17
  *     DESCRIPTION       : Retrieve the ICAS informations.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 04-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SELECT @Ac_IVDOutOfStateFile_ID = NULL,
         @Ac_IVDOutOfStateCase_ID = NULL,
         @Ac_IVDOutOfStateOfficeFips_CODE = NULL,
         @Ac_IVDOutOfStateCountyFips_CODE = NULL,
         @Ac_Status_CODE = NULL,
         @Ad_Effective_DATE = NULL,
         @Ad_End_DATE = NULL,
         @Ac_RespondInit_CODE = NULL,
         @Ac_ControlByCrtOrder_INDC = NULL,
         @Ad_ContOrder_DATE = NULL,
         @Ac_ContOrder_ID = NULL,
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
         @An_County_IDNO = NULL,
         @Ac_IVDOutOfStateTypeCase_CODE = NULL,
         @Ad_Create_DATE = NULL,
         @Ac_Worker_ID = NULL,
         @Ad_Update_DTTM = NULL,
         @Ac_WorkerUpdate_ID = NULL,
         @Ad_EndValidity_DATE = NULL,
         @Ad_BeginValidity_DATE = NULL,
         @An_PetitionerMci_IDNO = NULL;

  DECLARE @Ld_High_DATE DATE = '12/31/9999';

  SELECT @Ac_IVDOutOfStateFile_ID = i.IVDOutOfStateFile_ID,
         @Ac_IVDOutOfStateCase_ID = i.IVDOutOfStateCase_ID,
         @Ac_IVDOutOfStateOfficeFips_CODE = i.IVDOutOfStateOfficeFips_CODE,
         @Ac_IVDOutOfStateCountyFips_CODE = i.IVDOutOfStateCountyFips_CODE,
         @Ac_Status_CODE = i.Status_CODE,
         @Ad_Effective_DATE = i.Effective_DATE,
         @Ad_End_DATE = i.End_DATE,
         @Ac_RespondInit_CODE = i.RespondInit_CODE,
         @Ac_ControlByCrtOrder_INDC = i.ControlByCrtOrder_INDC,
         @Ad_ContOrder_DATE = i.ContOrder_DATE,
         @Ac_ContOrder_ID = i.ContOrder_ID,
         @As_Petitioner_NAME = i.Petitioner_NAME,
         @Ac_ContactFirst_NAME = i.ContactFirst_NAME,
         @As_Respondent_NAME = i.Respondent_NAME,
         @Ac_ContactLast_NAME = i.ContactLast_NAME,
         @Ac_ContactMiddle_NAME = i.ContactMiddle_NAME,
         @An_PhoneContact_NUMB = i.PhoneContact_NUMB,
         @Ad_Referral_DATE = i.Referral_DATE,
         @As_Contact_EML = i.Contact_EML,
         @An_FaxContact_NUMB = i.FaxContact_NUMB,
         @Ac_File_ID = i.File_ID,
         @An_County_IDNO = i.County_IDNO,
         @Ac_IVDOutOfStateTypeCase_CODE = i.IVDOutOfStateTypeCase_CODE,
         @Ad_Create_DATE = i.Create_DATE,
         @Ac_Worker_ID = i.Worker_ID,
         @Ad_Update_DTTM = i.Update_DTTM,
         @Ac_WorkerUpdate_ID = i.WorkerUpdate_ID,
         @Ad_EndValidity_DATE = i.EndValidity_DATE,
         @Ad_BeginValidity_DATE = i.BeginValidity_DATE,
         @An_PetitionerMci_IDNO = i.PetitionerMci_IDNO
    FROM ICAS_Y1 i
   WHERE i.Case_IDNO = @An_Case_IDNO
     AND i.IVDOutOfStateFips_CODE = @Ac_IVDOutOfStateFips_CODE
     AND i.Reason_CODE = @Ac_Reason_CODE
     AND i.TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB
     AND i.RespondentMci_IDNO=@An_RespondentMci_IDNO
     AND i.EndValidity_DATE = @Ld_High_DATE;
 END; -- END OF ICAS_RETRIEVE_S17

GO
