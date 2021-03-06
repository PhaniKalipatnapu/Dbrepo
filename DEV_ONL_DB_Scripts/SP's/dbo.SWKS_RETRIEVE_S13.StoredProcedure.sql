/****** Object:  StoredProcedure [dbo].[SWKS_RETRIEVE_S13]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SWKS_RETRIEVE_S13] (
 @An_Schedule_NUMB           NUMERIC(10, 0),
 @Ac_TypeActivity_CODE       CHAR(1) OUTPUT,
 @Ac_MemberCombinations_CODE CHAR(1) OUTPUT
 )
AS

/*
 *     PROCEDURE NAME    : SWKS_RETRIEVE_S13
 *     DESCRIPTION       : Retrieve Member Combinations Code of the Case Members who are the Participants of the Appointment and Type of Process for which the location is available.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 27-AUG-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/
 BEGIN
   DECLARE 
      @Ld_High_DATE DATE = '12/31/9999';
    
  SELECT @Ac_MemberCombinations_CODE = NULL,
         @Ac_TypeActivity_CODE = NULL;



  SELECT TOP 1 @Ac_MemberCombinations_CODE = A.MemberCombinations_CODE,
               @Ac_TypeActivity_CODE = S.TypeActivity_CODE
    FROM AMNR_Y1 A
         JOIN SWKS_Y1 S
          ON A.ActivityMinor_CODE = S.ActivityMinor_CODE
   WHERE S.Schedule_NUMB = @An_Schedule_NUMB
     AND A.EndValidity_DATE = @Ld_High_DATE;
 END; --END OF SWKS_RETRIEVE_S13


GO
