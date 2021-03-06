/****** Object:  StoredProcedure [dbo].[PLIC_RETRIEVE_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[PLIC_RETRIEVE_S1] (
 @An_MemberMci_IDNO           NUMERIC(10, 0),
 @Ac_TypeLicense_CODE         CHAR(5),
 @Ac_LicenseNo_TEXT           CHAR(25),
 @An_TransactionEventSeq_NUMB NUMERIC(19, 0),
 @Ac_IssuingState_CODE        CHAR(2) OUTPUT,
 @Ac_LicenseStatus_CODE       CHAR(1) OUTPUT,
 @Ad_IssueLicense_DATE        DATE OUTPUT,
 @Ad_ExpireLicense_DATE       DATE OUTPUT,
 @Ad_SuspLicense_DATE         DATE OUTPUT,
 @Ac_Status_CODE              CHAR(2) OUTPUT,
 @Ad_Status_DATE              DATE OUTPUT,
 @Ac_SourceVerified_CODE      CHAR(3) OUTPUT,
 @Ac_WorkerUpdate_ID          CHAR(30) OUTPUT,
 @Ac_Profession_CODE          CHAR(3) OUTPUT,
 @As_Business_NAME            VARCHAR(50) OUTPUT,
 @As_Trade_NAME               VARCHAR(50) OUTPUT,
 @An_OtherParty_IDNO          NUMERIC(9, 0) OUTPUT,
 @As_OtherParty_NAME          VARCHAR(60) OUTPUT,
 @As_Line1_ADDR               VARCHAR(50) OUTPUT,
 @As_Line2_ADDR               VARCHAR(50) OUTPUT,
 @Ac_City_ADDR                CHAR(28) OUTPUT,
 @Ac_Zip_ADDR                 CHAR(15) OUTPUT,
 @Ac_State_ADDR               CHAR(2) OUTPUT,
 @Ac_Country_ADDR             CHAR(2) OUTPUT,
 @An_Phone_NUMB               NUMERIC(15, 0) OUTPUT,
 @An_Fax_NUMB                 NUMERIC(15, 0) OUTPUT
 )
AS
 /*      
  *     PROCEDURE NAME    : PLIC_RETRIEVE_S1      
  *     DESCRIPTION       : Retrieve License Details for a Member ID, License Type Code and Transaction Sequence Event.      
  *     DEVELOPED BY      : IMP Team      
  *     DEVELOPED ON      : 08-SEP-2011      
  *     MODIFIED BY       :       
  *     MODIFIED ON       :       
  *     VERSION NO        : 1      
  */
 BEGIN

  DECLARE @Ld_High_DATE DATE = '12/31/9999';

  --13767 - MLIC - MLIC screen - display issue with License Number - START -
  SELECT 
         @Ac_IssuingState_CODE = a.IssuingState_CODE,
         @Ac_LicenseStatus_CODE = a.LicenseStatus_CODE,
         @Ad_IssueLicense_DATE = a.IssueLicense_DATE,
         @Ad_ExpireLicense_DATE = a.ExpireLicense_DATE,
         @Ad_SuspLicense_DATE = a.SuspLicense_DATE,
         @Ac_Status_CODE = a.Status_CODE,
         @Ad_Status_DATE = a.Status_DATE,
         @Ac_SourceVerified_CODE = a.SourceVerified_CODE,
         @Ac_WorkerUpdate_ID = a.WorkerUpdate_ID,
         @Ac_Profession_CODE = a.Profession_CODE,
         @As_Business_NAME = a.Business_NAME,
         @As_Trade_NAME = a.Trade_NAME,
         @An_OtherParty_IDNO = b.OtherParty_IDNO,
         @As_OtherParty_NAME = b.OtherParty_NAME,
         @As_Line1_ADDR = b.Line1_ADDR,
         @As_Line2_ADDR = b.Line2_ADDR,
         @Ac_City_ADDR = b.City_ADDR,
         @Ac_Zip_ADDR = b.Zip_ADDR,
         @Ac_State_ADDR = b.State_ADDR,
         @Ac_Country_ADDR = b.Country_ADDR,
         @An_Phone_NUMB = b.Phone_NUMB,
         @An_Fax_NUMB = b.Fax_NUMB
    FROM PLIC_Y1 a
         JOIN OTHP_Y1 b
          ON a.OthpLicAgent_IDNO = b.OtherParty_IDNO
   WHERE a.MemberMci_IDNO = @An_MemberMci_IDNO
     AND a.TypeLicense_CODE = @Ac_TypeLicense_CODE
     AND a.LicenseNo_TEXT = @Ac_LicenseNo_TEXT
     AND a.EndValidity_DATE = @Ld_High_DATE
     AND b.EndValidity_DATE = @Ld_High_DATE
     AND a.TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB;
 --13767 - MLIC - MLIC screen - display issue with License Number - END -
 END; --End of PLIC_RETRIEVE_S1    

GO
