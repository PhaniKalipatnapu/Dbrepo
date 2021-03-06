/****** Object:  StoredProcedure [dbo].[NMRQ_UPDATE_S2]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[NMRQ_UPDATE_S2] (
 @An_Barcode_NUMB NUMERIC(12, 0)
 )
AS
 /*
  *     PROCEDURE NAME    : NMRQ_UPDATE_S2
  *     DESCRIPTION       : Update the Notice Status and Inserted / Modified time for a given Notice with NonCancel Status. 
  *     DEVELOPED BY      : IMP TEAM
  *     DEVELOPED ON      : 03-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Ln_RowsAffected_NUMB       NUMERIC(10),
          @Lc_StatusNoticeCancel_CODE CHAR(1) = 'C';

  UPDATE NMRQ_Y1
     SET StatusNotice_CODE = @Lc_StatusNoticeCancel_CODE,
         Update_DTTM = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME()
   WHERE Barcode_NUMB = @An_Barcode_NUMB
     AND StatusNotice_CODE <> @Lc_StatusNoticeCancel_CODE;

  SELECT @Ln_RowsAffected_NUMB = @@ROWCOUNT;

  SELECT @Ln_RowsAffected_NUMB AS RowsAffected_NUMB;
 END; -- END OF NMRQ_UPDATE_S2

GO
