/****** Object:  StoredProcedure [dbo].[RESF_RETRIEVE_S10]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[RESF_RETRIEVE_S10] (
 @Ac_Process_ID  CHAR(10),
 @Ac_Type_CODE   CHAR(5),
 @Ac_Reason_CODE CHAR(5)
 )
AS
 /*
  *     PROCEDURE NAME    : RESF_RETRIEVE_S10
  *     DESCRIPTION       : Retrieve Reason Code and Minor Activity Description for a Process Idno. 
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 09-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Lc_Space_TEXT CHAR(1) = ' ',
          @Ld_High_DATE  DATE = '12/31/9999';

  SELECT R.Reason_CODE,
         A.DescriptionActivity_TEXT
    FROM RESF_Y1 R
         JOIN AMNR_Y1 A
          ON A.ActivityMinor_CODE = R.Reason_CODE
   WHERE R.Process_ID = @Ac_Process_ID
     AND R.Type_CODE = @Ac_Type_CODE
     AND R.Reason_CODE != (ISNULL (@Ac_Reason_CODE, @Lc_Space_TEXT))
     AND A.EndValidity_DATE = @Ld_High_DATE
   ORDER BY DescriptionActivity_TEXT;
 END; -- END OF RESF_RETRIEVE_S10


GO
