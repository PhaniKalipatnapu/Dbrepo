/****** Object:  StoredProcedure [dbo].[OBLE_RETRIEVE_S16]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[OBLE_RETRIEVE_S16] (
 @An_Case_IDNO              NUMERIC(6, 0),
 @Ac_IVDOutOfStateFips_CODE CHAR(2),
 @Ai_Count_QNTY             INT OUTPUT
 )
AS
 /*
 *      PROCEDURE NAME    : OBLE_RETRIEVE_S16
  *     DESCRIPTION       : To check whether a Periodic Amount and Arrear Amount for a Case and FIPS is greater than Zero
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 04-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SET @Ai_Count_QNTY = NULL;

  DECLARE @Li_Zero_NUMB      SMALLINT = 0,
          @Ld_High_DATE      DATE = '12/31/9999',
          @Lc_Percentage_PCT CHAR(1) ='%';

  SELECT @Ai_Count_QNTY = COUNT(1)
    FROM OBLE_Y1 o
   WHERE o.Case_IDNO = @An_Case_IDNO
     AND o.Periodic_AMNT > @Li_Zero_NUMB
     AND o.EndObligation_DATE > CONVERT(DATE, DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME ())
     AND o.EndValidity_DATE = @Ld_High_DATE
     AND o.Fips_CODE LIKE ISNULL(@Ac_IVDOutOfStateFips_CODE,@Lc_Percentage_PCT);
 END -- END OF OBLE_RETRIEVE_S16

GO
