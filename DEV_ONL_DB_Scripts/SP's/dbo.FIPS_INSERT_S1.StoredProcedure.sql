/****** Object:  StoredProcedure [dbo].[FIPS_INSERT_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[FIPS_INSERT_S1] (
 @Ac_Fips_CODE                CHAR(7),
 @Ac_TypeAddress_CODE         CHAR(3),
 @Ac_SubTypeAddress_CODE      CHAR(3),
 @An_TransactionEventSeq_NUMB NUMERIC(19, 0),
 @Ac_StateFips_CODE           CHAR(2),
 @Ac_CountyFips_CODE          CHAR(3),
 @Ac_OfficeFips_CODE          CHAR(2),
 @Ac_Fips_NAME                CHAR(40),
 @Ac_ContactTitle_NAME        CHAR(40),
 @As_Line1_ADDR               VARCHAR(50),
 @As_Line2_ADDR               VARCHAR(50),
 @Ac_City_ADDR                CHAR(28),
 @Ac_State_ADDR               CHAR(2),
 @Ac_Country_ADDR             CHAR(2),
 @Ac_FeeCharge_INDC           CHAR(1),
 @Ac_Csenet_INDC              CHAR(1),
 @Ac_CostRecovery_INDC        CHAR(1),
 @Ac_UresaUifsa_CODE          CHAR(1),
 @Ac_Sdu_INDC                 CHAR(1),
 @Ac_SendDisbursement_INDC    CHAR(1),
 @Ac_Zip_ADDR                 CHAR(15),
 @An_Phone_NUMB               NUMERIC(15, 0),
 @An_Fax_NUMB                 NUMERIC(15, 0),
 @Ac_SignedOnWorker_ID        CHAR(30)
 )
AS
 /*
  *     PROCEDURE NAME   : FIPS_INSERT_S1
  *     DESCRIPTION      : Inserts FIPS details
  *     DEVELOPED BY     : IMP Team
  *     DEVELOPED ON     : 04-AUG-2011
  *     MODIFIED BY      : 
  *     MODIFIED ON      : 
  *     VERSION NO       : 1
 */
 BEGIN
  DECLARE @Ld_Current_DATE        DATE = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
          @Ld_Systemdatetime_DTTM DATETIME2 = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
          @Ld_EndValidity_DATE    DATE = '12/31/9999';

  INSERT FIPS_Y1
         (Fips_CODE,
          StateFips_CODE,
          CountyFips_CODE,
          OfficeFips_CODE,
          TypeAddress_CODE,
          SubTypeAddress_CODE,
          Fips_NAME,
          ContactTitle_NAME,
          Line1_ADDR,
          Line2_ADDR,
          City_ADDR,
          State_ADDR,
          Country_ADDR,
          FeeCharge_INDC,
          Csenet_INDC,
          CostRecovery_INDC,
          UresaUifsa_CODE,
          Sdu_INDC,
          SendDisbursement_INDC,
          BeginValidity_DATE,
          EndValidity_DATE,
          WorkerUpdate_ID,
          TransactionEventSeq_NUMB,
          Update_DTTM,
          Zip_ADDR,
          Phone_NUMB,
          Fax_NUMB)
  VALUES ( @Ac_Fips_CODE,
           @Ac_StateFips_CODE,
           @Ac_CountyFips_CODE,
           @Ac_OfficeFips_CODE,
           @Ac_TypeAddress_CODE,
           @Ac_SubTypeAddress_CODE,
           @Ac_Fips_NAME,
           @Ac_ContactTitle_NAME,
           @As_Line1_ADDR,
           @As_Line2_ADDR,
           @Ac_City_ADDR,
           @Ac_State_ADDR,
           @Ac_Country_ADDR,
           @Ac_FeeCharge_INDC,
           @Ac_Csenet_INDC,
           @Ac_CostRecovery_INDC,
           @Ac_UresaUifsa_CODE,
           @Ac_Sdu_INDC,
           @Ac_SendDisbursement_INDC,
           @Ld_Current_DATE,
           @Ld_EndValidity_DATE,
           @Ac_SignedOnWorker_ID,
           @An_TransactionEventSeq_NUMB,
           @Ld_Systemdatetime_DTTM,
           @Ac_Zip_ADDR,
           @An_Phone_NUMB,
           @An_Fax_NUMB );
 END; -- END OF FIPS_INSERT_S1


GO
