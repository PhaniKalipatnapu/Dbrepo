/****** Object:  StoredProcedure [dbo].[MHIS_RETRIEVE_S30]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[MHIS_RETRIEVE_S30]  
    (
		 @An_Case_IDNO		     NUMERIC(6,0),
		 @An_MemberMci_IDNO		 NUMERIC(10,0),
		 @Ad_Status_DATE         DATE,
		 @Ac_TypeWelfare_CODE	 CHAR(1) OUTPUT,
		 @Ad_Start_DATE		     DATE	 OUTPUT
     )
AS
/*
*     PROCEDURE NAME    : MHIS_RETRIEVE_S30
 *     DESCRIPTION       : Procedure that gets the current welfare status of a given case and member
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 02-SEP-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/
BEGIN

      SELECT @Ac_TypeWelfare_CODE = NULL,
             @Ad_Start_DATE = NULL;

      SELECT @Ac_TypeWelfare_CODE = A.TypeWelfare_CODE, 
             @Ad_Start_DATE = A.Start_DATE
        FROM MHIS_Y1  A
       WHERE A.Case_IDNO = @An_Case_IDNO 
         AND A.MemberMci_IDNO = @An_MemberMci_IDNO 
         AND @Ad_Status_DATE BETWEEN A.Start_DATE AND A.End_DATE;

END;--End of MHIS_RETRIEVE_S30


GO
