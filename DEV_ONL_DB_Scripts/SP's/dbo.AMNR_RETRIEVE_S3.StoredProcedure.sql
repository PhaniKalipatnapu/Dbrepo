/****** Object:  StoredProcedure [dbo].[AMNR_RETRIEVE_S3]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[AMNR_RETRIEVE_S3] (
 @Ac_ActivityMinor_CODE       CHAR(5),
 @An_TransactionEventSeq_NUMB NUMERIC(19, 0),
 @Ac_CaseJournal_INDC         CHAR(1) OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : AMNR_RETRIEVE_S3
  *     DESCRIPTION       : Retrieves Case Journal Indicator from a valid record for the given Minor Activity Code 
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 23-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Ld_High_DATE DATE = '12/31/9999';

  SET @Ac_CaseJournal_INDC = NULL;

  SELECT @Ac_CaseJournal_INDC = A.CaseJournal_INDC
    FROM AMNR_Y1 A
   WHERE A.ActivityMinor_CODE = @Ac_ActivityMinor_CODE
     AND A.TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB
     AND A.EndValidity_DATE = @Ld_High_DATE;
 END; --End Of AMNR_RETRIEVE_S3

GO
