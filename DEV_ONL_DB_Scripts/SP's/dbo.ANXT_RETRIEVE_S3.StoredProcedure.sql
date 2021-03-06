/****** Object:  StoredProcedure [dbo].[ANXT_RETRIEVE_S3]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[ANXT_RETRIEVE_S3] (
 @Ac_ActivityMajor_CODE     CHAR(4),
 @Ac_ActivityMinor_CODE     CHAR(5),
 @An_ActivityOrder_QNTY     NUMERIC(3, 0) OUTPUT,
 @Ac_ActivityMajorNext_CODE CHAR(4) OUTPUT
 )
AS
 /*
 *      PROCEDURE NAME    : ANXT_RETRIEVE_S3
  *     DESCRIPTION       : Fetch sequence of order of Minor Activities with in the Remedy for the given Major and Minor activity when End Validity date should be equal to High date.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 09-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SELECT @An_ActivityOrder_QNTY = NULL,
         @Ac_ActivityMajorNext_CODE = NULL;

  DECLARE @Ld_High_DATE DATE = '12/31/9999';

  SELECT DISTINCT
         @An_ActivityOrder_QNTY = a.ActivityOrder_QNTY,
         @Ac_ActivityMajorNext_CODE = a.ActivityMajorNext_CODE
    FROM ANXT_Y1 a
   WHERE a.ActivityMajor_CODE = @Ac_ActivityMajor_CODE
     AND a.ActivityMinor_CODE = @Ac_ActivityMinor_CODE
     AND a.EndValidity_DATE = @Ld_High_DATE;
 END; -- End Of ANXT_RETRIEVE_S3

GO
