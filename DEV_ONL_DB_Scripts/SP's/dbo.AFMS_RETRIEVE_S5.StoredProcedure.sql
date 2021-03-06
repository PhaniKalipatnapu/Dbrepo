/****** Object:  StoredProcedure [dbo].[AFMS_RETRIEVE_S5]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[AFMS_RETRIEVE_S5] (
 @Ac_ActivityMajor_CODE     CHAR(4),
 @Ac_ActivityMinor_CODE     CHAR(5),
 @Ac_Reason_CODE            CHAR(2),
 @Ac_ActivityMajorNext_CODE CHAR(4),
 @Ac_ActivityMinorNext_CODE CHAR(5)
 )
AS
 /*
  *     PROCEDURE NAME    : AFMS_RETRIEVE_S5
  *     DESCRIPTION       : Fetch Minor Activity for which the forms has to be generated, code given for the form and the description or Name of the notice for the given Major and Minor activity and Reason when End Validity date is equal to High date.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 09-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Ld_High_DATE DATE = '12/31/9999';

  SELECT DISTINCT
         a.ActivityMinor_CODE,
         a.Notice_ID,
         b.DescriptionNotice_TEXT
    FROM AFMS_Y1 a
         JOIN NREF_Y1 b
          ON a.Notice_ID = b.Notice_ID
   WHERE a.ActivityMajor_CODE = @Ac_ActivityMajor_CODE
     AND a.ActivityMinor_CODE = @Ac_ActivityMinor_CODE
     AND a.Reason_CODE = @Ac_Reason_CODE
     AND a.ActivityMajorNext_CODE = @Ac_ActivityMajorNext_CODE
     AND a.ActivityMinorNext_CODE = @Ac_ActivityMinorNext_CODE
     AND a.EndValidity_DATE = @Ld_High_DATE
     AND b.EndValidity_DATE = @Ld_High_DATE
   ORDER BY a.ActivityMinor_CODE,
            a.Notice_ID;
 END; --End Of AFMS_RETRIEVE_S5

GO
