/****** Object:  StoredProcedure [dbo].[OBLE_RETRIEVE_S11]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[OBLE_RETRIEVE_S11] (
 @An_Case_IDNO            NUMERIC(6, 0),
 @An_OrderSeq_NUMB        NUMERIC(2, 0),
 @An_ObligationSeq_NUMB   NUMERIC(2, 0) OUTPUT,
 @Ad_BeginObligation_DATE DATE OUTPUT,
 @Ac_TypeDebt_CODE        CHAR(2) OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : OBLE_RETRIEVE_S11
  *     DESCRIPTION       : Retrieves the Obligation details of the member from Obligation table.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 02-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
  */
 BEGIN
  SELECT @Ac_TypeDebt_CODE = NULL,
         @Ad_BeginObligation_DATE = NULL,
         @An_ObligationSeq_NUMB = NULL;

  DECLARE @Ld_High_DATE DATE = '12/31/9999';

  SELECT TOP 1 @Ad_BeginObligation_DATE = O.BeginObligation_DATE,
               @An_ObligationSeq_NUMB = O.ObligationSeq_NUMB,
               @Ac_TypeDebt_CODE = O.TypeDebt_CODE
    FROM OBLE_Y1 O
   WHERE O.Case_IDNO = @An_Case_IDNO
     AND O.OrderSeq_NUMB = @An_OrderSeq_NUMB
     AND O.EndValidity_DATE = @Ld_High_DATE;
 END; --End of OBLE_RETRIEVE_S11 

GO
