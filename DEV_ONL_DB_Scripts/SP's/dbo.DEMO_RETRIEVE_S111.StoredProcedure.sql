/****** Object:  StoredProcedure [dbo].[DEMO_RETRIEVE_S111]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DEMO_RETRIEVE_S111] (
 @Ad_Batch_DATE       DATE,
 @Ac_SourceBatch_CODE CHAR(3),
 @An_Batch_NUMB       NUMERIC(4, 0),
 @An_SeqReceipt_NUMB  NUMERIC(6, 0),
 @Ac_Last_NAME        CHAR(20) OUTPUT,
 @Ac_First_NAME       CHAR(16) OUTPUT,
 @Ac_Middle_NAME      CHAR(20) OUTPUT,
 @Ac_Suffix_NAME      CHAR(4 ) OUTPUT,
 @An_MemberSsn_NUMB   NUMERIC(9, 0) OUTPUT,
 @An_PayorMCI_IDNO    NUMERIC(10, 0) OUTPUT
 )
AS
 /*
  *      PROCEDURE NAME   : DEMO_RETRIEVE_S111
  *     DESCRIPTION       : Retrieves the member demographic number for the given Receipt.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 27-SEP-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
  */
 BEGIN
  SELECT @An_PayorMCI_IDNO = NULL,
         @An_MemberSsn_NUMB = NULL;

  DECLARE @Ld_High_DATE DATE = '12/31/9999';

  SELECT TOP 1 @Ac_Last_NAME = d.Last_NAME,
               @Ac_Suffix_NAME = d.Suffix_NAME,
               @Ac_First_NAME = d.First_NAME,
               @Ac_Middle_NAME = d.Middle_NAME,
               @An_MemberSsn_NUMB = d.MemberSsn_NUMB,
               @An_PayorMCI_IDNO = r.PayorMCI_IDNO
    FROM RCTH_Y1 r
         JOIN DEMO_Y1 d
          ON d.MemberMci_IDNO = r.PayorMCI_IDNO
   WHERE r.Batch_DATE = @Ad_Batch_DATE
     AND r.SourceBatch_CODE = @Ac_SourceBatch_CODE
     AND r.Batch_NUMB = @An_Batch_NUMB
     AND r.SeqReceipt_NUMB = @An_SeqReceipt_NUMB
     AND r.EndValidity_DATE = @Ld_High_DATE;
 END; --End of DEMO_RETRIEVE_S111

GO
