/****** Object:  StoredProcedure [dbo].[PLIC_INSERT_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[PLIC_INSERT_S1](
 @An_MemberMci_IDNO           NUMERIC(10, 0),
 @Ac_TypeLicense_CODE         CHAR(5),
 @Ac_LicenseNo_TEXT           CHAR(25),
 @Ac_IssuingState_CODE        CHAR(2),
 @Ac_LicenseStatus_CODE       CHAR(1),
 @An_OthpLicAgent_IDNO        NUMERIC(9, 0),
 @Ad_IssueLicense_DATE        DATE,
 @Ad_ExpireLicense_DATE       DATE,
 @Ad_SuspLicense_DATE         DATE,
 @Ac_Status_CODE              CHAR(2),
 @Ad_Status_DATE              DATE,
 @Ac_SourceVerified_CODE      CHAR(3),
 @Ac_SignedOnWorker_ID        CHAR(30),
 @An_TransactionEventSeq_NUMB NUMERIC(19, 0),
 @Ac_Profession_CODE          CHAR(3),
 @As_Business_NAME            VARCHAR(50),
 @As_Trade_NAME               VARCHAR(50)
 )
AS
 /*      
  *     PROCEDURE NAME    : PLIC_INSERT_S1      
  *     DESCRIPTION       : Insert record with new Sequence Event Transaction for a Member Idno, Status Code, License Number and related information.      
  *     DEVELOPED BY      : IMP Team  
  *     DEVELOPED ON      : 23-SEP-2011      
  *     MODIFIED BY       :       
  *     MODIFIED ON       :       
  *     VERSION NO        : 1      
 */
 BEGIN
  DECLARE @Ld_Systemdatetime_DTTM DATETIME2 = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
          @Ld_High_DATE           DATE = '12/31/9999';

  INSERT INTO PLIC_Y1
              (MemberMci_IDNO,
               TypeLicense_CODE,
               LicenseNo_TEXT,
               IssuingState_CODE,
               LicenseStatus_CODE,
               OthpLicAgent_IDNO,
               IssueLicense_DATE,
               ExpireLicense_DATE,
               SuspLicense_DATE,
               Status_CODE,
               Status_DATE,
               SourceVerified_CODE,
               BeginValidity_DATE,
               EndValidity_DATE,
               WorkerUpdate_ID,
               Update_DTTM,
               TransactionEventSeq_NUMB,
               Profession_CODE,
               Business_NAME,
               Trade_NAME)
       VALUES (@An_MemberMci_IDNO,
               @Ac_TypeLicense_CODE,
               @Ac_LicenseNo_TEXT,
               @Ac_IssuingState_CODE,
               @Ac_LicenseStatus_CODE,
               @An_OthpLicAgent_IDNO,
               @Ad_IssueLicense_DATE,
               @Ad_ExpireLicense_DATE,
               @Ad_SuspLicense_DATE,
               @Ac_Status_CODE,
               @Ad_Status_DATE,
               @Ac_SourceVerified_CODE,
               @Ld_Systemdatetime_DTTM,
               @Ld_High_DATE,
               @Ac_SignedOnWorker_ID,
               @Ld_Systemdatetime_DTTM,
               @An_TransactionEventSeq_NUMB,
               @Ac_Profession_CODE,
               @As_Business_NAME,
               @As_Trade_NAME );
 END; --End of PLIC_INSERT_S1.    



GO
