/****** Object:  StoredProcedure [dbo].[FFCL_RETRIEVE_S7]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[FFCL_RETRIEVE_S7] (
 @Ac_Function_CODE CHAR(3),
 @Ac_Action_CODE   CHAR(1),
 @Ac_Reason_CODE   CHAR(5)
 )
AS
 /*
  *     PROCEDURE NAME    : FFCL_RETRIEVE_S7
  *     DESCRIPTION       : Retrieve Distinct Notice Idno and Description for a Notice Idno.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 11-OCT-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
  */
 BEGIN
  DECLARE @Ld_High_DATE       DATE = '12/31/9999',
          @Lc_TableImcl_ID    CHAR(4) = 'IMCL',
          @Lc_TableSubUifs_ID CHAR(4) = 'UIFS',
          @Lc_Empty_TEXT      CHAR(1) ='';

  SELECT a.Notice_ID,
         (SELECT R.DescriptionValue_TEXT
            FROM REFM_Y1 R
           WHERE R.Table_ID = @Lc_TableImcl_ID
             AND R.TableSub_ID = @Lc_TableSubUifs_ID
             AND R.Value_CODE = a.Notice_ID) AS DescriptionValue_TEXT
    FROM FFCL_Y1 a
   WHERE a.Function_CODE = @Ac_Function_CODE
     AND a.Action_CODE = @Ac_Action_CODE
     AND a.Reason_CODE = ISNULL(@Ac_Reason_CODE,@Lc_Empty_TEXT)
     AND a.EndValidity_DATE = @Ld_High_DATE;
 END; -- End of FFCL_RETRIEVE_S7

GO
