/****** Object:  StoredProcedure [dbo].[SKEY_RETRIEVE_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SKEY_RETRIEVE_S1] (
 @Ac_Screen_ID           CHAR(4),
 @Ac_SignedOnWorker_ID   CHAR(30),
 @As_XmlSearch_TEXT      VARCHAR(4000) OUTPUT,
 @Ac_ScreenFunction_CODE CHAR(10) OUTPUT
 )
AS
 /*                                                                                         
  *     PROCEDURE NAME    : SKEY_RETRIEVE_S1                                                
  *     DESCRIPTION       : Retrieves the screen function details for the respective screen.
  *     DEVELOPED BY      : IMP Team                                                        
  *     DEVELOPED ON      : 02-AUG-2011                                                     
  *     MODIFIED BY       :                                                                 
  *     MODIFIED ON       :                                                                 
  *     VERSION NO        : 1                                                               
  */
 BEGIN
  SELECT @Ac_ScreenFunction_CODE = NULL,
         @As_XmlSearch_TEXT = NULL;

  SELECT @Ac_ScreenFunction_CODE = S.ScreenFunction_CODE,
         @As_XmlSearch_TEXT = S.XmlSearch_TEXT
    FROM SKEY_Y1 S
   WHERE S.Screen_ID = @Ac_Screen_ID
     AND S.Worker_ID = @Ac_SignedOnWorker_ID;
 END; --End Of SKEY_RETRIEVE_S1      


GO
