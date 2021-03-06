/****** Object:  StoredProcedure [dbo].[SWKS_INSERT_S2]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SWKS_INSERT_S2] (
 @An_Schedule_NUMB NUMERIC(10, 0) OUTPUT
 )
AS
 /*                                                                                              
  *     PROCEDURE NAME    : SWKS_INSERT_S2                                                      
  *     DESCRIPTION       : Insert the current date.             
  *     DEVELOPED BY      : IMP Team                                                           
  *     DEVELOPED ON      : 26-AUG-2011                                                          
  *     MODIFIED BY       :                                                                      
  *     MODIFIED ON       :                                                                      
  *     VERSION NO        : 1                                                                    
 */
 BEGIN
  DECLARE @Ld_Current_DATE DATE = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();

  INSERT  ISWKS_Y1 
        (Entered_DATE)
       VALUES ( @Ld_Current_DATE );

  SET @An_Schedule_NUMB = @@IDENTITY;
 END; --END OF  SWKS_INSERT_S1                                                                                            


GO
