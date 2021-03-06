/****** Object:  StoredProcedure [dbo].[DMJR_RETRIEVE_S50]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DMJR_RETRIEVE_S50] (
 @An_Case_IDNO          NUMERIC(6, 0),
 @Ac_ActivityMajor_CODE CHAR(4),
 @Ac_Subsystem_CODE     CHAR(2),
 @An_MajorIntSeq_NUMB   NUMERIC(5, 0) OUTPUT,
 @An_Forum_IDNO         NUMERIC(10, 0) OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : DMJR_RETRIEVE_S50
  *     DESCRIPTION       : Retrieve Forum ID and Sequence Number for the Remedy and Case/Order combination for a Case ID, Status of the Case is Start, Subsystem of the Child Support and Activity Major Code.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 04-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
  */
 BEGIN
  SELECT @An_Forum_IDNO = NULL,
         @An_MajorIntSeq_NUMB = NULL;

  DECLARE @Lc_StatusStart_CODE CHAR(4) = 'STRT';

  SELECT @An_MajorIntSeq_NUMB = b.MajorIntSeq_NUMB,
         @An_Forum_IDNO = b.Forum_IDNO
    FROM DMJR_Y1 b
   WHERE b.Case_IDNO = @An_Case_IDNO
     AND b.Status_CODE = @Lc_StatusStart_CODE
     AND b.Subsystem_CODE = @Ac_Subsystem_CODE
     AND b.ActivityMajor_CODE = @Ac_ActivityMajor_CODE;
 END; --End of DMJR_RETRIEVE_S50


GO
