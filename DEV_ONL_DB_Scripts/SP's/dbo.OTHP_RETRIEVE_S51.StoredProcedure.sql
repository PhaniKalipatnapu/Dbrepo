/****** Object:  StoredProcedure [dbo].[OTHP_RETRIEVE_S51]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[OTHP_RETRIEVE_S51] (
 @An_OtherParty_IDNO              NUMERIC(9, 0),
 @Ac_TypeOthp_CODE                CHAR(1),
 @As_OtherParty_NAME              VARCHAR(60) OUTPUT,
 @Ac_Aka_NAME                     CHAR(30) OUTPUT,
 @Ac_Attn_ADDR                    CHAR(40) OUTPUT,
 @As_Line1_ADDR                   VARCHAR(50) OUTPUT,
 @As_Line2_ADDR                   VARCHAR(50) OUTPUT,
 @Ac_City_ADDR                    CHAR(28) OUTPUT,
 @Ac_Zip_ADDR                     CHAR(15) OUTPUT,
 @Ac_State_ADDR                   CHAR(2) OUTPUT,
 @Ac_Fips_CODE                    CHAR(7) OUTPUT,
 @Ac_Country_ADDR                 CHAR(2) OUTPUT,
 @Ac_DescriptionContactOther_TEXT CHAR(30) OUTPUT,
 @As_Contact_EML                  VARCHAR(100) OUTPUT,
 @An_Phone_NUMB                   NUMERIC(15, 0) OUTPUT,
 @An_Fax_NUMB                     NUMERIC(15, 0) OUTPUT,
 @An_Fein_IDNO                    NUMERIC(9, 0) OUTPUT,
 @An_Sein_IDNO                    NUMERIC(12, 0) OUTPUT,
 @Ac_Tribal_CODE                  CHAR(2) OUTPUT,
 @Ac_Tribal_INDC                  CHAR(1) OUTPUT
 )
AS
 /*  
  *     PROCEDURE NAME    : OTHP_RETRIEVE_S51  
  *     DESCRIPTION       : Retrieve OtherParty Details for OtherParty_IDNO,TypeOthp_CODE,EndValidity_DATE 
  *     DEVELOPED BY      : IMP TEAM  
  *     DEVELOPED ON      : 02-AUG-2011  
  *     MODIFIED BY       :   
  *     MODIFIED ON       :   
  *     VERSION NO        : 1  
 */
 BEGIN
  SELECT @As_OtherParty_NAME = NULL,
         @Ac_Attn_ADDR = NULL,
         @Ac_Aka_NAME =NULL,
         @As_Line1_ADDR = NULL,
         @As_Line2_ADDR = NULL,
         @Ac_City_ADDR = NULL,
         @Ac_Zip_ADDR = NULL,
         @Ac_State_ADDR = NULL,
         @Ac_Fips_CODE = NULL,
         @Ac_Country_ADDR = NULL,
         @Ac_DescriptionContactOther_TEXT = NULL,
         @As_Contact_EML = NULL,
         @An_Phone_NUMB = NULL,
         @An_Fax_NUMB = NULL,
         @An_Fein_IDNO = NULL,
         @An_Sein_IDNO = NULL,
         @Ac_Tribal_CODE = NULL,
         @Ac_Tribal_INDC = NULL;

  DECLARE @Ld_High_DATE DATE = '12/31/9999';

  SELECT @As_OtherParty_NAME = a.OtherParty_NAME,
         @Ac_Attn_ADDR = a.Attn_ADDR,
         @Ac_Aka_NAME =a.Aka_NAME,
         @As_Line1_ADDR = a.Line1_ADDR,
         @As_Line2_ADDR = a.Line2_ADDR,
         @Ac_City_ADDR = a.City_ADDR,
         @Ac_Zip_ADDR = a.Zip_ADDR,
         @Ac_State_ADDR = a.State_ADDR,
         @Ac_Fips_CODE = a.Fips_CODE,
         @Ac_Country_ADDR = a.Country_ADDR,
         @Ac_DescriptionContactOther_TEXT = a.DescriptionContactOther_TEXT,
         @As_Contact_EML = a.Contact_EML,
         @An_Phone_NUMB = a.Phone_NUMB,
         @An_Fax_NUMB = a.Fax_NUMB,
         @An_Fein_IDNO = a.Fein_IDNO,
         @An_Sein_IDNO = a.Sein_IDNO,
         @Ac_Tribal_CODE = a.Tribal_CODE,
         @Ac_Tribal_INDC = a.Tribal_INDC
    FROM OTHP_Y1 a
   WHERE a.OtherParty_IDNO = @An_OtherParty_IDNO
     AND (@Ac_TypeOthp_CODE IS NULL
           OR (@Ac_TypeOthp_CODE IS NOT NULL
               AND a.TypeOthp_CODE = @Ac_TypeOthp_CODE))
     AND a.EndValidity_DATE = @Ld_High_DATE;
 END; --END OF OTHP_RETRIEVE_S51   


GO
