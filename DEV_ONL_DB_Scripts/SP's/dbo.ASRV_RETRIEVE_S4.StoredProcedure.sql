/****** Object:  StoredProcedure [dbo].[ASRV_RETRIEVE_S4]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[ASRV_RETRIEVE_S4]  (

     @An_MemberMci_IDNO		 NUMERIC(10,0),
     @An_AssetSeq_NUMB		 NUMERIC(3,0)	 OUTPUT
     )
AS

/*
 *     PROCEDURE NAME    : ASRV_RETRIEVE_S4
 *     DESCRIPTION       : Derive NEW Unique number generated for Each Asset by retrieving the Maximum of Unique number generated for Each Asset from Registered Vehicles table for Unique number assigned by the System to the Participants.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 02-MAR-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/
   BEGIN

      SET @An_AssetSeq_NUMB = NULL;

      DECLARE
         @Ld_High_DATE  DATE = '12/31/9999';
        
      SELECT @An_AssetSeq_NUMB = ISNULL(MAX(A.AssetSeq_NUMB), 0) + 1
      FROM ASRV_Y1 A
      WHERE A.MemberMci_IDNO = @An_MemberMci_IDNO 
       AND A.EndValidity_DATE = @Ld_High_DATE;

                  
END; --END OF ASRV_RETRIEVE_S4


GO
