/****** Object:  StoredProcedure [dbo].[ACES_RETRIEVE_S3]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[ACES_RETRIEVE_S3](
 @An_Case_IDNO                   NUMERIC(6),
 @An_TransactionEventSeq_NUMB    NUMERIC(19),
 @Ac_StatusEstablish_CODE        CHAR(1) OUTPUT,
 @Ad_BeginEstablishment_DATE     DATE OUTPUT,
 @An_TransactionEventSeqOut_NUMB NUMERIC(19) OUTPUT
 )
AS
 /*
 *     PROCEDURE NAME    : ACES_RETRIEVE_S3
  *     DESCRIPTION       : Gets the status of the Case in Establishment for the given Case Id, Transaction event sequence where enddate validity is highdate.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 02-MAR-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SELECT @Ac_StatusEstablish_CODE = NULL,
         @Ad_BeginEstablishment_DATE = NULL,
         @An_TransactionEventSeqOut_NUMB = NULL;

  DECLARE @Ld_High_DATE DATE = '12/31/9999';

  SELECT @Ac_StatusEstablish_CODE = AE.StatusEstablish_CODE,
         @Ad_BeginEstablishment_DATE = AE.BeginEstablishment_DATE,
         @An_TransactionEventSeqOut_NUMB = AE.TransactionEventSeq_NUMB
    FROM ACES_Y1 AE
   WHERE AE.Case_IDNO = @An_Case_IDNO
     AND AE.TransactionEventSeq_NUMB = ISNULL(@An_TransactionEventSeq_NUMB, AE.TransactionEventSeq_NUMB)
     AND AE.EndValidity_DATE = @Ld_High_DATE;
 END; --End of ACES_RETRIEVE_S3

GO
