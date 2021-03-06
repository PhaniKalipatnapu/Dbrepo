/****** Object:  StoredProcedure [dbo].[AHIS_RETRIEVE_S31]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[AHIS_RETRIEVE_S31]  (

     @An_MemberMci_IDNO		NUMERIC(10,0),
     @Ac_Exists_INDC		CHAR(1)  OUTPUT
     )
AS

/*
 *     PROCEDURE NAME    : AHIS_RETRIEVE_S31
 *     DESCRIPTION       : Retrieves 'YES' when given member mci has confirmed good mailing address.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 04-NOV-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/
   BEGIN

      SET @Ac_Exists_INDC = 'N';

      DECLARE
         @Lc_AddrMailing_CODE               CHAR(1) = 'M', 
         @Lc_VerificationStatusGood_CODE    CHAR(1) = 'Y',
         @Ld_High_DATE                      DATE = '12/31/9999';
        
    SELECT @Ac_Exists_INDC = 'Y'
      FROM  AHIS_Y1 A
      WHERE A.MemberMci_IDNO = @An_MemberMci_IDNO 
       AND  A.TypeAddress_CODE = @Lc_AddrMailing_CODE 
       AND  A.Status_CODE = @Lc_VerificationStatusGood_CODE
       AND A.End_DATE = @Ld_High_DATE;

                  
END; --END OF AHIS_RETRIEVE_S31


GO
