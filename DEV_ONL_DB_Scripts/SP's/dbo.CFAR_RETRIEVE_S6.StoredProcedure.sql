/****** Object:  StoredProcedure [dbo].[CFAR_RETRIEVE_S6]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CFAR_RETRIEVE_S6] (
 @Ac_Function_CODE        CHAR(3),
 @Ac_Action_CODE          CHAR(1),
 @Ac_Reason_CODE          CHAR(5),
 @Ac_AutomaticUpdate_INDC CHAR(1) OUTPUT,
 @Ac_RefAssist_CODE       CHAR(2) OUTPUT
 )
AS
 /*
 *     PROCEDURE NAME    : CFAR_RETRIEVE_S6
  *     DESCRIPTION       : Retrieve the Row Count for a Function Code, Action Code, System Update Indicator, and Reason Code.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 04-OCT-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SET @Ac_RefAssist_CODE = NULL;

  DECLARE 
   @Lc_ObsoleteNo_INDC CHAR(1) = 'N',
   @Lc_Empty_TEXT    CHAR(1) ='';
       

  SELECT @Ac_AutomaticUpdate_INDC = c.AutomaticUpdate_INDC,
         @Ac_RefAssist_CODE = c.RefAssist_CODE
    FROM CFAR_Y1 c
   WHERE c.Function_CODE = @Ac_Function_CODE
     AND c.Action_CODE = @Ac_Action_CODE
     AND c.Reason_CODE = ISNULL(@Ac_Reason_CODE,@Lc_Empty_TEXT)
     AND c.Obsolete_INDC = @Lc_ObsoleteNo_INDC;
 END; -- End of CFAR_RETRIEVE_S6

GO
