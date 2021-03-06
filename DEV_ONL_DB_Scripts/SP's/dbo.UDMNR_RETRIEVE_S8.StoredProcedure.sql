/****** Object:  StoredProcedure [dbo].[UDMNR_RETRIEVE_S8]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[UDMNR_RETRIEVE_S8] (
 @An_Case_IDNO          NUMERIC(6, 0),
 @Ac_ActivityMajor_CODE CHAR(4),
 @Ac_Subsystem_CODE     CHAR(2),
 @Ai_DateDiff_NUMB      SMALLINT OUTPUT
 )
AS
 /*                                                                                                                                                                                                                    
  *     PROCEDURE NAME    : UDMNR_RETRIEVE_S8                                                                                                                                                                           
  *     DESCRIPTION       : Retrieve number of days between date on which the Minor Activity was inserted and Server date for a Subsystem of the Child Support system, Major Activity Code, Case ID and Forum ID.      
  *     DEVELOPED BY      : IMP Team                                                                                                                                                                                   
  *     DEVELOPED ON      : 18-AUG-2011                                                                                                                                                                                
  *     MODIFIED BY       :                                                                                                                                                                                            
  *     MODIFIED ON       :                                                                                                                                                                                            
  *     VERSION NO        : 1                                                                                                                                                                                          
 */
 BEGIN
  SET @Ai_DateDiff_NUMB = NULL;

  DECLARE @Lc_Percentage_TEXT CHAR(1) ='%';

  SELECT @Ai_DateDiff_NUMB = DATEDIFF(D, MIN(m.Entered_DATE), DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME())
    FROM DMJR_Y1 b
         JOIN UDMNR_V1 m
          ON b.Forum_IDNO = m.Forum_IDNO
             AND m.Case_IDNO = b.Case_IDNO
   WHERE b.Subsystem_CODE LIKE  ISNULL(dbo.BATCH_COMMON_SCALAR$SF_TRIM2_NULL_VARCHAR(@Ac_Subsystem_CODE), @Lc_Percentage_TEXT)
     AND b.ActivityMajor_CODE LIKE ISNULL(dbo.BATCH_COMMON_SCALAR$SF_TRIM2_NULL_VARCHAR(@Ac_ActivityMajor_CODE), @Lc_Percentage_TEXT)
     AND m.Case_IDNO = @An_Case_IDNO;
 END; --END OF UDMNR_RETRIEVE_S8


GO
