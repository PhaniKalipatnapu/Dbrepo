/****** Object:  StoredProcedure [dbo].[UNOT_RETRIEVE_S3]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[UNOT_RETRIEVE_S3](
 @Ac_CheckRecipient_ID   CHAR(10),
 @Ac_CheckRecipient_CODE CHAR(1),
 @Ad_Disburse_DATE       DATE,
 @An_DisburseSeq_NUMB    NUMERIC(4, 0),
 @As_DescriptionNote_TEXT        VARCHAR(4000) OUTPUT
 )
AS
 /*                                                                            
  *     PROCEDURE NAME   : UNOT_RETRIEVE_S3                                    
  *     DESCRIPTION      : This function is used to get the log notes for the given sequence event global.                                                  
  *     DEVELOPED BY     : IMP Team                                         
  *     DEVELOPED ON     : 12/10/2011                                      
  *     MODIFIED BY      :                                                    
  *     MODIFIED ON      :                                                    
  *     VERSION NO       : 1                                                  
  */
 BEGIN
  SET @As_DescriptionNote_TEXT='';

  SELECT @As_DescriptionNote_TEXT = @As_DescriptionNote_TEXT + DescriptionNote_TEXT + CHAR(10)
    FROM (SELECT @As_DescriptionNote_TEXT + SUBSTRING(a.DescriptionNote_TEXT, 1, 5000) DescriptionNote_TEXT,
                 ROW_NUMBER()OVER( ORDER BY Event_DTTM DESC, a.EventGlobalSeq_NUMB DESC) column_id
            FROM UNOT_Y1 a,
                 GLEV_Y1 b,
                 DSBH_Y1 c
           WHERE a.EventGlobalSeq_NUMB = b.EventGlobalSeq_NUMB
             AND b.EventGlobalSeq_NUMB = c.EventGlobalBeginSeq_NUMB
             AND c.CheckRecipient_ID = @Ac_CheckRecipient_ID
             AND c.CheckRecipient_CODE = @AC_CheckRecipient_CODE
             AND c.Disburse_DATE = @Ad_Disburse_DATE
             AND c.DisburseSeq_NUMB = @An_DisburseSeq_NUMB)A
   ORDER BY column_id;
 END;


GO
