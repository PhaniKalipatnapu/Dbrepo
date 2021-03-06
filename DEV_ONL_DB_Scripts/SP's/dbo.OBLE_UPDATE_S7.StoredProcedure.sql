/****** Object:  StoredProcedure [dbo].[OBLE_UPDATE_S7]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[OBLE_UPDATE_S7] (
 @An_Case_IDNO                NUMERIC(6, 0),
 @An_OrderSeq_NUMB            NUMERIC(2, 0),
 @Ad_BeginObligation_DATE     DATE,
 @An_MemberMci_IDNO           NUMERIC(10, 0),
 @Ac_TypeDebt_CODE            CHAR(2),
 @Ac_Fips_CODE                CHAR(7),
 @An_TransactionEventSeq_NUMB NUMERIC(19, 0)
 )
AS
 /*
  *     PROCEDURE NAME    : OBLE_UPDATE_S7
  *     DESCRIPTION       : This procedure is used to update the Obligation record in OBLE_Y1 Table.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 21-DEC-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Ld_Current_DATE      DATE = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
          @Ld_High_DATE         DATE = '12/31/9999',
          @Ln_RowsAffected_NUMB NUMERIC(10);

  UPDATE OBLE_Y1
     SET EventGlobalEndSeq_NUMB = @An_TransactionEventSeq_NUMB,
         EndValidity_DATE = @Ld_Current_DATE
   WHERE Case_IDNO = @An_Case_IDNO
     AND OrderSeq_NUMB = @An_OrderSeq_NUMB
     AND ObligationSeq_NUMB = (SELECT DISTINCT
                                      ObligationSeq_NUMB
                                 FROM OBLE_Y1 a
                                WHERE a.Case_IDNO = @An_Case_IDNO
                                  AND a.OrderSeq_NUMB = @An_OrderSeq_NUMB
                                  AND a.TypeDebt_CODE = @Ac_TypeDebt_CODE
                                  AND a.Fips_CODE = @Ac_Fips_CODE
                                  AND a.MemberMci_IDNO = @An_MemberMci_IDNO
                                  AND a.EndValidity_DATE = @Ld_High_DATE)
     AND BeginObligation_DATE = @Ad_BeginObligation_DATE
     AND EventGlobalBeginSeq_NUMB != @An_TransactionEventSeq_NUMB
     AND EndValidity_DATE = @Ld_High_DATE;

  SET @Ln_RowsAffected_NUMB = @@ROWCOUNT;

  SELECT @Ln_RowsAffected_NUMB AS RowsAffected_NUMB;
 END; --END OF OBLE_UPDATE_S7

GO
