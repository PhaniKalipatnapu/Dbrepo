/****** Object:  StoredProcedure [dbo].[NVER_UPDATE_S2]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[NVER_UPDATE_S2] (
 @Ac_Notice_ID CHAR(8)
 )
AS
 /*                                                                                                                        
  *     PROCEDURE NAME    : NVER_UPDATE_S2                                                                                 
  *     DESCRIPTION       : Update the Transaction sequence and  XSL Boilerplate Form for a respective Notice.
  *     DEVELOPED BY      : IMP Team                                                                                     
  *     DEVELOPED ON      : 10-AUG-2011                                                                                    
  *     MODIFIED BY       :                                                                                                
  *     MODIFIED ON       :                                                                                                
  *     VERSION NO        : 1                                                                                              
  */
 BEGIN
  DECLARE @Li_Zero_NUMB         SMALLINT = 0,
          @Ln_RowsAffected_NUMB NUMERIC(10);

  UPDATE NVER_Y1
     SET End_DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME()
   WHERE Notice_ID = @Ac_Notice_ID
     AND NoticeVersion_NUMB <> @Li_Zero_NUMB
     AND CONVERT (DATE, dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME()) BETWEEN Effective_DATE AND End_DATE
     AND NoticeVersion_NUMB = (SELECT MAX(NoticeVersion_NUMB) AS expr
                                 FROM NVER_Y1 N
                                WHERE N.Notice_ID = @Ac_Notice_ID
                                  AND N.NoticeVersion_NUMB <> @Li_Zero_NUMB
                                  AND CONVERT (DATE, dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME()) BETWEEN N.Effective_DATE AND N.End_DATE);

  SET @Ln_RowsAffected_NUMB = @@ROWCOUNT;

  SELECT @Ln_RowsAffected_NUMB AS RowsAffected_NUMB;
 END; -- End Of NVER_UPDATE_S1                                                                                                                       

GO
