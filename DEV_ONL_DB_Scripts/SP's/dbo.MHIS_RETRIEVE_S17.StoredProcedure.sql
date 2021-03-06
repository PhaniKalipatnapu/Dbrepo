/****** Object:  StoredProcedure [dbo].[MHIS_RETRIEVE_S17]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[MHIS_RETRIEVE_S17](  
     @An_MemberMci_IDNO	 NUMERIC(10,0),
     @An_Case_IDNO		 NUMERIC(6,0),
     @Ad_Start_DATE		 DATE,
     @Ad_End_DATE		 DATE,
     @Ac_TypeWelfare_CODE		 CHAR(1)	 OUTPUT
     )
AS

/*
 *     PROCEDURE NAME    : MHIS_RETRIEVE_S17
 *     DESCRIPTION       : Gets the Program Type for the given Member Idno, Case Idno,
                           Date from which the given Member status is valid, and Date up to which the given Member status is valid.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 12/14/2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/
BEGIN
      SET @Ac_TypeWelfare_CODE = NULL;

      DECLARE
         @Ld_Highdate DATE =  '12/31/9999';
        
        SELECT @Ac_TypeWelfare_CODE= M.TypeWelfare_CODE
           FROM MHIS_Y1 M
         WHERE 
         M.MemberMci_IDNO = @An_MemberMci_IDNO AND 
         M.Case_IDNO = @An_Case_IDNO AND 
         M.Start_DATE = @Ad_Start_DATE AND 
         M.End_DATE = ISNULL(@Ad_End_DATE, @Ld_Highdate);
                  
END; --End of MHIS_RETRIEVE_S17


GO
