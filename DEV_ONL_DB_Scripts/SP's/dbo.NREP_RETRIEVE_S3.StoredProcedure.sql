/****** Object:  StoredProcedure [dbo].[NREP_RETRIEVE_S3]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[NREP_RETRIEVE_S3] (
 @Ac_Notice_ID CHAR(8)
 )
AS
 /*
  *     PROCEDURE NAME    : NREP_RETRIEVE_S3
  *     DESCRIPTION       : Retrieve the Recipient,Print Method,Service Type and Transaction sequence for a respective Notice.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 10-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Ld_High_DATE DATE = '12/31/9999';

  SELECT N.Recipient_CODE,
         N.TypeService_CODE,
         N.PrintMethod_CODE,
         N.TransactionEventSeq_NUMB
    FROM NREP_Y1 N
   WHERE N.Notice_ID = @Ac_Notice_ID
     AND N.EndValidity_DATE = @Ld_High_DATE
   ORDER BY N.Recipient_CODE;
 END; -- End Of NREP_RETRIEVE_S3

GO
