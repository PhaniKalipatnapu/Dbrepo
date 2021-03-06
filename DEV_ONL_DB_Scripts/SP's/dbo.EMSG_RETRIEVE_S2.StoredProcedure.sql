/****** Object:  StoredProcedure [dbo].[EMSG_RETRIEVE_S2]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[EMSG_RETRIEVE_S2] (
 @Ac_Error_CODE               CHAR(18),
 @An_TransactionEventSeq_NUMB NUMERIC(19, 0) OUTPUT
 )
AS
 /*
  *     Procedure Name    : EMSG_RETRIEVE_S2
  *     Description       : Retrieves the Sequence Event Transaction for the given Error Code
  *     Developed By      : IMP Team 
  *     Developed On      : 03-AUG-2011
  *     Modified By       : 
  *     Modified On       : 
  *     Version No        : 1
 */
 BEGIN
  SET @An_TransactionEventSeq_NUMB = NULL;

  SELECT @An_TransactionEventSeq_NUMB = E.TransactionEventSeq_NUMB
    FROM EMSG_Y1 E
   WHERE E.Error_CODE = @Ac_Error_CODE;
 END; --End of EMSG_RETRIEVE_S2 

GO
