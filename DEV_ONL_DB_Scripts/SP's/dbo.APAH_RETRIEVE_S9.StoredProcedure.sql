/****** Object:  StoredProcedure [dbo].[APAH_RETRIEVE_S9]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[APAH_RETRIEVE_S9](
 @An_Application_IDNO         NUMERIC(15),
 @An_MemberMci_IDNO           NUMERIC(10),
 @Ac_TypeAddress_CODE         CHAR(1) OUTPUT,
 @An_TransactionEventSeq_NUMB NUMERIC(19) OUTPUT,
 @Ac_Attn_ADDR                CHAR(40) OUTPUT,
 @As_Line1_ADDR               VARCHAR(50) OUTPUT,
 @As_Line2_ADDR               VARCHAR(50) OUTPUT,
 @Ac_City_ADDR                CHAR(28) OUTPUT,
 @Ac_State_ADDR               CHAR(2) OUTPUT,
 @Ac_Country_ADDR             CHAR(2) OUTPUT,
 @Ac_Zip_ADDR                 CHAR(15) OUTPUT,
 @Ac_MemberAddress_CODE       CHAR(1) OUTPUT,
 @Ad_AddressAsOf_DATE         DATE OUTPUT
 )
AS
 /*                    
 *     PROCEDURE NAME    : APAH_RETRIEVE_S9                    
  *     DESCRIPTION       : Retrieve Member Address Line1, Address Line2, City, State, Zip, County, Unique Sequence Number, Country, and Member Address Type for an Application ID, Member ID and Member Address Type are Mailing, Primary and Secondary Residence.                    
  *     DEVELOPED BY      : IMP Team                    
  *     DEVELOPED ON      : 02-NOV-2011           
  *     MODIFIED BY       :                     
  *     MODIFIED ON       :                     
  *     VERSION NO        : 1                    
 */
 BEGIN
  SELECT @An_TransactionEventSeq_NUMB = NULL,
         @Ac_Attn_ADDR = NULL,
         @Ac_City_ADDR = NULL,
         @Ac_Country_ADDR = NULL,
         @As_Line1_ADDR = NULL,
         @As_Line2_ADDR = NULL,
         @Ac_State_ADDR = NULL,
         @Ac_Zip_ADDR = NULL,
         @Ac_TypeAddress_CODE = NULL,
         @Ac_MemberAddress_CODE = NULL,
         @Ad_AddressAsOf_DATE = NULL;

  DECLARE	@Lc_TypeAddress_CODE CHAR(1) = 'C',  
			@Ld_High_DATE DATE = '12/31/9999';

  SELECT TOP 1 @As_Line1_ADDR = X.Line1_ADDR,
               @As_Line2_ADDR = X.Line2_ADDR,
               @Ac_City_ADDR = X.City_ADDR,
               @Ac_State_ADDR = X.State_ADDR,
               @Ac_Zip_ADDR = X.Zip_ADDR,
               @Ac_Country_ADDR = X.Country_ADDR,
               @Ac_TypeAddress_CODE = X.TypeAddress_CODE,
               @Ac_Attn_ADDR = X.Attn_ADDR,
               @Ac_MemberAddress_CODE = x.MemberAddress_CODE,
               @Ad_AddressAsOf_DATE = X.AddressAsOf_DATE,
               @An_TransactionEventSeq_NUMB = X.TransactionEventSeq_NUMB
    FROM (SELECT AP.Line1_ADDR,
                 AP.Line2_ADDR,
                 AP.City_ADDR,
                 AP.State_ADDR,
                 AP.Zip_ADDR,
                 AP.County_ADDR,
                 AP.TransactionEventSeq_NUMB,
                 AP.Country_ADDR,
                 AP.TypeAddress_CODE,
                 AP.Attn_ADDR,
                 AP.MemberAddress_CODE,
                 AP.AddressAsOf_DATE,
                 ROW_NUMBER() OVER( ORDER BY AP.TypeAddress_CODE) AS ORD_ROWNUM
            FROM APAH_Y1 AP
           WHERE AP.Application_IDNO = @An_Application_IDNO
             AND AP.MemberMci_IDNO = @An_MemberMci_IDNO
			 AND AP.TypeAddress_CODE <> @Lc_TypeAddress_CODE
             AND AP.EndValidity_DATE = @Ld_High_DATE) AS X;
 END; -- End Of APAH_RETRIEVE_S9

GO
