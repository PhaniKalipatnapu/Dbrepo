/****** Object:  StoredProcedure [dbo].[RESF_RETRIEVE_S14]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[RESF_RETRIEVE_S14] (
 @Ac_Type_CODE   CHAR(5),
 @Ac_Reason_CODE CHAR(5),
 @Ai_Count_QNTY  INT OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : RESF_RETRIEVE_S14
  *     DESCRIPTION       : Retrieve the Row Count for Type Code, a Table Idno is SLTP, Process Idno is ALTP, and Reason Code is the Other Party Type which was retrieved by the previous action.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 02-MAR-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SET @Ai_Count_QNTY = NULL;

  DECLARE @Lc_ProcessAltp_ID CHAR(4) = 'ALTP',
          @Lc_TableSltp_ID   CHAR(4) = 'SLTP';

  SELECT @Ai_Count_QNTY = COUNT(1)
    FROM RESF_Y1 R
   WHERE R.Table_ID = @Lc_TableSltp_ID
     AND R.Process_ID = @Lc_ProcessAltp_ID
     AND R.Reason_CODE = @Ac_Reason_CODE
     AND R.Type_CODE = @Ac_Type_CODE;
 END; --END OF  RESF_RETRIEVE_S14


GO
