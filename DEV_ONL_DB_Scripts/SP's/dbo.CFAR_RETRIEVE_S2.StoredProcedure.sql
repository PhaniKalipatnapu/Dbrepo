/****** Object:  StoredProcedure [dbo].[CFAR_RETRIEVE_S2]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CFAR_RETRIEVE_S2] (
 @Ac_Function_CODE        CHAR(3),
 @Ac_Action_CODE          CHAR(1),
 @Ac_AutomaticUpdate_INDC CHAR(1)
 )
AS
 /*
  *     PROCEDURE NAME    : CFAR_RETRIEVE_S2
  *     DESCRIPTION       : Retrieves the Reason code and the description far text for the given action code, function code according to the automatic update indc
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 11-OCT-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
  */
 BEGIN
  DECLARE @Lc_No_INDC         CHAR(1) = 'N',
          @Lc_Yes_INDC        CHAR(1) = 'Y',
          @Lc_ObsoleteNo_INDC CHAR(1) = 'N';

  SELECT DISTINCT RTRIM(LTRIM(a.Reason_CODE)) AS Reason_CODE,
         UPPER(a.DescriptionFar_TEXT) AS DescriptionFar_TEXT
    FROM CFAR_Y1 a
   WHERE a.Action_CODE = @Ac_Action_CODE
     AND a.Function_CODE = @Ac_Function_CODE
     AND ((@Ac_AutomaticUpdate_INDC = @Lc_Yes_INDC
           AND a.AutomaticUpdate_INDC IN (@Lc_Yes_INDC, @Lc_No_INDC))
           OR (a.AutomaticUpdate_INDC = @Ac_AutomaticUpdate_INDC))
     AND a.Obsolete_INDC = @Lc_ObsoleteNo_INDC
   ORDER BY DescriptionFar_TEXT;
 END; -- End of CFAR_RETRIEVE_S2

GO
