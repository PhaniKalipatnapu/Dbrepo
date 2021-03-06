/****** Object:  StoredProcedure [dbo].[AHIS_RETRIEVE_S16]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[AHIS_RETRIEVE_S16]  
(
     @An_MemberMci_IDNO		 NUMERIC(10,0),
     @As_Line1_ADDR		 VARCHAR(50)	 OUTPUT,
     @As_Line2_ADDR		 VARCHAR(50)	 OUTPUT,
     @Ac_City_ADDR		 CHAR(28)	 OUTPUT,
     @Ac_State_ADDR                   CHAR(2)  OUTPUT,
     @Ac_Zip_ADDR		 CHAR(15)	 OUTPUT,
     @Ac_Country_ADDR		 CHAR(2)	 OUTPUT,
     @Ac_Status_CODE                   CHAR(1)   OUTPUT
 )
AS

/*
 *     PROCEDURE NAME    : AHIS_RETRIEVE_S16
 *     DESCRIPTION       : Retrieve the Mailing Address of a Member Idno.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 04-AUG-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/

   BEGIN
  SELECT
       @Ac_Status_CODE = NULL,
       @Ac_City_ADDR = NULL ,
       @Ac_Country_ADDR = NULL ,
       @As_Line1_ADDR = NULL ,
       @As_Line2_ADDR = NULL ,
       @Ac_State_ADDR = NULL ,
       @Ac_Zip_ADDR = NULL ;

      DECLARE
         @Lc_AddrMailing_CODE CHAR(1) = 'M',
         @Lc_ConfirmedGood_CODE CHAR(1) = 'Y';
        
        SELECT @As_Line1_ADDR = f.Line1_ADDR, 
         @As_Line2_ADDR = f.Line2_ADDR, 
         @Ac_City_ADDR = f.City_ADDR, 
         @Ac_State_ADDR = f.State_ADDR, 
         @Ac_Zip_ADDR = f.Zip_ADDR, 
         @Ac_Country_ADDR = f.Country_ADDR, 
         @Ac_Status_CODE = f.Status_CODE
      FROM  AHIS_Y1   f
      WHERE 
           f.MemberMci_IDNO = @An_MemberMci_IDNO  
      AND  f.TypeAddress_CODE = @Lc_AddrMailing_CODE 
      AND  f.Begin_DATE = 
         (
            SELECT MAX(z.Begin_DATE) 
            FROM AHIS_Y1   z
            WHERE z.MemberMci_IDNO = @An_MemberMci_IDNO 
              AND z.TypeAddress_CODE = @Lc_AddrMailing_CODE
              AND z.Status_CODE = @Lc_ConfirmedGood_CODE
         );

                  
END ;--End of AHIS_RETRIEVE_S16
  

GO
