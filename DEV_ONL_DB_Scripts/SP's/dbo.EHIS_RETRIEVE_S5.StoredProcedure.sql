/****** Object:  StoredProcedure [dbo].[EHIS_RETRIEVE_S5]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[EHIS_RETRIEVE_S5] (
 @An_MemberMci_IDNO       NUMERIC(10, 0),
 @An_OthpPartyEmpl_IDNO   NUMERIC(9, 0),
 @Ad_BeginEmployment_DATE DATE,
 @Ai_Count_QNTY           INT OUTPUT
 )
AS
 /*  
  *     PROCEDURE NAME    : EHIS_RETRIEVE_S5  
  *     DESCRIPTION       : Retrieve the Record Count if records exist for a Member Idno, Other Party Idno and Employment Begin Date.  
  *     DEVELOPED BY      : IMP Team   
  *     DEVELOPED ON      : 04-OCT-2011  
  *     MODIFIED BY       :   
  *     MODIFIED ON       :   
  *     VERSION NO        : 1  
 */
 BEGIN
  SET @Ai_Count_QNTY = NULL;

  SELECT @Ai_Count_QNTY = COUNT(1)
    FROM EHIS_Y1 a
   WHERE a.MemberMci_IDNO = @An_MemberMci_IDNO
     AND a.OthpPartyEmpl_IDNO = @An_OthpPartyEmpl_IDNO
     AND @Ad_BeginEmployment_DATE BETWEEN a.BeginEmployment_DATE AND a.EndEmployment_DATE;
 END; --END OF EHIS_RETRIEVE_S5 


GO
