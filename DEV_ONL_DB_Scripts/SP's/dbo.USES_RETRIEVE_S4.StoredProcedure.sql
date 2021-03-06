/****** Object:  StoredProcedure [dbo].[USES_RETRIEVE_S4]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[USES_RETRIEVE_S4] (
 @An_TransactionEventSeq_NUMB	  NUMERIC(19),
 @As_ESignature_BIN			  VARCHAR(4000) OUTPUT
 )
AS
 /*  
  *     PROCEDURE NAME    : USES_RETRIEVE_S4  
  *     DESCRIPTION       : Retrieve the electronic signature information for a given transaction event sequence number
  *     DEVELOPED BY      : IMP Team  
  *     DEVELOPED ON      : 11-AUG-2011  
  *     MODIFIED BY       :   
  *     MODIFIED ON       :   
  *     VERSION NO        : 1.0  
  */
 BEGIN
  SET @As_ESignature_BIN = NULL;      

	SELECT TOP 1 @As_ESignature_BIN = a.ESignature_BIN FROM
		(SELECT  CONVERT(VARCHAR(4000),a.ESignature_BIN) AS ESignature_BIN
			FROM USES_Y1 a
			WHERE a.TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB
		UNION
		 SELECT  CONVERT(VARCHAR(4000),a.ESignature_BIN) AS ESignature_BIN
		 FROM HUSES_Y1 a
		 WHERE a.TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB)a;
 END

GO
