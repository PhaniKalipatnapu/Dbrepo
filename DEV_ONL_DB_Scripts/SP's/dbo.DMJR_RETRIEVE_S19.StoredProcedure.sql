/****** Object:  StoredProcedure [dbo].[DMJR_RETRIEVE_S19]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DMJR_RETRIEVE_S19] (
 @An_Case_IDNO          NUMERIC(6, 0),
 @Ac_ActivityMajor_CODE CHAR(4),
 @An_MajorIntSeq_NUMB   NUMERIC(5, 0) OUTPUT,
 @Ad_BeginExempt_DATE   DATE OUTPUT,
 @Ad_EndExempt_DATE     DATE OUTPUT,
 @An_Forum_IDNO         NUMERIC(10, 0) OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : DMJR_RETRIEVE_S19
  *     DESCRIPTION       : Retrieve Exemption Starts/Started date, Exemption End date and Row Count for a Case ID, Remedy Status is Exemption, Activity Major Code and Start & End Exemption date is between System date..
  *     DEVELOPED BY      : IMP Team   
  *     DEVELOPED ON      : 02-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
  */
 BEGIN
  SELECT @Ad_BeginExempt_DATE = NULL,
         @Ad_EndExempt_DATE = NULL;

  DECLARE @Lc_StatusExempt_CODE CHAR(4) = 'EXMT',
          @Ld_Low_DATE          DATE = '01/01/0001',
          @Ld_Today_DATE        DATE = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();

  SELECT @An_MajorIntSeq_NUMB = D.MajorIntSeq_NUMB,
         @Ad_BeginExempt_DATE = D.BeginExempt_DATE,
         @Ad_EndExempt_DATE = D.EndExempt_DATE,
         @An_Forum_IDNO = D.Forum_IDNO
    FROM DMJR_Y1 D
   WHERE D.Case_IDNO = @An_Case_IDNO
     AND D.Status_CODE = @Lc_StatusExempt_CODE
     AND D.ActivityMajor_CODE = @Ac_ActivityMajor_CODE
     AND D.BeginExempt_DATE != @Ld_Low_DATE
     AND @Ld_Today_DATE BETWEEN D.BeginExempt_DATE AND D.EndExempt_DATE;
 END; --END OF DMJR_RETRIEVE_S19

GO
