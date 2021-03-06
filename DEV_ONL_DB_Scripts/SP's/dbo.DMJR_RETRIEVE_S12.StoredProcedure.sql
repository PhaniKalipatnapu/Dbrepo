/****** Object:  StoredProcedure [dbo].[DMJR_RETRIEVE_S12]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DMJR_RETRIEVE_S12] (
 @An_Case_IDNO          NUMERIC(6, 0),
 @Ac_ActivityMinor_CODE CHAR(5),
 @Ac_ActivityMajor_CODE CHAR(4),
 @An_MajorIntSeq_NUMB   NUMERIC(5, 0) OUTPUT
 )
AS
 /*                                                                                                                                                                                                                                                                                      
  *     PROCEDURE NAME    : DMJR_RETRIEVE_S12                                                                                                                                                                                                                                             
  *     DESCRIPTION       : Retrieving the seq_major_int for CASE Remedy  .If -1 returned CASE Remedy has to be newly inserted
  *     DEVELOPED BY      : IMP Team                                                                                                                                                                                                                                                   
  *     DEVELOPED ON      : 31-AUG-2011                                                                                                                                                                                                                                                 
  *     MODIFIED BY       :                                                                                                                                                                                                                                                              
  *     MODIFIED ON       :                                                                                                                                                                                                                                                              
  *     VERSION NO        : 1                                                                                                                                                                                                                                                            
 */
 BEGIN
  SET @An_MajorIntSeq_NUMB = NULL;

  DECLARE @Ld_High_DATE                    DATE = '12/31/9999',
          @Lc_RemedyStatusComplete_CODE    CHAR(4) = 'COMP',
          @Lc_SubsystemCaseManagement_CODE CHAR(2) = 'CM';

  SELECT @An_MajorIntSeq_NUMB = ISNULL(MAX(A.MajorIntSeq_NUMB), -1)
    FROM DMJR_Y1 A,
         AMNR_Y1 B
   WHERE A.ActivityMajor_CODE = @Ac_ActivityMajor_CODE
     AND A.Case_IDNO = @An_Case_IDNO
     AND A.Status_CODE != @Lc_RemedyStatusComplete_CODE
     AND A.Subsystem_CODE = @Lc_SubsystemCaseManagement_CODE
     AND B.ActivityMinor_CODE = @Ac_ActivityMinor_CODE
     AND B.EndValidity_DATE = @Ld_High_DATE;
 END; --END OF DMJR_RETRIEVE_S12                                                                                                                                                                                                                                                                                  


GO
