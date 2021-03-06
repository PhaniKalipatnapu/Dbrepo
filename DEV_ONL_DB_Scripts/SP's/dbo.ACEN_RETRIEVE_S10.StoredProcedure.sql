/****** Object:  StoredProcedure [dbo].[ACEN_RETRIEVE_S10]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[ACEN_RETRIEVE_S10] (
 @An_Case_IDNO                NUMERIC(6, 0),
 @An_OrderSeq_NUMB            NUMERIC(2, 0) OUTPUT,
 @Ad_BeginEnforcement_DATE    DATE OUTPUT,
 @Ac_StatusEnforce_CODE       CHAR(1) OUTPUT,
 @Ac_ReasonStatus_CODE        CHAR(2) OUTPUT,
 @Ad_BeginExempt_DATE         DATE OUTPUT,
 @Ad_EndExempt_DATE           DATE OUTPUT,
 @An_TransactionEventSeq_NUMB NUMERIC(19, 0) OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : ACEN_RETRIEVE_S10
  *     DESCRIPTION       : Retrieve Enforcement Status of the Case for a Case ID, Unique Sequence Number when end validity date is equal to high date.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 10-AUG-2011
  *     MODIFIED BY       :
  *     MODIFIED ON       :
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Ld_High_DATE DATE = '12/31/9999';

  SELECT @An_OrderSeq_NUMB = a.OrderSeq_NUMB,
         @Ad_BeginEnforcement_DATE = a.BeginEnforcement_DATE,
         @Ac_StatusEnforce_CODE = a.StatusEnforce_CODE,
         @Ac_ReasonStatus_CODE = a.ReasonStatus_CODE,
         @Ad_BeginExempt_DATE = a.BeginExempt_DATE,
         @Ad_EndExempt_DATE = a.EndExempt_DATE,
         @An_TransactionEventSeq_NUMB = a.TransactionEventSeq_NUMB
    FROM ACEN_Y1 a
   WHERE a.Case_IDNO = @An_Case_IDNO
     AND a.EndValidity_DATE = @Ld_High_DATE;
 END; --End of ACEN_RETRIEVE_S10

GO
