/****** Object:  StoredProcedure [dbo].[ANXT_RETRIEVE_S14]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[ANXT_RETRIEVE_S14] (
 @Ac_ActivityMajor_CODE     CHAR(4),
 @Ac_ActivityMinor_CODE     CHAR(5),
 @Ac_Reason_CODE            CHAR(2),
 @Ac_ActivityMinorNext_CODE CHAR(5),
 @Ac_Error_CODE             CHAR(18) OUTPUT,
 @Ac_NavigateTo_CODE        CHAR(4) OUTPUT
 )
AS
 /*
 *      PROCEDURE NAME    : ANXT_RETRIEVE_S14
  *     DESCRIPTION       : Retrieve the Screen Name  and Warning Code to show the warning Pop Up for a   Major Activity code, Minor Activity code, Next Major Activity and Reason to upDATE the current Minor Activity.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 17-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SELECT @Ac_Error_CODE = NULL,
         @Ac_NavigateTo_CODE = NULL;

  DECLARE @Ld_High_DATE DATE = '12/31/9999';

  SELECT @Ac_Error_CODE = a.Error_CODE,
         @Ac_NavigateTo_CODE = a.NavigateTo_CODE
    FROM ANXT_Y1 a
   WHERE a.ActivityMajor_CODE = @Ac_ActivityMajor_CODE
     AND a.ActivityMinor_CODE = @Ac_ActivityMinor_CODE
     AND a.ActivityMinorNext_CODE = @Ac_ActivityMinorNext_CODE
     AND a.Reason_CODE = @Ac_Reason_CODE
     AND a.EndValidity_DATE = @Ld_High_DATE;
 END; --End of ANXT_RETRIEVE_S14 


GO
