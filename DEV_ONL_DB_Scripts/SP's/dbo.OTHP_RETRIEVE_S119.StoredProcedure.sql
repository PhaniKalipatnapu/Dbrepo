/****** Object:  StoredProcedure [dbo].[OTHP_RETRIEVE_S119]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[OTHP_RETRIEVE_S119] (
 @An_Case_IDNO				NUMERIC(6, 0),
 @Ac_Last_NAME				CHAR(20) OUTPUT,
 @Ac_First_NAME				CHAR(16) OUTPUT,
 @Ac_Middle_NAME			CHAR(20) OUTPUT,
 @Ac_Suffix_NAME			CHAR(4) OUTPUT,
 @As_Contact_EML			VARCHAR(100) OUTPUT,
 @As_Office_NAME			VARCHAR(60) OUTPUT,
 @Ac_Attn_ADDR				CHAR(40) OUTPUT,
 @As_Line1_ADDR				CHAR(50) OUTPUT,
 @As_Line2_ADDR				CHAR(50) OUTPUT,
 @Ac_City_ADDR				CHAR(28) OUTPUT,
 @Ac_State_ADDR				CHAR(2) OUTPUT,
 @Ac_Zip_ADDR				CHAR(15) OUTPUT,
 @Ac_Country_ADDR			CHAR(2) OUTPUT,
 @An_Phone_NUMB				NUMERIC(15, 0) OUTPUT,
 @An_Fax_NUMB				NUMERIC(15, 0) OUTPUT,
 @Ac_Worker_ID				CHAR(30) OUTPUT
 )
AS
 /*    
  *     PROCEDURE NAME    : OTHP_RETRIEVE_S119    
  *     DESCRIPTION       : .    
  *     DEVELOPED BY      : IMP Team    
  *     DEVELOPED ON      : 12-AUG-2011    
  *     MODIFIED BY       :     
  *     MODIFIED ON       :     
  *     VERSION NO        : 1    
 */
 BEGIN
  SELECT @Ac_Last_NAME = NULL,
         @Ac_First_NAME = NULL,
         @Ac_Middle_NAME = NULL,
         @Ac_Suffix_NAME = NULL,
		 @As_Contact_EML = NULL,
         @As_Office_NAME = NULL,
         @Ac_Attn_ADDR = NULL,
         @As_Line1_ADDR = NULL,
         @As_Line2_ADDR = NULL,
         @Ac_City_ADDR = NULL,
         @Ac_State_ADDR = NULL,
		 @Ac_Zip_ADDR = NULL,
         @Ac_Country_ADDR = NULL,
         @An_Phone_NUMB = NULL,
         @An_Fax_NUMB = NULL,
         @Ac_Worker_ID = NULL;

  DECLARE @Ld_High_DATE DATE = '12/31/9999';

	SELECT @Ac_Last_NAME = U.Last_NAME,
			@Ac_First_NAME = U.First_NAME,
			@Ac_Middle_NAME = U.Middle_NAME,
			@Ac_Suffix_NAME = U.Suffix_NAME,
			@As_Contact_EML = U.Contact_EML,
			@As_Office_NAME = O.Office_NAME,
			@Ac_Attn_ADDR = T.Attn_ADDR,
			@As_Line1_ADDR = T.Line1_ADDR,
			@As_Line2_ADDR = T.Line2_ADDR,
			@Ac_City_ADDR = T.City_ADDR,
			@Ac_State_ADDR = T.State_ADDR,
			@Ac_Zip_ADDR = T.Zip_ADDR,
			@Ac_Country_ADDR = T.Country_ADDR,
			@An_Phone_NUMB = T.Phone_NUMB,
			@An_Fax_NUMB = T.Fax_NUMB,
			@Ac_Worker_ID = C.Worker_ID 
	FROM CASE_Y1 C, OFIC_Y1 O, OTHP_Y1 T, USEM_Y1 U
	WHERE C.Case_IDNO = @An_Case_IDNO
		AND C.Worker_ID = U.Worker_ID
		AND U.EndValidity_DATE = @Ld_High_DATE
		AND C.Office_IDNO = O.Office_IDNO
		AND O.EndValidity_DATE = @Ld_High_DATE
		AND O.OtherParty_IDNO = T.OtherParty_IDNO
		AND T.EndValidity_DATE = @Ld_High_DATE;
		
 END; -- End of OTHP_RETRIEVE_S119

GO
