/****** Object:  StoredProcedure [dbo].[ICAS_INSERT_S2]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[ICAS_INSERT_S2] (
 @An_Case_IDNO                    NUMERIC(6, 0),
 @Ac_IVDOutOfStateFips_CODE       CHAR(2),
 @Ac_IVDOutOfStateFile_ID         CHAR(17),
 @Ac_Reason_CODE                  CHAR(5),
 @An_TransactionEventSeq_NUMB     NUMERIC(19, 0),
 @Ac_IVDOutOfStateCase_ID         CHAR(15),
 @Ac_IVDOutOfStateOfficeFips_CODE CHAR(2),
 @Ac_IVDOutOfStateCountyFips_CODE CHAR(3),
 @Ac_Status_CODE                  CHAR(1),
 @Ac_RespondInit_CODE             CHAR(1),
 @Ac_ControlByCrtOrder_INDC       CHAR(1),
 @Ac_ContOrder_ID                 CHAR(15),
 @As_Petitioner_NAME              VARCHAR(65),
 @Ac_ContactFirst_NAME            CHAR(30),
 @As_Respondent_NAME              VARCHAR(65),
 @Ac_ContactLast_NAME             CHAR(30),
 @Ac_ContactMiddle_NAME           CHAR(30),
 @An_PhoneContact_NUMB            NUMERIC(15, 0),
 @Ad_Referral_DATE                DATE,
 @As_Contact_EML                  VARCHAR(100),
 @An_FaxContact_NUMB              NUMERIC(15, 0),
 @Ac_File_ID                      CHAR(10),
 @An_County_IDNO                  NUMERIC(3, 0),
 @Ac_IVDOutOfStateTypeCase_CODE   CHAR(1),
 @Ac_Worker_ID                    CHAR(30),
 @Ac_SignedOnWorker_ID            CHAR(30),
 @An_RespondentMci_IDNO           NUMERIC(10, 0),
 @An_PetitionerMci_IDNO           NUMERIC(10, 0),
 @As_DescriptionComments_TEXT     VARCHAR(1000)
 )
AS
 /*
  *     PROCEDURE NAME    : ICAS_INSERT_S2
  *     DESCRIPTION       : Insert details into Interstate Case table.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 10-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Ld_Systemdatetime_DTTM DATETIME2 = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
          @Ld_High_DATE           DATE = '12/31/9999',
          @Ld_Low_DATE            DATE = '01/01/0001';

  INSERT ICAS_Y1
         (Case_IDNO,
          IVDOutOfStateFips_CODE,
          IVDOutOfStateFile_ID,
          Reason_CODE,
          TransactionEventSeq_NUMB,
          IVDOutOfStateCase_ID,
          IVDOutOfStateOfficeFips_CODE,
          IVDOutOfStateCountyFips_CODE,
          Status_CODE,
          Effective_DATE,
          End_DATE,
          RespondInit_CODE,
          ControlByCrtOrder_INDC,
          ContOrder_DATE,
          ContOrder_ID,
          Petitioner_NAME,
          ContactFirst_NAME,
          Respondent_NAME,
          ContactLast_NAME,
          ContactMiddle_NAME,
          PhoneContact_NUMB,
          Referral_DATE,
          Contact_EML,
          FaxContact_NUMB,
          File_ID,
          County_IDNO,
          IVDOutOfStateTypeCase_CODE,
          Create_DATE,
          Worker_ID,
          Update_DTTM,
          WorkerUpdate_ID,
          EndValidity_DATE,
          BeginValidity_DATE,
          RespondentMci_IDNO,
          PetitionerMci_IDNO,
          DescriptionComments_TEXT)
  VALUES ( @An_Case_IDNO,
           @Ac_IVDOutOfStateFips_CODE,
           @Ac_IVDOutOfStateFile_ID,
           @Ac_Reason_CODE,
           @An_TransactionEventSeq_NUMB,
           @Ac_IVDOutOfStateCase_ID,
           @Ac_IVDOutOfStateOfficeFips_CODE,
           @Ac_IVDOutOfStateCountyFips_CODE,
           @Ac_Status_CODE,
           @Ld_Systemdatetime_DTTM,
           @Ld_High_DATE,
           @Ac_RespondInit_CODE,
           @Ac_ControlByCrtOrder_INDC,
           @Ld_Systemdatetime_DTTM,
           @Ac_ContOrder_ID,
           @As_Petitioner_NAME,
           @Ac_ContactFirst_NAME,
           @As_Respondent_NAME,
           @Ac_ContactLast_NAME,
           @Ac_ContactMiddle_NAME,
           @An_PhoneContact_NUMB,
           ISNULL(@Ad_Referral_DATE, @Ld_Low_DATE),
           @As_Contact_EML,
           @An_FaxContact_NUMB,
           @Ac_File_ID,
           @An_County_IDNO,
           @Ac_IVDOutOfStateTypeCase_CODE,
           @Ld_Systemdatetime_DTTM,
           @Ac_Worker_ID,
           @Ld_Systemdatetime_DTTM,
           @Ac_SignedOnWorker_ID,
           @Ld_High_DATE,
           @Ld_Systemdatetime_DTTM,
           @An_RespondentMci_IDNO,
           @An_PetitionerMci_IDNO,
           @As_DescriptionComments_TEXT );
 END; -- END OF ICAS_INSERT_S2


GO
