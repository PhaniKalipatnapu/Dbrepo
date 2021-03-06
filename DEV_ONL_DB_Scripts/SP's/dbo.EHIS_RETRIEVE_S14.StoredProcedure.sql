/****** Object:  StoredProcedure [dbo].[EHIS_RETRIEVE_S14]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[EHIS_RETRIEVE_S14]  (
     @An_MemberMci_IDNO		 NUMERIC(10,0)              
     )
AS

/*
 *     PROCEDURE NAME    : EHIS_RETRIEVE_S14
 *     DESCRIPTION       : Retrieves the Other Party Employee Id fro the given MemberMci Id  .
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 12/06/2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1.0
*/

 BEGIN

      DECLARE @Ld_Current_DATE DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
       SELECT E.OthpPartyEmpl_IDNO
         FROM EHIS_Y1 E
        WHERE E.MemberMci_IDNO = @An_MemberMci_IDNO 
          AND @Ld_Current_DATE BETWEEN E.BeginEmployment_DATE AND E.EndEmployment_DATE;
          
END--END OF EHIS_RETRIEVE_S14


GO
