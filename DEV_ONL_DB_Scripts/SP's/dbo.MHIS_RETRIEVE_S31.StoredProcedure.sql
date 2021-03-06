/****** Object:  StoredProcedure [dbo].[MHIS_RETRIEVE_S31]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[MHIS_RETRIEVE_S31]  
(
     @An_Case_IDNO		   NUMERIC(6,0),
     @An_MemberMci_IDNO	   NUMERIC(10,0),
     @Ad_Start_DATE		   DATE,
     @Ac_TypeWelfare_CODE  CHAR(1)	 OUTPUT
     )
AS
/*
*     PROCEDURE NAME    : MHIS_RETRIEVE_S31
 *     DESCRIPTION       : Procedure that gets the previous welfare status of a given case and member.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 02-SEP-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/
BEGIN

         SET @Ac_TypeWelfare_CODE = NULL;

     DECLARE @Lc_WelfareTypeFosterCare_CODE		CHAR(1) = 'F', 
			 @Lc_WelfareTypeMedicaid_CODE		CHAR(1) = 'M', 
			 @Lc_WelfareTypeNonIve_CODE			CHAR(1) = 'J', 
			 @Lc_WelfareTypeNonTanf_CODE		CHAR(1) = 'N', 
			 @Lc_WelfareTypeTanf_CODE			CHAR(1) = 'A', 
			 @Ld_High_DATE						DATE = '12/31/9999';
        
      SELECT @Ac_TypeWelfare_CODE = a.TypeWelfare_CODE
        FROM MHIS_Y1 a
       WHERE a.Case_IDNO = @An_Case_IDNO 
         AND a.MemberMci_IDNO = @An_MemberMci_IDNO 
         AND a.TypeWelfare_CODE IN ( @Lc_WelfareTypeTanf_CODE, @Lc_WelfareTypeNonTanf_CODE, @Lc_WelfareTypeMedicaid_CODE, @Lc_WelfareTypeNonIve_CODE, @Lc_WelfareTypeFosterCare_CODE  ) 
         AND a.Start_DATE = 
						   (
							SELECT MAX(b.Start_DATE)
							FROM MHIS_Y1 b
							WHERE b.MemberMci_IDNO = a.MemberMci_IDNO 
							  AND b.Case_IDNO = a.Case_IDNO 
							  AND b.Start_DATE < ISNULL(@Ad_Start_DATE, @Ld_High_DATE)
						   );

END; --End of  MHIS_RETRIEVE_S31


GO
