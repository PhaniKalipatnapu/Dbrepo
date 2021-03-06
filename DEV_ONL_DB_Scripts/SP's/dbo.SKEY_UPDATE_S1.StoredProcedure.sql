/****** Object:  StoredProcedure [dbo].[SKEY_UPDATE_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SKEY_UPDATE_S1] (
 @Ac_Screen_ID           CHAR(4),
 @As_XmlSearch_TEXT      VARCHAR(4000),
 @Ac_ScreenFunction_CODE CHAR(10),
 @Ac_SignedOnWorker_ID   CHAR(30)
 )
AS
 /*
  *     PROCEDURE NAME    : SKEY_UPDATE_S1
  *     DESCRIPTION       : Updates the search  values.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 02-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
  */
 BEGIN
 		DECLARE @Lc_Space_TEXT CHAR(1) = ' ';
 		
  UPDATE SKEY_Y1
     SET Work_DTTM = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
         XmlSearch_TEXT = @As_XmlSearch_TEXT,
         ScreenFunction_CODE = @Ac_ScreenFunction_CODE
   OUTPUT
   Deleted.Screen_ID,
   Deleted.Worker_ID,
   Deleted.Work_DTTM,
   Deleted.XmlSearch_TEXT,
   ISNULL(Deleted.ScreenFunction_CODE, @Lc_Space_TEXT)
   INTO HSKEY_Y1
   WHERE Screen_ID = @Ac_Screen_ID
     AND Worker_ID = @Ac_SignedOnWorker_ID;

  DECLARE @Ln_RowsAffected_NUMB NUMERIC(10);

  SET @Ln_RowsAffected_NUMB = @@ROWCOUNT;

  SELECT @Ln_RowsAffected_NUMB AS RowsAffected_NUMB;
 END; -- End Of SKEY_UPDATE_S1


GO
