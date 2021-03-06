/****** Object:  StoredProcedure [dbo].[AFMS_RETRIEVE_S6]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[AFMS_RETRIEVE_S6] (
 @Ac_ActivityMajor_CODE     CHAR(4),
 @Ac_ActivityMinor_CODE     CHAR(5),
 @Ac_Reason_CODE            CHAR(2),
 @Ac_ActivityMajorNext_CODE CHAR(4),
 @Ac_ActivityMinorNext_CODE CHAR(5),
 @Ac_Notice_ID              CHAR(8),
 @Ai_RowFrom_NUMB           INT =1,
 @Ai_RowTo_NUMB             INT =10
 )
AS
 /*
 *      PROCEDURE NAME    : AFMS_RETRIEVE_S6
  *     DESCRIPTION       : Fetch  the recipients of all the document related to a Major Activity, Minor Activity and Reason when End Validity date is equal to High date.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 09-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Ld_High_DATE DATE = '12/31/9999';

  SELECT Y.Recipient_CODE,
         Y.TypeService_CODE,
         Y.TransactionEventSeq_NUMB,
         Y.PrintMethod_CODE,
         Y.RowCount_NUMB
    FROM (SELECT X.Recipient_CODE,
                 X.PrintMethod_CODE,
                 X.TypeService_CODE,
                 X.TransactionEventSeq_NUMB,
                 X.Row_NUMB,
                 X.RowCount_NUMB
            FROM (SELECT AF.Recipient_CODE,
                         AF.PrintMethod_CODE,
                         AF.TypeService_CODE,
                         AF.TransactionEventSeq_NUMB,
                         COUNT(1) OVER() AS RowCount_NUMB,
                         ROW_NUMBER() OVER ( ORDER BY Recipient_CODE ) AS Row_NUMB
                    FROM AFMS_Y1 AF
                   WHERE AF.ActivityMajor_CODE = @Ac_ActivityMajor_CODE
                     AND AF.ActivityMinor_CODE = @Ac_ActivityMinor_CODE
                     AND AF.Reason_CODE = @Ac_Reason_CODE
                     AND AF.ActivityMajorNext_CODE = @Ac_ActivityMajorNext_CODE
                     AND AF.ActivityMinorNext_CODE = @Ac_ActivityMinorNext_CODE
                     AND AF.Notice_ID = @Ac_Notice_ID
                     AND AF.EndValidity_DATE = @Ld_High_DATE) AS X
           WHERE X.Row_NUMB <= @Ai_RowTo_NUMB) AS Y
   WHERE Y.Row_NUMB >= @Ai_RowFrom_NUMB
   ORDER BY Y.Row_NUMB;
 END; --End Of AFMS_RETRIEVE_S6


GO
