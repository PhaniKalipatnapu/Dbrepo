/****** Object:  StoredProcedure [dbo].[OTHP_UPDATE_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[OTHP_UPDATE_S1] (
 @An_OtherParty_IDNO          NUMERIC(9, 0),
 @Ac_TypeOthp_CODE            CHAR(1),
 @An_TransactionEventSeq_NUMB NUMERIC(19, 0)
 )
AS
 /*    
  *     PROCEDURE NAME    : OTHP_UPDATE_S1
  *     DESCRIPTION       : End validating the record and Inserted / Modified for a Other Party number and Other Party TYPE.
  *     DEVELOPED BY      : IMP Team    
  *     DEVELOPED ON      : 16-AUG-2011 
  *     MODIFIED BY       :     
  *     MODIFIED ON       :     
  *     VERSION NO        : 1    
 */
 BEGIN
  DECLARE @Ld_High_DATE         DATE = '12/31/9999',
          @Ld_Current_DATE      DATE = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
          @Ln_RowsAffected_NUMB NUMERIC(10);

  UPDATE OTHP_Y1
     SET EndValidity_DATE = @Ld_Current_DATE
   WHERE OtherParty_IDNO = @An_OtherParty_IDNO
     AND TypeOthp_CODE = @Ac_TypeOthp_CODE
     AND TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB
     AND EndValidity_DATE = @Ld_High_DATE;

  SET @Ln_RowsAffected_NUMB = @@ROWCOUNT;

  SELECT @Ln_RowsAffected_NUMB AS RowsAffected_NUMB;
 END; -- END OF OTHP_UPDATE_S1


GO
