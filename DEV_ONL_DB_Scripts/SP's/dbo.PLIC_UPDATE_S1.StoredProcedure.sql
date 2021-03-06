/****** Object:  StoredProcedure [dbo].[PLIC_UPDATE_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[PLIC_UPDATE_S1] (
 @An_MemberMci_IDNO              NUMERIC(10, 0),
 @Ac_TypeLicense_CODE            CHAR(5),
 @Ac_LicenseNo_TEXT              CHAR(25),
 @An_TransactionEventSeq_NUMB    NUMERIC(19, 0),
 @An_TransactionEventSeqNew_NUMB NUMERIC(19, 0),
 @Ac_IssuingState_CODE           CHAR(2),
 @Ac_LicenseStatus_CODE          CHAR(1),
 @An_OthpLicAgent_IDNO           NUMERIC(9, 0),
 @Ad_IssueLicense_DATE           DATE,
 @Ad_ExpireLicense_DATE          DATE,
 @Ad_SuspLicense_DATE            DATE,
 @Ac_Status_CODE                 CHAR(2),
 @Ad_Status_DATE                 DATE,
 @Ac_SourceVerified_CODE         CHAR(3),
 @Ac_SignedOnWorker_ID           CHAR(30),
 @Ac_Profession_CODE             CHAR(3),
 @As_Business_NAME               VARCHAR(50),
 @As_Trade_NAME                  VARCHAR(50)
 )
AS
 /*  
  *     PROCEDURE NAME    : PLIC_UPDATE_S1  
  *     DESCRIPTION       : Update End Validity Date to current date for member Idno, License Type Code, Transaction Event Sequence and End Validity Date.  
  *     DEVELOPED BY      : IMP Team 
  *     DEVELOPED ON      : 15-SEP-2011  
  *     MODIFIED BY       :   
  *     MODIFIED ON       :   
  *     VERSION NO        : 1  
  */
 BEGIN
  DECLARE @Ln_RowsAffected_NUMB   NUMERIC(10),
          @Ld_Systemdatetime_DTTM DATETIME2 = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
          @Ld_Current_DATE        DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
          @Ld_High_DATE           DATE ='12/31/9999';

  UPDATE PLIC_Y1
     SET EndValidity_DATE = @Ld_Current_DATE
  OUTPUT @An_MemberMci_IDNO AS MemberMci_IDNO,
         @Ac_TypeLicense_CODE AS TypeLicense_CODE,
         @Ac_LicenseNo_TEXT AS LicenseNo_TEXT,
         @Ac_IssuingState_CODE AS IssuingState_CODE,
         @Ac_LicenseStatus_CODE AS LicenseStatus_CODE,
         @An_OthpLicAgent_IDNO AS OthpLicAgent_IDNO,
         @Ad_IssueLicense_DATE AS IssueLicense_DATE,
         @Ad_ExpireLicense_DATE AS ExpireLicense_DATE,
         @Ad_SuspLicense_DATE AS SuspLicense_DATE,
         @Ac_Status_CODE AS Status_CODE,
         @Ad_Status_DATE AS Status_DATE,
         @Ac_SourceVerified_CODE AS SourceVerified_CODE,
         @Ld_Systemdatetime_DTTM AS BeginValidity_DATE,
         @Ld_High_DATE AS EndValidity_DATE,
         @Ac_SignedOnWorker_ID AS WorkerUpdate_ID,
         @Ld_Systemdatetime_DTTM AS Update_DTTM,
         @An_TransactionEventSeqNew_NUMB AS TransactionEventSeq_NUMB,
         @Ac_Profession_CODE AS Profession_CODE,
         @As_Business_NAME AS Business_NAME,
         @As_Trade_NAME AS Trade_NAME
  INTO PLIC_Y1
   WHERE MemberMci_IDNO = @An_MemberMci_IDNO
     AND TypeLicense_CODE = @Ac_TypeLicense_CODE
     AND RTRIM(LTRIM(LicenseNo_TEXT)) = @Ac_LicenseNo_TEXT
     AND TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB
     AND EndValidity_DATE = @Ld_High_DATE;

  SET @Ln_RowsAffected_NUMB = @@ROWCOUNT;

  SELECT @Ln_RowsAffected_NUMB AS RowsAffected_NUMB;
 END --End of PLIC_UPDATE_S1      

GO
