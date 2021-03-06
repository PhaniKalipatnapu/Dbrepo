/****** Object:  StoredProcedure [dbo].[CFAR_RETRIEVE_S3]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CFAR_RETRIEVE_S3]
@Ac_AutomaticUpdate_INDC CHAR(1)
AS
 /*
  *     PROCEDURE NAME    : CFAR_RETRIEVE_S3
  *     DESCRIPTION       : Retrieve Distinct Action Code for a Locate Request based on System Update Indicator.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 04-OCT-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
  */
 BEGIN
  DECLARE @Lc_ActionRequest_CODE  CHAR(1) = 'R',
          @Lc_ActionProvide_CODE  CHAR(1) = 'P', 
          @Lc_ObsoleteNo_INDC     CHAR(1) = 'N',
          @Lc_No_INDC             CHAR(1) = 'N',
          @Lc_Yes_INDC            CHAR(1) = 'Y',
          @Lc_FunctionLocate_CODE CHAR(3) ='LO1',
          @Lc_TableSubActn_ID    CHAR(4) = 'ACTN',
          @Lc_TableInts_ID       CHAR(4) = 'INTS';

  SELECT DISTINCT a.Action_CODE,
         (SELECT R.DescriptionValue_TEXT
            FROM REFM_Y1 R
           WHERE R.Table_ID = @Lc_TableInts_ID
             AND R.TableSub_ID = @Lc_TableSubActn_ID
             AND R.Value_CODE = a.Action_CODE) AS DescriptionValue_TEXT
    FROM CFAR_Y1 a
   WHERE a.Action_CODE IN (@Lc_ActionRequest_CODE,@Lc_ActionProvide_CODE)
     AND a.Function_CODE = @Lc_FunctionLocate_CODE
     AND a.Obsolete_INDC = @Lc_ObsoleteNo_INDC
     AND ((@Ac_AutomaticUpdate_INDC = @Lc_Yes_INDC
           AND a.AutomaticUpdate_INDC IN (@Lc_Yes_INDC, @Lc_No_INDC))
           OR (a.AutomaticUpdate_INDC = @Ac_AutomaticUpdate_INDC))
   ORDER BY DescriptionValue_TEXT;
 END; -- End of CFAR_RETRIEVE_S3

GO
