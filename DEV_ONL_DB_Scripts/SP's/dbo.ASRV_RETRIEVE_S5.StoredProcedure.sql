/****** Object:  StoredProcedure [dbo].[ASRV_RETRIEVE_S5]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[ASRV_RETRIEVE_S5]  (

     @An_MemberMci_IDNO		         NUMERIC(10,0),
     @An_TransactionEventSeq_NUMB	 NUMERIC(19,0),
     @Ai_Count_QNTY                  INT   OUTPUT
     )
AS

/*
 *     PROCEDURE NAME    : ASRV_RETRIEVE_S5
 *     DESCRIPTION       : Retrieve the count of records from Registered Vehicles table for Unique number assigned by the System to the Participants and Unique Sequence Number that will be generated for any given Transaction on the Table. 
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 02-MAR-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/
   BEGIN

      SET @Ai_Count_QNTY = NULL;

      DECLARE
         @Ld_High_DATE   DATE = '12/31/9999';
        
        SELECT @Ai_Count_QNTY = COUNT(1)
      FROM ASRV_Y1 A
      WHERE A.MemberMci_IDNO = @An_MemberMci_IDNO 
       AND A.TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB 
       AND A.EndValidity_DATE = @Ld_High_DATE;

                  
END;  --END OF ASRV_RETRIEVE_S5


GO
