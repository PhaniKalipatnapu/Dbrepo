/****** Object:  StoredProcedure [dbo].[SWKS_RETRIEVE_S2]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SWKS_RETRIEVE_S2] (
 @An_Case_IDNO NUMERIC(6, 0)
 )
AS
 /*
  *     PROCEDURE NAME    : SWKS_RETRIEVE_S2
  *     DESCRIPTION       : Retrieve Schedule details for a Case,Schedule date is  greater than or equal to current date and Application Status is scheduled.
  *     DEVELOPED BY      : IMP Team 
  *     DEVELOPED ON      : 04-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Lc_ActivityTypeActp_CODE CHAR(4) = 'ACTP',
          @Lc_ApptStatusSc_CODE     CHAR(2) = 'SC';

  SELECT DISTINCT S.Schedule_NUMB,
                  S.TypeActivity_CODE,
                  S.Schedule_DATE,
                  S.BeginSch_DTTM,
                  R.DescriptionValue_TEXT
    FROM SWKS_Y1 S
         LEFT OUTER JOIN REFM_Y1 R
          ON (R.Table_ID = @Lc_ActivityTypeActp_CODE
              AND R.TableSub_ID = @Lc_ActivityTypeActp_CODE
              AND R.Value_CODE = S.TypeActivity_CODE)
   WHERE S.Case_IDNO = @An_Case_IDNO
     AND S.Schedule_DATE >= CONVERT(DATE, DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME())
     AND S.ApptStatus_CODE = @Lc_ApptStatusSc_CODE
   ORDER BY R.DescriptionValue_TEXT;
 END; --End Of SWKS_RETRIEVE_S2


GO
