/****** Object:  StoredProcedure [dbo].[DMNR_RETRIEVE_S3]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DMNR_RETRIEVE_S3] (
 @An_Case_IDNO      NUMERIC(6, 0),
 @An_MemberMci_IDNO NUMERIC(10, 0),
 @Ai_Count_QNTY     INT OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : DMNR_RETRIEVE_S3
  *     DESCRIPTION       : Retrieve the count of records from Minor Activity Diary table for the retrieved Active Dependant's (D) Case and Member whose Code with in the system for the Minor Activity equal to Case Selected as Eligible for Emancipation (EMANI) and Current Status of the Minor Activity equal to START (STRT).
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 23-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
  */
 BEGIN
  SET @Ai_Count_QNTY = NULL;

  DECLARE @Lc_StatusStart_CODE               CHAR(4) = 'STRT',
          @Lc_ActivityMinorEmancipation_CODE CHAR(5) = 'RNEMD';

  SELECT @Ai_Count_QNTY = COUNT(1)
    FROM DMNR_Y1 A
   WHERE A.Case_IDNO = @An_Case_IDNO
     AND A.MemberMci_IDNO = @An_MemberMci_IDNO
     AND A.ActivityMinor_CODE = @Lc_ActivityMinorEmancipation_CODE
     AND A.Status_CODE = @Lc_StatusStart_CODE;
 END; -- End of DMNR_RETRIEVE_S3


GO
