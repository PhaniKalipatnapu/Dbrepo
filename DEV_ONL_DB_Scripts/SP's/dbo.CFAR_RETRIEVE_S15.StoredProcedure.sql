/****** Object:  StoredProcedure [dbo].[CFAR_RETRIEVE_S15]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CFAR_RETRIEVE_S15] (
 @Ac_Reason_CODE CHAR(5),
 @Ai_Count_QNTY  INT OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : CFAR_RETRIEVE_S15
  *     DESCRIPTION       : To Check whether the Entered FAR Combination Reason is Valid.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 11-OCT-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
  */
 BEGIN
  SET @Ai_Count_QNTY = NULL;

  DECLARE @Lc_No_INDC    CHAR(1) = 'N',
          @Lc_Space_TEXT CHAR(1) = ' ';

  SELECT @Ai_Count_QNTY = COUNT(1)
    FROM CFAR_Y1 a
   WHERE a.Reason_CODE = ISNULL(@Ac_Reason_CODE,@Lc_Space_TEXT)
     AND a.Obsolete_INDC = @Lc_No_INDC;
 END; -- End of CFAR_RETRIEVE_S15

GO
