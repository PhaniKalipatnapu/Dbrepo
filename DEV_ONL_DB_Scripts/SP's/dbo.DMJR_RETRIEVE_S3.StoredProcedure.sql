/****** Object:  StoredProcedure [dbo].[DMJR_RETRIEVE_S3]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DMJR_RETRIEVE_S3](
 @An_Case_IDNO NUMERIC(6, 0),
 @Ac_Subsystem_CODE CHAR(2)
 )
AS
 /*
  *     PROCEDURE NAME    : DMJR_RETRIEVE_S3
  *     DESCRIPTION       : Retrieves the sequence number for the Remedy and Case / Order combination for the given case id 
  *							where Status of the Remedy is Start , Major Activity is not equal to CASE and Subsystem of the 
  *							Child Support system is Establishment.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 20-SEP-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Lc_ActivityMajorCase_CODE  CHAR(4) = 'CASE',
          @Lc_StatusStart_CODE        CHAR(4) = 'STRT';

  SELECT D.MajorIntSeq_NUMB
    FROM DMJR_Y1 D
   WHERE D.Case_IDNO = @An_Case_IDNO
     AND D.Status_CODE = @Lc_StatusStart_CODE
     AND D.ActivityMajor_CODE <> @Lc_ActivityMajorCase_CODE
     AND D.Subsystem_CODE = @Ac_Subsystem_CODE;
 END; -- End Of DMJR_RETRIEVE_S3

GO
