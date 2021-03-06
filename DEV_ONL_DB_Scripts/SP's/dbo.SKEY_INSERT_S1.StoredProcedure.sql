/****** Object:  StoredProcedure [dbo].[SKEY_INSERT_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SKEY_INSERT_S1] (
 @Ac_Screen_ID           CHAR(4),
 @As_XmlSearch_TEXT      VARCHAR(4000),
 @Ac_ScreenFunction_CODE CHAR(10),
 @Ac_SignedOnWorker_ID   CHAR(30)
 )
AS
 /*
  *     PROCEDURE NAME    : SKEY_INSERT_S1
  *     DESCRIPTION       : Inserts the set of key values which is used for the users to search on the screen.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 02-AUG-2011
  *     MODIFIED BY       :
  *     MODIFIED ON       :
  *     VERSION NO        : 1
  */
 BEGIN
  INSERT SKEY_Y1
         (Screen_ID,
          Worker_ID,
          Work_DTTM,
          XmlSearch_TEXT,
          ScreenFunction_CODE)
  VALUES ( @Ac_Screen_ID,
           @Ac_SignedOnWorker_ID,
           dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
           @As_XmlSearch_TEXT,
           @Ac_ScreenFunction_CODE );
 END; -- End Of Procedure SKEY_INSERT_S1

GO
