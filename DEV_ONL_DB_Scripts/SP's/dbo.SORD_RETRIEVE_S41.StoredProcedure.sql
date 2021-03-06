/****** Object:  StoredProcedure [dbo].[SORD_RETRIEVE_S41]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SORD_RETRIEVE_S41]  (
     @An_Case_IDNO		 NUMERIC(6,0),
     @Ac_File_ID		 CHAR(10),
     @An_OrderSeq_NUMB	 NUMERIC(2,0)	 OUTPUT,
     @An_Order_IDNO		 NUMERIC(15,0)   OUTPUT
	)
AS
/*
 *     PROCEDURE NAME    : SORD_RETRIEVE_S41
 *     DESCRIPTION       : This procedure returns the sequence number from SORD_Y1 for CASE.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 22-DEC-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/
   BEGIN
        SET @An_OrderSeq_NUMB = NULL;

		DECLARE @Ld_High_DATE		DATE    = '12/31/9999';
	        
        SELECT @An_OrderSeq_NUMB = S.OrderSeq_NUMB,
			   @An_Order_IDNO    = S.Order_IDNO
			FROM SORD_Y1 S
		WHERE  S.Case_IDNO = @An_Case_IDNO 
		   AND S.File_ID = ISNULL(@Ac_File_ID,S.File_ID) 
		   AND S.EndValidity_DATE = @Ld_High_DATE;
                  
END; --END OF SORD_RETRIEVE_S41 


GO
