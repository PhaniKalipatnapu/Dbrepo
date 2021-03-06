/****** Object:  StoredProcedure [dbo].[CSPR_INSERT_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CSPR_INSERT_S1] (
 @An_TransactionEventSeq_NUMB     NUMERIC(19, 0),
 @Ad_Generated_DATE               DATE,
 @An_Case_IDNO                    NUMERIC(6, 0),
 @Ac_IVDOutOfStateFips_CODE       CHAR(2),
 @Ac_IVDOutOfStateCountyFips_CODE CHAR(3),
 @Ac_IVDOutOfStateOfficeFips_CODE CHAR(2),
 @Ac_IVDOutOfStateCase_ID         CHAR(15),
 @Ac_ExchangeMode_INDC            CHAR(1),
 @Ac_StatusRequest_CODE           CHAR(2),
 @Ac_Form_ID                      CHAR(15),
 @As_FormWeb_URL                  VARCHAR(1000),
 @An_TransHeader_IDNO             NUMERIC(12, 0),
 @Ac_Function_CODE                CHAR(3),
 @Ac_Action_CODE                  CHAR(1),
 @Ac_Reason_CODE                  CHAR(5),
 @As_DescriptionComments_TEXT     VARCHAR(1000),
 @Ac_CaseFormer_ID                CHAR(6),
 @Ac_InsCarrier_NAME              CHAR(36),
 @Ac_InsPolicyNo_TEXT             CHAR(30),
 @Ad_Hearing_DATE                 DATE,
 @Ad_Dismissal_DATE               DATE,
 @Ad_GeneticTest_DATE             DATE,
 @Ac_Attachment_INDC              CHAR(1),
 @Ac_SignedOnWorker_ID            CHAR(30),
 @Ac_File_ID                      CHAR(15),
 @Ad_PfNoShow_DATE                DATE,
 @An_RespondentMci_IDNO           NUMERIC(10, 0),
 @Ad_ArrearComputed_DATE          DATE,
 @An_TotalInterestOwed_AMNT       NUMERIC(11, 2),
 @An_TotalArrearsOwed_AMNT        NUMERIC(11, 2),
 @An_Request_IDNO                 NUMERIC(9, 0) OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : CSPR_INSERT_S1
  *     DESCRIPTION       : Insert details into Csenet Pending Request table.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 11-OCT-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
  */
 BEGIN
  SET @An_Request_IDNO = NULL;

  DECLARE @Ld_Systemdatetime_DTTM DATETIME2 = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
          @Ld_High_DATE           DATE = '12/31/9999';

  INSERT CSPR_Y1
         (TransactionEventSeq_NUMB,
          Generated_DATE,
          Case_IDNO,
          IVDOutOfStateFips_CODE,
          IVDOutOfStateCountyFips_CODE,
          IVDOutOfStateOfficeFips_CODE,
          IVDOutOfStateCase_ID,
          ExchangeMode_INDC,
          StatusRequest_CODE,
          Form_ID,
          FormWeb_URL,
          TransHeader_IDNO,
          Function_CODE,
          Action_CODE,
          Reason_CODE,
          DescriptionComments_TEXT,
          CaseFormer_ID,
          InsCarrier_NAME,
          InsPolicyNo_TEXT,
          Hearing_DATE,
          Dismissal_DATE,
          GeneticTest_DATE,
          Attachment_INDC,
          BeginValidity_DATE,
          EndValidity_DATE,
          WorkerUpdate_ID,
          Update_DTTM,
          File_ID,
          PfNoShow_DATE,
          RespondentMci_IDNO,
          ArrearComputed_DATE,
          TotalInterestOwed_AMNT,
          TotalArrearsOwed_AMNT)
  VALUES ( @An_TransactionEventSeq_NUMB,
           @Ad_Generated_DATE,
           @An_Case_IDNO,
           @Ac_IVDOutOfStateFips_CODE,
           @Ac_IVDOutOfStateCountyFips_CODE,
           @Ac_IVDOutOfStateOfficeFips_CODE,
           @Ac_IVDOutOfStateCase_ID,
           @Ac_ExchangeMode_INDC,
           @Ac_StatusRequest_CODE,
           @Ac_Form_ID,
           @As_FormWeb_URL,
           @An_TransHeader_IDNO,
           @Ac_Function_CODE,
           @Ac_Action_CODE,
           @Ac_Reason_CODE,
           @As_DescriptionComments_TEXT,
           @Ac_CaseFormer_ID,
           @Ac_InsCarrier_NAME,
           @Ac_InsPolicyNo_TEXT,
           @Ad_Hearing_DATE,
           @Ad_Dismissal_DATE,
           @Ad_GeneticTest_DATE,
           @Ac_Attachment_INDC,
           @Ld_Systemdatetime_DTTM,
           @Ld_High_DATE,
           @Ac_SignedOnWorker_ID,
           @Ld_Systemdatetime_DTTM,
           @Ac_File_ID,
           @Ad_PfNoShow_DATE,
           @An_RespondentMci_IDNO,
           @Ad_ArrearComputed_DATE,
           @An_TotalInterestOwed_AMNT,
           @An_TotalArrearsOwed_AMNT );

  SELECT @An_Request_IDNO = SCOPE_IDENTITY();
 END; -- End of CSPR_INSERT_S1

GO
