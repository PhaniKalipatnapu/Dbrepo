/****** Object:  StoredProcedure [dbo].[ASRV_RETRIEVE_S7]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[ASRV_RETRIEVE_S7] ( 

     @An_MemberMci_IDNO            NUMERIC(10,0),
     @Ac_Asset_CODE                CHAR(3),
     @Ac_DescriptionVin_TEXT       CHAR(20),
     @Ai_Count_QNTY                INT  OUTPUT
     )
AS

/*
 *     PROCEDURE NAME    : ASRV_RETRIEVE_S7
 *     DESCRIPTION       : Retrieve the count of records from Registered Vehicles table for Unique number assigned by the System to the Participants, Type of Asset and Vehicle Identification number.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 02-MAR-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/
   BEGIN

      SET @Ai_Count_QNTY = NULL;

      DECLARE
         @Ld_High_DATE  DATE = '12/31/9999';
        
      SELECT @Ai_Count_QNTY = COUNT(1)
      FROM ASRV_Y1 A
      WHERE A.MemberMci_IDNO = @An_MemberMci_IDNO 
       AND A.Asset_CODE = @Ac_Asset_CODE 
       AND A.DescriptionVin_TEXT = @Ac_DescriptionVin_TEXT 
       AND A.EndValidity_DATE = @Ld_High_DATE;

                  
END; --END OF ASRV_RETRIEVE_S7


GO
