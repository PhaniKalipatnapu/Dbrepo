/****** Object:  StoredProcedure [dbo].[AFMS_RETRIEVE_S7]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[AFMS_RETRIEVE_S7] (
 @Ac_ActivityMajor_CODE     CHAR(4),
 @Ac_ActivityMinor_CODE     CHAR(5),
 @Ac_Reason_CODE            CHAR(2),
 @Ac_ActivityMajorNext_CODE CHAR(4),
 @Ac_ActivityMinorNext_CODE CHAR(5),
 @Ac_Notice_ID              CHAR(8),
 @Ac_Exists_INDC            CHAR(1) OUTPUT
 )
AS
 /*
 *      PROCEDURE NAME    : AFMS_RETRIEVE_S7
  *     DESCRIPTION       : Return 1 if exists for the given Major and Minor Activity when End Validity date is equal to High date.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 09-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
 
  DECLARE 
    @Lc_No_TEXT	CHAR(1)	= 'N',
    @Lc_Yes_TEXT	CHAR(1)	= 'Y',
    @Ld_High_DATE DATE = '12/31/9999';

  SET @Ac_Exists_INDC = @Lc_No_TEXT;	
     
  SELECT @Ac_Exists_INDC = @Lc_Yes_TEXT
    FROM AFMS_Y1 AF
   WHERE AF.ActivityMajor_CODE = @Ac_ActivityMajor_CODE
     AND AF.ActivityMinor_CODE = @Ac_ActivityMinor_CODE
     AND AF.Reason_CODE = @Ac_Reason_CODE
     AND AF.ActivityMajorNext_CODE = @Ac_ActivityMajorNext_CODE
     AND AF.ActivityMinorNext_CODE = @Ac_ActivityMinorNext_CODE
     AND AF.Notice_ID = @Ac_Notice_ID
     AND AF.EndValidity_DATE = @Ld_High_DATE;
 END; -- End Of AFMS_RETRIEVE_S7

GO
