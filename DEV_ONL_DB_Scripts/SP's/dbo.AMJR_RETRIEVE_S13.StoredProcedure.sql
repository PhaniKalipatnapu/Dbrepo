/****** Object:  StoredProcedure [dbo].[AMJR_RETRIEVE_S13]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[AMJR_RETRIEVE_S13] (
 @An_Case_IDNO NUMERIC(6, 0)
 )
AS
 /*
  *     PROCEDURE NAME    : AMJR_RETRIEVE_S13
  *     DESCRIPTION       : Retrieve Remedy Title,Minor Activity Description and date on which the Minor Activity is expected to be updated for a given Case.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 02-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Ld_High_DATE                   DATE = '12/31/9999',
          @Lc_ActivityMajorCASE_CODE      CHAR(4) = 'CASE',
          @Lc_StatusStrt_CODE             CHAR(4) = 'STRT',
          @Lc_SubsystemEnforcementEN_CODE CHAR(2) = 'EN';

  SELECT a1.DescriptionActivity_TEXT,
         a2.DescriptionActivity_TEXT AS DescriptionActivityMinor_TEXT,
         d1.Due_DATE
    FROM CASE_Y1 c
         JOIN DMNR_Y1 d1
          ON d1.Case_IDNO = c.Case_IDNO
         JOIN DMJR_Y1 d2
          ON d2.Case_IDNO = d1.Case_IDNO
             AND d2.MajorIntSeq_NUMB = d1.MajorIntSeq_NUMB
             AND d1.MajorIntSeq_NUMB = d2.MajorIntSeq_NUMB
         JOIN AMJR_Y1 a1
          ON a1.ActivityMajor_CODE = d2.ActivityMajor_CODE
         JOIN AMNR_Y1 a2
          ON a2.ActivityMinor_CODE = d1.ActivityMinor_CODE
   WHERE c.Case_IDNO = @An_Case_IDNO
     AND d2.Subsystem_CODE = @Lc_SubsystemEnforcementEN_CODE
     AND a1.EndValidity_DATE = @Ld_High_DATE
     AND a2.EndValidity_DATE = @Ld_High_DATE
     AND a1.Subsystem_CODE = @Lc_SubsystemEnforcementEN_CODE
     AND a1.ActivityMajor_CODE != @Lc_ActivityMajorCASE_CODE
     AND d1.Status_CODE = @Lc_StatusStrt_CODE
     AND d2.Status_CODE = @Lc_StatusStrt_CODE
   ORDER BY d1.Due_DATE DESC;
 END; --End OF AMJR_RETRIEVE_S13

GO
