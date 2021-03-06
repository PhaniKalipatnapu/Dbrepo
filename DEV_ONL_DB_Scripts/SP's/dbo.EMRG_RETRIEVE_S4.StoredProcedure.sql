/****** Object:  StoredProcedure [dbo].[EMRG_RETRIEVE_S4]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[EMRG_RETRIEVE_S4] (
 @An_OthpEmplPrimary_IDNO		NUMERIC(9,0),
 @An_OthpEmplSecondary_IDNO		NUMERIC(9,0),
 @An_TransactionEventSeq_NUMB	NUMERIC(19,0),
 @Ai_Count_QNTY		 			INT OUTPUT
 )
AS

/*
 *     PROCEDURE NAME    : EMRG_RETRIEVE_S4
 *     DESCRIPTION       : Retrieve the count of records from Employer Merge table for Unique Employer ID generated by the system as Other party ID in the system (This is the primary ID that will replace the secondary value that needs to be merged), Unique Employer ID generated by the system as Other party ID in the system (This is the ID value that will get replaced with the primary ID that needs to be merged) and Unique Sequence Number that will be generated for any given Transaction on the Table. 
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 21-DEC-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
 */
 BEGIN

   SET @Ai_Count_QNTY = NULL;

 DECLARE @Ld_High_DATE	DATE = '12/31/9999';
        
  SELECT @Ai_Count_QNTY = COUNT(1)
    FROM EMRG_Y1 a
   WHERE a.OthpEmplPrimary_IDNO = @An_OthpEmplPrimary_IDNO 
     AND a.OthpEmplSecondary_IDNO = @An_OthpEmplSecondary_IDNO 
     AND a.TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB 
     AND a.EndValidity_DATE = @Ld_High_DATE;

END; --END OF EMRG_RETRIEVE_S4


GO
