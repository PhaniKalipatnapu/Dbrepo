/****** Object:  StoredProcedure [dbo].[NREP_RETRIEVE_S8]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[NREP_RETRIEVE_S8] (
 @Ac_Notice_ID                CHAR(8),
 @Ac_Recipient_CODE           CHAR(2),
 @An_TransactionEventSeq_NUMB NUMERIC(19, 0)
 )
AS
 /*                                                                                                                       
  *     PROCEDURE NAME    : NREP_RETRIEVE_S8                                                                               
  *     DESCRIPTION       : Retrieve Notice Recipient details for a respective Notice,Transaction sequence and Recipient Code.
  *     DEVELOPED BY      : IMP Team                                                                                    
  *     DEVELOPED ON      : 10-AUG-2011                                                                                   
  *     MODIFIED BY       :                                                                                               
  *     MODIFIED ON       :                                                                                               
  *     VERSION NO        : 1                                                                                             
  */
 BEGIN
  SELECT N.Notice_ID,
         N.Recipient_CODE,
         N.Copies_QNTY
    FROM NREP_Y1 N
   WHERE N.Notice_ID = @Ac_Notice_ID
     AND N.Recipient_CODE = @Ac_Recipient_CODE
     AND N.TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB;
 END; -- End Of NREP_RETRIEVE_S8                                                                                                                      

GO
