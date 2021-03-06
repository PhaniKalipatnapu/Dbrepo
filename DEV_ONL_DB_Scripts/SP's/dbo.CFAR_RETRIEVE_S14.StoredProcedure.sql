/****** Object:  StoredProcedure [dbo].[CFAR_RETRIEVE_S14]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CFAR_RETRIEVE_S14] (
 @Ac_Function_CODE        CHAR(3),
 @Ac_Action_CODE          CHAR(1),
 @Ac_Reason_CODE          CHAR(5),
 @Ac_AutomaticUpdate_INDC CHAR(1),
 @As_DescriptionFar_TEXT  VARCHAR(1000) OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : CFAR_RETRIEVE_S14
  *     DESCRIPTION       : Retrives Reason Description for the FAR Combination Provided with Automatic Update Indication
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 11-OCT-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
  */
 BEGIN
  DECLARE @Lc_No_INDC    CHAR(1) = 'N',
          @Lc_Yes_INDC   CHAR(1) = 'Y',
          @Lc_Space_TEXT CHAR(1) = ' ';

  SELECT @As_DescriptionFar_TEXT = UPPER(DescriptionFar_TEXT)
    FROM CFAR_Y1 a
   WHERE a.Action_CODE = @Ac_Action_CODE
     AND a.Function_CODE = @Ac_Function_CODE
     AND a.Reason_CODE = ISNULL(@Ac_Reason_CODE,@Lc_Space_TEXT)
     AND ((@Ac_AutomaticUpdate_INDC = @Lc_Yes_INDC
           AND a.AutomaticUpdate_INDC IN (@Lc_Yes_INDC, @Lc_No_INDC))
           OR (a.AutomaticUpdate_INDC = @Ac_AutomaticUpdate_INDC))
     AND a.Obsolete_INDC = @Lc_No_INDC;
 END; -- End of CFAR_RETRIEVE_S14

GO
