/****** Object:  StoredProcedure [dbo].[SLSD_UPDATE_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SLSD_UPDATE_S1] (
 @Ac_Day_CODE                 CHAR(1),
 @Ac_TypeActivity_CODE        CHAR(1),
 @An_TransactionEventSeq_NUMB NUMERIC(19, 0),
 @An_OthpLocation_IDNO        NUMERIC(9, 0)
 )
AS
 /*
  *     PROCEDURE NAME    : SLSD_UPDATE_S1
  *     DESCRIPTION       : Updates the location availability details by endvalidating the record for the given weekday,location and sequence number.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 02-MAR-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Ld_High_DATE         DATE = '12/31/9999',
          @Ld_Current_DATE  DATE = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
          @Ln_RowsAffected_NUMB NUMERIC(10);

  UPDATE SLSD_Y1
     SET EndValidity_DATE = @Ld_Current_DATE
   WHERE Day_CODE = @Ac_Day_CODE
     AND OthpLocation_IDNO = @An_OthpLocation_IDNO
     AND TypeActivity_CODE = @Ac_TypeActivity_CODE
     AND EndValidity_DATE = @Ld_High_DATE
     AND TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB;

  SET @Ln_RowsAffected_NUMB = @@ROWCOUNT;

  SELECT @Ln_RowsAffected_NUMB AS RowsAffected_NUMB;
 END; -- END OF SLSD_UPDATE_S1


GO
