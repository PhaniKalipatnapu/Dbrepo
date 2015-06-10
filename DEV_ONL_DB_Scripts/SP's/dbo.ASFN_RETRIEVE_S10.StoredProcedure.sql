/****** Object:  StoredProcedure [dbo].[ASFN_RETRIEVE_S10]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[ASFN_RETRIEVE_S10]  (
     
     @Ac_Asset_CODE                 CHAR(3),
     @An_MemberMci_IDNO             NUMERIC(10,0),
     @An_TransactionEventSeq_NUMB   NUMERIC(19,0),
     @An_OthpInsFin_IDNO            NUMERIC(9,0),
     @Ac_AccountAssetNo_TEXT        CHAR(30),
     @Ai_Count_QNTY                 INT  OUTPUT
    )  
AS

/*
 *     PROCEDURE NAME    : ASFN_RETRIEVE_S10
 *     DESCRIPTION       : Retrieve the count of records from Member Financial Assets table for Unique number assigned by the System to the Participants, Type of Asset, Other Party Id of the Financial Institution or Insurance Company, Bank Account number and Unique Sequence Number that will be generated for any given Transaction on the Table NOT equal to Input's Unique Sequence Number that will be generated for any given Transaction on the Table.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 03-DEC-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/
   BEGIN

      SET @Ai_Count_QNTY = NULL;

      DECLARE
         @Ld_High_DATE    DATE = '12/31/9999';
        
        SELECT @Ai_Count_QNTY = COUNT(1)
      FROM ASFN_Y1  A
      WHERE A.MemberMci_IDNO = @An_MemberMci_IDNO 
       AND A.Asset_CODE = @Ac_Asset_CODE 
       AND A.OthpInsFin_IDNO = @An_OthpInsFin_IDNO 
       AND A.AccountAssetNo_TEXT = @Ac_AccountAssetNo_TEXT 
       AND A.TransactionEventSeq_NUMB <> @An_TransactionEventSeq_NUMB 
       AND A.EndValidity_DATE = @Ld_High_DATE;

                  
END; --END OF ASFN_RETRIEVE_S10


GO
