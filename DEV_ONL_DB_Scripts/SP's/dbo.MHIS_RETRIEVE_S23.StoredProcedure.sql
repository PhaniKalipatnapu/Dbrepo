/****** Object:  StoredProcedure [dbo].[MHIS_RETRIEVE_S23]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[MHIS_RETRIEVE_S23](  
     @An_MemberMci_IDNO		        NUMERIC(10) ,
     @An_Case_IDNO                  NUMERIC(6)  ,
     @An_EventGlobalBeginSeq_NUMB	NUMERIC(19)	 OUTPUT
)
AS

/*
 *     PROCEDURE NAME    : MHIS_RETRIEVE_S23
 *     DESCRIPTION       : Gets the highest Global Event Sequence number for the given Member Idno.
 *     DEVELOPED BY      : IMP TEAM
 *     DEVELOPED ON      : 02-MAR-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/
BEGIN

      SET @An_EventGlobalBeginSeq_NUMB = NULL;
      
      SELECT @An_EventGlobalBeginSeq_NUMB = MAX(M.EventGlobalBeginSeq_NUMB)
      FROM   MHIS_Y1 M
      WHERE  M.MemberMci_IDNO  = @An_MemberMci_IDNO
         AND M.Case_IDNO       = @An_Case_IDNO ;
                  
END; --End of MHIS_RETRIEVE_S23 


GO
