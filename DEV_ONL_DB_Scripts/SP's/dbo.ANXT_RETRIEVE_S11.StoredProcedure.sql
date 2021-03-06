/****** Object:  StoredProcedure [dbo].[ANXT_RETRIEVE_S11]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[ANXT_RETRIEVE_S11] (
 @Ac_ActivityMajor_CODE CHAR(4),
 @Ac_ActivityMinor_CODE CHAR(5)
 )
AS
 /*    
  *     PROCEDURE NAME    : ANXT_RETRIEVE_S11    
  *     DESCRIPTION       : Retrieve Minor Activity Update Reason, Next Major Activity code, Next Minor Activity code, Reference table value's description for a Major and Minor Activity Code.    
  *     DEVELOPED BY      : IMP Team    
  *     DEVELOPED ON      : 10-AUG-2011    
  *     MODIFIED BY       :     
  *     MODIFIED ON       :     
  *     VERSION NO        : 1    
  */
 BEGIN
  DECLARE @Lc_RespManSysSystem_CODE   CHAR(1) = 'S',
          @Lc_ActivityMajorCclo_CODE  CHAR(4) = 'CCLO',
          @Lc_ActivityMinorCsfcc_CODE CHAR(5) = 'CSFCC',
          @Ld_High_DATE               DATE = '12/31/9999';

  SELECT X.ActivityMajorNext_CODE,
         X.ActivityMinorNext_CODE,
         X.Reason_CODE
    FROM (SELECT n.Reason_CODE,
                 n.ParallelSeq_QNTY,
                 n.ReasonOrder_QNTY,
                 n.ActivityMajorNext_CODE,
                 n.ActivityMinorNext_CODE
            FROM ANXT_Y1 n
           WHERE n.ActivityMajor_CODE = @Ac_ActivityMajor_CODE
             AND n.ActivityMinor_CODE = @Ac_ActivityMinor_CODE
             AND n.EndValidity_DATE = @Ld_High_DATE
          EXCEPT
          (SELECT n.Reason_CODE,
                  n.ParallelSeq_QNTY,
                  n.ReasonOrder_QNTY,
                  n.ActivityMajorNext_CODE,
                  n.ActivityMinorNext_CODE
             FROM ANXT_Y1 n
            WHERE n.ActivityMajor_CODE = @Lc_ActivityMajorCclo_CODE
              AND n.ActivityMinor_CODE = @Lc_ActivityMinorCsfcc_CODE
              AND n.EndValidity_DATE = @Ld_High_DATE
              AND n.RespManSys_CODE = @Lc_RespManSysSystem_CODE)) AS X
   ORDER BY X.ReasonOrder_QNTY,
            X.ParallelSeq_QNTY;
 END; -- End of ANXT_RETRIEVE_S11


GO
