/****** Object:  StoredProcedure [dbo].[MHIS_RETRIEVE_S18]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[MHIS_RETRIEVE_S18](  
     @An_MemberMci_IDNO	 NUMERIC(10,0),
     @An_Case_IDNO		 NUMERIC(6,0),
     @Ai_Count_QNTY		 INT	 OUTPUT
     )
AS

/*
 *     PROCEDURE NAME    : MHIS_RETRIEVE_S18
 *     DESCRIPTION       : Gets the record count for the given Case Idno, Member Idno where Program Type is not in Non-IVE/Foster Care.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 02-MAR-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/
BEGIN

     SET @Ai_Count_QNTY = NULL;

     DECLARE
         @Lc_WelfareTypeFosterCare CHAR(1) = 'J', 
         @Lc_WelfareTypeNonIve     CHAR(1) = 'F';
        
        SELECT @Ai_Count_QNTY = COUNT(1)
          FROM MHIS_Y1 M
         WHERE 
         M.Case_IDNO = @An_Case_IDNO AND 
         M.MemberMci_IDNO = @An_MemberMci_IDNO AND 
         M.TypeWelfare_CODE NOT IN ( @Lc_WelfareTypeNonIve, @Lc_WelfareTypeFosterCare );
                  
END; --End of MHIS_RETRIEVE_S18


GO
