/****** Object:  StoredProcedure [dbo].[RESF_RETRIEVE_S9]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[RESF_RETRIEVE_S9] (
 @Ac_Reason_CODE           CHAR(5),
 @Ac_Process_ID            CHAR(10),
 @Ac_Type_CODE             CHAR(5),
 @As_DescriptionValue_TEXT VARCHAR(70) OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : RESF_RETRIEVE_S9
  *     DESCRIPTION       : Retrieving the description of the reason code.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 02-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SET @As_DescriptionValue_TEXT = NULL;

  SELECT @As_DescriptionValue_TEXT = B.DescriptionValue_TEXT
    FROM RESF_Y1 A
         JOIN REFM_Y1 B
          ON B.Table_ID = A.Table_ID
             AND B.TableSub_ID = A.TableSub_ID
             AND B.Value_CODE = A.Reason_CODE
   WHERE A.Process_ID = @Ac_Process_ID
     AND A.Type_CODE = @Ac_Type_CODE
     AND A.Reason_CODE = @Ac_Reason_CODE;
 END; --End Of RESF_RETRIEVE_S9

GO
