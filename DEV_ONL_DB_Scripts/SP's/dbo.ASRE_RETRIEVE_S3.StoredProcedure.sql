/****** Object:  StoredProcedure [dbo].[ASRE_RETRIEVE_S3]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[ASRE_RETRIEVE_S3]  (

     @An_MemberMci_IDNO		 NUMERIC(10,0),
     @An_AssetSeq_NUMB		 NUMERIC(3,0)	 OUTPUT
     )
AS

/*
 *     PROCEDURE NAME    : ASRE_RETRIEVE_S3
 *     DESCRIPTION       : Derive NEW Unique number generated for Each Asset by retrieving the Maximum of Unique number generated for Each Asset from Realty Assets table for Unique number assigned by the System to the Participants.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 02-MAR-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/
   BEGIN

      SET @An_AssetSeq_NUMB = NULL;

      DECLARE
         @Ld_High_DATE    DATE = '12/31/9999';
        
      SELECT @An_AssetSeq_NUMB = ISNULL(MAX(A.AssetSeq_NUMB), 0) + 1
      FROM ASRE_Y1 A
      WHERE A.MemberMci_IDNO = @An_MemberMci_IDNO 
       AND A.EndValidity_DATE = @Ld_High_DATE;

                  
END; --END OF ASRE_RETRIEVE_S3


GO
