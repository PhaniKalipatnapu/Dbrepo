/****** Object:  StoredProcedure [dbo].[AHIS_RETRIEVE_S28]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[AHIS_RETRIEVE_S28]  (

     @An_MemberMci_IDNO		NUMERIC(10,0),
     @As_Line1_ADDR			VARCHAR(50)  OUTPUT,
     @As_Line2_ADDR			VARCHAR(50)  OUTPUT,
     @Ac_City_ADDR			CHAR(28)	 OUTPUT,
     @Ac_State_ADDR     	CHAR(2)      OUTPUT,
     @Ac_Zip_ADDR			CHAR(15)	 OUTPUT
     )
AS

/*
 *     PROCEDURE NAME    : AHIS_RETRIEVE_S28
 *     DESCRIPTION       : Retrieves Mailing Address which has the Status Code has Good.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 04-NOV-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/
   BEGIN

      SELECT @As_Line1_ADDR = NULL,
              @As_Line2_ADDR = NULL,
              @Ac_City_ADDR = NULL,
              @Ac_State_ADDR = NULL,
              @Ac_Zip_ADDR = NULL;

      DECLARE
         @Lc_AddrMailing_CODE               CHAR(1) = 'M', 
         @Lc_VerificationStatusGood_CODE    CHAR(1) = 'Y',
         @Ld_Current_DATE                   DATE    = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
        
        SELECT TOP 1 @As_Line1_ADDR = A.Line1_ADDR, 
         @As_Line2_ADDR = A.Line2_ADDR, 
         @Ac_City_ADDR = A.City_ADDR, 
         @Ac_State_ADDR = A.State_ADDR, 
         @Ac_Zip_ADDR = A.Zip_ADDR
      FROM  AHIS_Y1 A
      WHERE A.MemberMci_IDNO = @An_MemberMci_IDNO 
       AND  A.TypeAddress_CODE = @Lc_AddrMailing_CODE 
       AND  @Ld_Current_DATE BETWEEN A.Begin_DATE AND A.End_DATE 
       AND  A.Status_CODE = @Lc_VerificationStatusGood_CODE;

                  
END; --END OF AHIS_RETRIEVE_S28


GO
