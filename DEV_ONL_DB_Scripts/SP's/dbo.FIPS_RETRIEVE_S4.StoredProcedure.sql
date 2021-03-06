/****** Object:  StoredProcedure [dbo].[FIPS_RETRIEVE_S4]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[FIPS_RETRIEVE_S4] (
 @Ac_Fips_CODE                   CHAR(7),
 @Ac_TypeAddress_CODE            CHAR(3),
 @Ac_SubTypeAddress_CODE         CHAR(3),
 @An_TransactionEventSeq_NUMB    NUMERIC(19, 0),
 @Ac_StateFips_CODE              CHAR(2),
 @Ac_Fips_NAME                   CHAR(40) OUTPUT,
 @Ac_ContactTitle_NAME           CHAR(40) OUTPUT,
 @As_Line1_ADDR                  VARCHAR(50) OUTPUT,
 @As_Line2_ADDR                  VARCHAR(50) OUTPUT,
 @Ac_City_ADDR                   CHAR(28) OUTPUT,
 @Ac_State_ADDR                  CHAR(2) OUTPUT,
 @Ac_Country_ADDR                CHAR(2) OUTPUT,
 @Ad_BeginValidity_DATE          DATE OUTPUT,
 @Ac_Zip_ADDR                    CHAR(15) OUTPUT,
 @An_Phone_NUMB                  NUMERIC(15, 0) OUTPUT,
 @An_Fax_NUMB                    NUMERIC(15, 0) OUTPUT,
 @Ac_TypeAddressOut_CODE         CHAR(3) OUTPUT,
 @Ac_SubTypeAddressOut_CODE      CHAR(3) OUTPUT,
 @An_TransactionEventSeqOut_NUMB NUMERIC(19, 0) OUTPUT,
 @Ac_SignedOnWorker_ID           CHAR(30) OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : FIPS_RETRIEVE_S4
  *     DESCRIPTION       : Retrives FIPS Details for a Given State and Fips with Specified addresses
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 04-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SELECT @Ad_BeginValidity_DATE = NULL,
         @An_TransactionEventSeqOut_NUMB = NULL,
         @Ac_City_ADDR = NULL,
         @As_Line2_ADDR = NULL,
         @Ac_Country_ADDR = NULL,
         @Ac_State_ADDR = NULL,
         @Ac_Zip_ADDR = NULL,
         @Ac_ContactTitle_NAME = NULL,
         @Ac_SignedOnWorker_ID = NULL,
         @Ac_Fips_NAME = NULL,
         @An_Fax_NUMB = NULL,
         @An_Phone_NUMB = NULL,
         @Ac_TypeAddressOut_CODE = NULL,
         @Ac_SubTypeAddressOut_CODE = NULL,
         @As_Line1_ADDR = NULL;

  DECLARE @Ld_High_DATE DATE = '12/31/9999';

  SELECT @Ac_Fips_NAME = X.Fips_NAME,
         @As_Line1_ADDR = X.Line1_ADDR,
         @As_Line2_ADDR = X.Line2_ADDR,
         @Ac_City_ADDR = X.City_ADDR,
         @Ac_Zip_ADDR = X.Zip_ADDR,
         @Ac_State_ADDR = X.State_ADDR,
         @Ac_Country_ADDR = X.Country_ADDR,
         @Ac_ContactTitle_NAME = X.ContactTitle_NAME,
         @An_Phone_NUMB = X.Phone_NUMB,
         @An_Fax_NUMB = X.Fax_NUMB,
         @Ad_BeginValidity_DATE = X.BeginValidity_DATE,
         @An_TransactionEventSeqOut_NUMB = X.TransactionEventSeq_NUMB,
         @Ac_SignedOnWorker_ID = X.WorkerUpdate_ID,
         @Ac_TypeAddressOut_CODE = X.TypeAddress_CODE,
         @Ac_SubTypeAddressOut_CODE = X.SubTypeAddress_CODE
    FROM (SELECT f.Fips_NAME,
                 f.Line1_ADDR,
                 f.Line2_ADDR,
                 f.City_ADDR,
                 f.Zip_ADDR,
                 f.State_ADDR,
                 f.Country_ADDR,
                 f.ContactTitle_NAME,
                 f.Phone_NUMB,
                 f.Fax_NUMB,
                 f.BeginValidity_DATE,
                 f.TransactionEventSeq_NUMB,
                 f.WorkerUpdate_ID,
                 f.TypeAddress_CODE,
                 f.SubTypeAddress_CODE
            FROM FIPS_Y1 f
           WHERE f.StateFips_CODE = @Ac_StateFips_CODE
             AND f.Fips_CODE = @Ac_Fips_CODE
             AND f.TypeAddress_CODE = ISNULL (@Ac_TypeAddress_CODE, f.TypeAddress_CODE)
             AND f.SubTypeAddress_CODE = ISNULL (@Ac_SubTypeAddress_CODE, f.SubTypeAddress_CODE)
             AND f.EndValidity_DATE = @Ld_High_DATE
             AND f.TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB) AS X;
 END; --END OF FIPS_RETRIEVE_S4 


GO
