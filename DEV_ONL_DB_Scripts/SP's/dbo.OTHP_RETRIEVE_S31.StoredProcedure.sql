/****** Object:  StoredProcedure [dbo].[OTHP_RETRIEVE_S31]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[OTHP_RETRIEVE_S31] (
 @An_OtherParty_IDNO NUMERIC(9, 0),
 @Ai_Count_QNTY      INT OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : OTHP_RETRIEVE_S31
  *     DESCRIPTION       : Retrieve Record Count for an Other Party Idno, Other Party Type Code and  End valitity should be high date.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 06-OCT-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SET @Ai_Count_QNTY = NULL;

  DECLARE @Ld_High_DATE      DATE = '12/31/9999',
          @Lc_TypeOthp9_CODE CHAR(1) = '9',
          @Lc_TypeOthpE_CODE CHAR(1) = 'E',
          @Lc_TypeOthpG_CODE CHAR(1) = 'G',
          @Lc_TypeOthpI_CODE CHAR(1) = 'I',
          @Lc_TypeOthpM_CODE CHAR(1) = 'M',
          @Lc_TypeOthpS_CODE CHAR(1) = 'S',
          @Lc_TypeOthpU_CODE CHAR(1) = 'U',
          @Lc_TypeOthpW_CODE CHAR(1) = 'W',
          @Lc_TypeOthpX_CODE CHAR(1) = 'X';

  SELECT @Ai_Count_QNTY = COUNT(1)
    FROM OTHP_Y1 t
   WHERE t.OtherParty_IDNO = @An_OtherParty_IDNO
     AND t.EndValidity_DATE = @Ld_High_DATE
     AND (	t.TypeOthp_CODE IN (@Lc_TypeOthpE_CODE, @Lc_TypeOthpI_CODE, @Lc_TypeOthpM_CODE, @Lc_TypeOthpG_CODE,@Lc_TypeOthp9_CODE, @Lc_TypeOthpS_CODE, @Lc_TypeOthpX_CODE, @Lc_TypeOthpU_CODE, @Lc_TypeOthpW_CODE));
 END; --END OF OTHP_RETRIEVE_S31

GO
