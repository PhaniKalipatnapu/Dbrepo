/****** Object:  StoredProcedure [dbo].[ANXT_RETRIEVE_S7]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[ANXT_RETRIEVE_S7] (
 @Ac_ActivityMajor_CODE       CHAR(4),
 @Ac_ActivityMinor_CODE       CHAR(5),
 @Ac_Reason_CODE              CHAR(2),
 @An_TransactionEventSeq_NUMB NUMERIC(19, 0),
 @Ac_ActivityMajorNext_CODE   CHAR(4),
 @Ac_ActivityMinorNext_CODE   CHAR(5)
 )
AS
 /*                                                                                                                
 *      PROCEDURE NAME    : ANXT_RETRIEVE_S7                                                                        
  *     DESCRIPTION       : Fetch the Major and Minor activity using the generated sequence transaction.           
  *     DEVELOPED BY      : IMP Team                                                                             
  *     DEVELOPED ON      : 09-AUG-2011                                                                     
  *     MODIFIED BY       :                                                                                        
  *     MODIFIED ON       :                                                                                        
  *     VERSION NO        : 1                                                                                      
 */
 BEGIN
  SELECT a.ActivityMajor_CODE,
         a.ActivityMinor_CODE,
         a.Reason_CODE,
         a.ParallelSeq_QNTY,
         a.ActivityOrder_QNTY,
         a.ReasonOrder_QNTY,
         a.RespManSys_CODE,
         a.ActivityMajorNext_CODE,
         a.ActivityMinorNext_CODE,
         a.Group_ID,
         a.GroupNext_ID,
         a.Function1_CODE,
         a.Action1_CODE,
         a.Reason1_CODE,
         a.Function2_CODE,
         a.Action2_CODE,
         a.Reason2_CODE,
         a.Error_CODE,
         a.Procedure_NAME,
         a.NavigateTo_CODE,
         a.CsenetComment1_TEXT,
         a.CsenetComment2_TEXT,
         a.Alert_CODE,
         a.ScannedDocuments_INDC,
         a.RejectionReason_INDC
    FROM ANXT_Y1 a
   WHERE a.ActivityMajor_CODE = @Ac_ActivityMajor_CODE
     AND a.ActivityMinor_CODE = @Ac_ActivityMinor_CODE
     AND a.Reason_CODE = @Ac_Reason_CODE
     AND a.ActivityMajorNext_CODE = @Ac_ActivityMajorNext_CODE
     AND a.ActivityMinorNext_CODE = @Ac_ActivityMinorNext_CODE
     AND a.TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB;
 END; --End Of ANXT_RETRIEVE_S7 


GO
