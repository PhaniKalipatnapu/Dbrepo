/****** Object:  StoredProcedure [dbo].[DMJR_RETRIEVE_S26]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DMJR_RETRIEVE_S26] (
 @An_Case_IDNO NUMERIC(6, 0)
 )
AS
 /*
  *     PROCEDURE NAME    : DMJR_RETRIEVE_S26
  *     DESCRIPTION       : Retrieve Sequence Number for the Remedy and Case/Order combination for a Case ID, Remedy Status is start, Subsystem of the Child Support system is enforcement and Activity Major Code is not equal to Case Activity Chain.
  *     DEVELOPED BY      : IMP Team   
  *     DEVELOPED ON      : 02-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Lc_SubsystemEnforcement_CODE CHAR(3) = 'EN',
          @Lc_ActivityMajorCase_CODE    CHAR(4) = 'CASE',
          @Lc_StatusStart_CODE          CHAR(4) = 'STRT';

  SELECT D.MajorIntSeq_NUMB,
         D.ActivityMajor_CODE,
         D.Forum_IDNO,
         D.TransactionEventSeq_NUMB
    FROM DMJR_Y1 D
   WHERE D.Case_IDNO = @An_Case_IDNO
     AND D.Status_CODE = @Lc_StatusStart_CODE
     AND D.ActivityMajor_CODE <> @Lc_ActivityMajorCase_CODE
     AND D.Subsystem_CODE = @Lc_SubsystemEnforcement_CODE;
 END; --END OF DMJR_RETRIEVE_S26


GO
