/****** Object:  StoredProcedure [dbo].[ASFN_RETRIEVE_S9]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[ASFN_RETRIEVE_S9]  (

     @Ac_Asset_CODE                 CHAR(3),
     @An_MemberMci_IDNO             NUMERIC(10,0),
     @An_OthpAtty_IDNO              NUMERIC(9,0),
     @Ai_Count_QNTY                 INT  OUTPUT
     )
AS

/*
 *     PROCEDURE NAME    : ASFN_RETRIEVE_S9
 *     DESCRIPTION       : Retrieve the count of records from Member Financial Assets table for Unique number assigned by the System to the Participants, Type of Asset and Other Party Id of the Attorney.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 02-DEC-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/

   BEGIN

      SET @Ai_Count_QNTY = NULL;

      DECLARE
         @Ld_High_DATE     DATE='12/31/9999';
        
        SELECT @Ai_Count_QNTY = COUNT(1)
        FROM ASFN_Y1  A
        WHERE A.MemberMci_IDNO = @An_MemberMci_IDNO 
         AND A.Asset_CODE = @Ac_Asset_CODE 
         AND A.OthpAtty_IDNO = @An_OthpAtty_IDNO 
         AND A.EndValidity_DATE = @Ld_High_DATE;

                  
END;  --END OF  ASFN_RETRIEVE_S9


GO
